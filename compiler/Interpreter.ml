open Cps
open InterpreterUtils
open InterpreterProjectors
open InterpreterBorrows
open InterpreterStatements
open LlbcAstUtils
open Types
open TypesUtils
open Values
open LlbcAst
open Contexts
open SynthesizeSymbolic
open Errors
module SA = SymbolicAst

(** The local logger *)
let log = Logging.interpreter_log

let compute_contexts (m : crate) : decls_ctx =
  let type_decls_list, _, _, _, _, _ = split_declarations m.declarations in
  let type_decls = m.type_decls in
  let fun_decls = m.fun_decls in
  let global_decls = m.global_decls in
  let trait_decls = m.trait_decls in
  let trait_impls = m.trait_impls in
  let type_decls_groups, _, _, _, _ =
    split_declarations_to_group_maps m.declarations
  in
  let type_infos =
    TypesAnalysis.analyze_type_declarations type_decls type_decls_list
  in
  let type_ctx = { type_decls_groups; type_decls; type_infos } in
  let fun_infos =
    FunsAnalysis.analyze_module m fun_decls global_decls !Config.use_state
  in
  let regions_hierarchies =
    RegionsHierarchy.compute_regions_hierarchies type_decls fun_decls
      global_decls trait_decls trait_impls
  in
  let fun_ctx = { fun_decls; fun_infos; regions_hierarchies } in
  let global_ctx = { global_decls } in
  let trait_decls_ctx = { trait_decls } in
  let trait_impls_ctx = { trait_impls } in
  { type_ctx; fun_ctx; global_ctx; trait_decls_ctx; trait_impls_ctx }

(** Small helper.

    Normalize an instantiated function signature provided we used this signature
    to compute a normalization map (for the associated types) and that we added
    it in the context.
 *)
let normalize_inst_fun_sig (span : Meta.span) (ctx : eval_ctx)
    (sg : inst_fun_sig) : inst_fun_sig =
  let { regions_hierarchy = _; trait_type_constraints = _; inputs; output } =
    sg
  in
  let norm = AssociatedTypes.ctx_normalize_ty span ctx in
  let inputs = List.map norm inputs in
  let output = norm output in
  { sg with inputs; output }

(** Instantiate a function signature for a symbolic execution.

    We return a new context because we compute and add the type normalization
    map in the same step.

    **WARNING**: this doesn't normalize the types. This step has to be done
    separately. Remark: we need to normalize essentially because of the where
    clauses (we are not considering a function call, so we don't need to
    normalize because a trait clause was instantiated with a specific trait ref).
 *)
let symbolic_instantiate_fun_sig (span : Meta.span) (ctx : eval_ctx)
    (sg : fun_sig) (regions_hierarchy : region_var_groups) (kind : item_kind) :
    eval_ctx * inst_fun_sig =
  let tr_self =
    match kind with
    | RegularKind | TraitItemImpl _ -> UnknownTrait __FUNCTION__
    | TraitItemDecl _ | TraitItemProvided _ -> Self
  in
  let generics =
    let { regions; types; const_generics; trait_clauses; _ } = sg.generics in
    let regions = List.map (fun _ -> RErased) regions in
    let types = List.map (fun (v : type_var) -> TVar v.index) types in
    let const_generics =
      List.map (fun (v : const_generic_var) -> CgVar v.index) const_generics
    in
    (* Annoying that we have to generate this substitution here *)
    let r_subst _ = craise __FILE__ __LINE__ span "Unexpected region" in
    let ty_subst =
      Substitute.make_type_subst_from_vars sg.generics.types types
    in
    let cg_subst =
      Substitute.make_const_generic_subst_from_vars sg.generics.const_generics
        const_generics
    in
    (* TODO: some clauses may use the types of other clauses, so we may have to
       reorder them.

       Example:
       If in Rust we write:
       {[
         pub fn use_get<'a, T: Get>(x: &'a mut T) -> u32
         where
             T::Item: ToU32,
         {
             x.get().to_u32()
         }
       ]}

       In LLBC we get:
       {[
         fn demo::use_get<'a, T>(@1: &'a mut (T)) -> u32
         where
             [@TraitClause0]: demo::Get<T>,
             [@TraitClause1]: demo::ToU32<@TraitClause0::Item>, // HERE
         {
             ... // Omitted
         }
       ]}
    *)
    (* We will need to update the trait refs map while we perform the instantiations *)
    let mk_tr_subst (tr_map : trait_instance_id TraitClauseId.Map.t) clause_id :
        trait_instance_id =
      match TraitClauseId.Map.find_opt clause_id tr_map with
      | Some tr -> tr
      | None -> craise __FILE__ __LINE__ span "Local trait clause not found"
    in
    let mk_subst tr_map =
      let tr_subst = mk_tr_subst tr_map in
      { Substitute.r_subst; ty_subst; cg_subst; tr_subst; tr_self }
    in
    let _, trait_refs =
      List.fold_left_map
        (fun tr_map (c : trait_clause) ->
          let subst = mk_subst tr_map in
          let { trait_id = trait_decl_id; clause_generics; _ } = c in
          let generics =
            Substitute.generic_args_substitute subst clause_generics
          in
          let trait_decl_ref = { trait_decl_id; decl_generics = generics } in
          (* Note that because we directly refer to the clause, we give it
             empty generics *)
          let trait_id = Clause c.clause_id in
          let trait_ref =
            { trait_id; generics = empty_generic_args; trait_decl_ref }
          in
          (* Update the traits map *)
          let tr_map = TraitClauseId.Map.add c.clause_id trait_id tr_map in
          (tr_map, trait_ref))
        TraitClauseId.Map.empty trait_clauses
    in
    { regions; types; const_generics; trait_refs }
  in
  let inst_sg =
    instantiate_fun_sig span ctx generics tr_self sg regions_hierarchy
  in
  (* Compute the normalization maps *)
  let ctx =
    AssociatedTypes.ctx_add_norm_trait_types_from_preds span ctx
      inst_sg.trait_type_constraints
  in
  (* Normalize the signature *)
  let inst_sg = normalize_inst_fun_sig span ctx inst_sg in
  (* Return *)
  (ctx, inst_sg)

(** Initialize an evaluation context to execute a function.

    Introduces local variables initialized in the following manner:
    - input arguments are initialized as symbolic values
    - the remaining locals are initialized as [⊥]
    Abstractions are introduced for the regions present in the function
    signature.

    We return:
    - the initialized evaluation context
    - the list of symbolic values introduced for the input values
    - the instantiated function signature
 *)
let initialize_symbolic_context_for_fun (ctx : decls_ctx) (fdef : fun_decl) :
    eval_ctx * symbolic_value list * inst_fun_sig =
  (* The abstractions are not initialized the same way as for function
   * calls: they contain *loan* projectors, because they "provide" us
   * with the input values (which behave as if they had been returned
   * by some function calls...).
   * Also, note that we properly set the set of parents of every abstraction:
   * this should not be necessary, as those abstractions should never be
   * *automatically* ended (because ending some borrows requires to end
   * one of them), but rather selectively ended when generating code
   * for each of the backward functions. We do it only because we can
   * do it, and because it gives a bit of sanity.
   * *)
  let sg = fdef.signature in
  (* Sanity check: no nested borrows, borrows in ADTs, etc. *)
  cassert __FILE__ __LINE__
    (List.for_all
       (fun ty -> not (ty_has_nested_borrows ctx.type_ctx.type_infos ty))
       (sg.output :: sg.inputs))
    fdef.item_meta.span "Nested borrows are not supported yet";
  cassert __FILE__ __LINE__
    (List.for_all
       (fun ty -> not (ty_has_adt_with_borrows ctx.type_ctx.type_infos ty))
       (sg.output :: sg.inputs))
    fdef.item_meta.span "ADTs containing borrows are not supported yet";

  (* Create the context *)
  let regions_hierarchy =
    FunIdMap.find (FRegular fdef.def_id) ctx.fun_ctx.regions_hierarchies
  in
  let region_groups =
    List.map (fun (g : region_var_group) -> g.id) regions_hierarchy
  in
  let ctx =
    initialize_eval_ctx fdef.item_meta.span ctx region_groups sg.generics.types
      sg.generics.const_generics
  in
  (* Instantiate the signature. This updates the context because we compute
     at the same time the normalization map for the associated types.
  *)
  let ctx, inst_sg =
    symbolic_instantiate_fun_sig fdef.item_meta.span ctx fdef.signature
      regions_hierarchy fdef.kind
  in
  (* Create fresh symbolic values for the inputs *)
  let input_svs =
    List.map
      (fun ty -> mk_fresh_symbolic_value fdef.item_meta.span ty)
      inst_sg.inputs
  in
  (* Initialize the abstractions as empty (i.e., with no avalues) abstractions *)
  let call_id = fresh_fun_call_id () in
  sanity_check __FILE__ __LINE__ (call_id = FunCallId.zero) fdef.item_meta.span;
  let compute_abs_avalues (abs : abs) (ctx : eval_ctx) :
      eval_ctx * typed_avalue list =
    (* Project over the values - we use *loan* projectors, as explained above *)
    let avalues =
      List.map (mk_aproj_loans_value_from_symbolic_value abs.regions) input_svs
    in
    (ctx, avalues)
  in
  let region_can_end _ = false in
  let ctx =
    create_push_abstractions_from_abs_region_groups
      (fun rg_id -> SynthInput rg_id)
      inst_sg.regions_hierarchy region_can_end compute_abs_avalues ctx
  in
  (* Split the variables between return var, inputs and remaining locals *)
  let body = Option.get fdef.body in
  let ret_var = List.hd body.locals in
  let input_vars, local_vars =
    Collections.List.split_at (List.tl body.locals) body.arg_count
  in
  (* Push the return variable (initialized with ⊥) *)
  let ctx = ctx_push_uninitialized_var fdef.item_meta.span ctx ret_var in
  (* Push the input variables (initialized with symbolic values) *)
  let input_values = List.map mk_typed_value_from_symbolic_value input_svs in
  let ctx =
    ctx_push_vars fdef.item_meta.span ctx (List.combine input_vars input_values)
  in
  (* Push the remaining local variables (initialized with ⊥) *)
  let ctx = ctx_push_uninitialized_vars fdef.item_meta.span ctx local_vars in
  (* Return *)
  (ctx, input_svs, inst_sg)

(** Small helper.

    This is a continuation function called by the symbolic interpreter upon
    reaching the [return] instruction when synthesizing a *backward* function:
    this continuation takes care of doing the proper manipulations to finish
    the synthesis (mostly by ending abstractions).

    [is_regular_return]: [true] if we reached a [Return] instruction (i.e., the
    result is {!constructor:Cps.statement_eval_res.Return} or {!constructor:Cps.statement_eval_res.LoopReturn}).

    [inside_loop]: [true] if we are *inside* a loop (result [EndContinue]).
*)
let evaluate_function_symbolic_synthesize_backward_from_return (config : config)
    (fdef : fun_decl) (inst_sg : inst_fun_sig) (back_id : RegionGroupId.id)
    (loop_id : LoopId.id option) (is_regular_return : bool) (inside_loop : bool)
    (ctx : eval_ctx) : SA.expression =
  log#ldebug
    (lazy
      ("evaluate_function_symbolic_synthesize_backward_from_return:"
     ^ "\n- fname: "
      ^ Print.EvalCtx.name_to_string ctx fdef.item_meta.name
      ^ "\n- back_id: "
      ^ RegionGroupId.to_string back_id
      ^ "\n- loop_id: "
      ^ Print.option_to_string LoopId.to_string loop_id
      ^ "\n- is_regular_return: "
      ^ Print.bool_to_string is_regular_return
      ^ "\n- inside_loop: "
      ^ Print.bool_to_string inside_loop
      ^ "\n- ctx:\n"
      ^ Print.Contexts.eval_ctx_to_string ~span:(Some fdef.item_meta.span) ctx));
  (* We need to instantiate the function signature - to retrieve
   * the return type. Note that it is important to re-generate
   * an instantiation of the signature, so that we use fresh
   * region ids for the return abstractions. *)
  let regions_hierarchy =
    FunIdMap.find (FRegular fdef.def_id) ctx.fun_ctx.regions_hierarchies
  in
  let _, ret_inst_sg =
    symbolic_instantiate_fun_sig fdef.item_meta.span ctx fdef.signature
      regions_hierarchy fdef.kind
  in
  let ret_rty = ret_inst_sg.output in
  (* Move the return value out of the return variable *)
  let pop_return_value = is_regular_return in
  let ret_value, ctx, cc =
    pop_frame config fdef.item_meta.span pop_return_value ctx
  in

  (* We need to find the parents regions/abstractions of the region we
   * will end - this will allow us to, first, mark the other return
   * regions as non-endable, and, second, end those parent regions in
   * proper order. *)
  let parent_rgs = list_ancestor_region_groups regions_hierarchy back_id in
  let parent_input_abs_ids =
    RegionGroupId.mapi
      (fun rg_id rg ->
        if RegionGroupId.Set.mem rg_id parent_rgs then Some rg.id else None)
      inst_sg.regions_hierarchy
  in
  let parent_input_abs_ids =
    List.filter_map (fun x -> x) parent_input_abs_ids
  in
  (* TODO: need to be careful for loops *)
  assert (parent_input_abs_ids = []);

  (* Insert the return value in the return abstractions (by applying
   * borrow projections) *)
  let ctx =
    if is_regular_return then (
      let ret_value = Option.get ret_value in
      let compute_abs_avalues (abs : abs) (ctx : eval_ctx) :
          eval_ctx * typed_avalue list =
        let ctx, avalue =
          apply_proj_borrows_on_input_value config fdef.item_meta.span ctx
            abs.regions abs.ancestors_regions ret_value ret_rty
        in
        (ctx, [ avalue ])
      in

      (* Initialize and insert the abstractions in the context.
       *
       * We take care of allowing to end only the regions which should end (note
       * that this is important for soundness: this is part of the borrow checking).
       * Also see the documentation of the [can_end] field of [abs] for more
       * information. *)
      let parent_and_current_rgs = RegionGroupId.Set.add back_id parent_rgs in
      let region_can_end rid =
        RegionGroupId.Set.mem rid parent_and_current_rgs
      in
      sanity_check __FILE__ __LINE__ (region_can_end back_id)
        fdef.item_meta.span;
      let ctx =
        create_push_abstractions_from_abs_region_groups
          (fun rg_id -> SynthRet rg_id)
          ret_inst_sg.regions_hierarchy region_can_end compute_abs_avalues ctx
      in
      ctx)
    else ctx
  in
  log#ldebug
    (lazy
      ("evaluate_function_symbolic_synthesize_backward_from_return: (after \
        putting the return value in the proper abstraction)\n" ^ "\n- ctx:\n"
      ^ Print.Contexts.eval_ctx_to_string ~span:(Some fdef.item_meta.span) ctx));

  (* We now need to end the proper *input* abstractions - pay attention
   * to the fact that we end the *input* abstractions, not the *return*
   * abstractions (of course, the corresponding return abstractions will
   * automatically be ended, because they consumed values coming from the
   * input abstractions...) *)
  (* End the parent abstractions and the current abstraction - note that we
   * end them in an order which follows the regions hierarchy: it should lead
   * to generated code which has a better consistency between the parent
   * and children backward functions.
   *
   * Note that we don't end the same abstraction if we are *inside* a loop (i.e.,
   * we are evaluating an [EndContinue]) or not.
   *)
  let current_abs_id, end_fun_synth_input =
    let fun_abs_id = (RegionGroupId.nth inst_sg.regions_hierarchy back_id).id in
    if not inside_loop then (Some fun_abs_id, true)
    else
      (* We are inside a loop *)
      let pred (abs : abs) =
        match abs.kind with
        | Loop (_, rg_id', kind) ->
            let rg_id' = Option.get rg_id' in
            let is_ret =
              match kind with
              | LoopSynthInput -> true
              | LoopCall -> false
            in
            rg_id' = back_id && is_ret
        | _ -> false
      in
      (* There is not necessarily an input synthesis abstraction specifically
         for the loop.
         If there is none, the input synthesis abstraction is actually the
         function input synthesis abstraction.

         Example:
         ========
         {[
           fn clear(v: &mut Vec<u32>) {
               let mut i = 0;
               while i < v.len() {
                   v[i] = 0;
                   i += 1;
               }
           }
         ]}
      *)
      match ctx_find_abs ctx pred with
      | None ->
          (* The loop gives back nothing for this region group.
             Ex.:
             {[
               pub fn ignore_input_mut_borrow(_a: &mut u32) {
                   loop {}
               }
             ]}
          *)
          (* If we are borrow-checking: end the synth input abstraction to
             check there is no borrow-checking issue.
             Otherwise, do nothing.

             We need this check because of the following:
             {[
               fn loop_reborrow_mut1<'a, 'b>(a: &'a mut u32, b: &'b mut u32) -> &'a mut u32 {
                   let mut x = 0;
                   while x > 0 {
                       x += 1;
                   }
                   if x > 0 {
                       a
                   } else {
                       b // Failure
                   }
               }
             ]}
             (remark: this is slightly ad-hoc, and we won't need to do that
              once we make the handling of loops more general).
          *)
          if !Config.borrow_check then (Some fun_abs_id, true) else (None, false)
      | Some abs -> (Some abs.abs_id, false)
  in
  log#ldebug
    (lazy
      ("evaluate_function_symbolic_synthesize_backward_from_return: ending \
        input abstraction: "
      ^ Print.option_to_string AbstractionId.to_string current_abs_id));

  (* Set the proper abstractions as endable *)
  let ctx =
    let visit_loop_abs =
      object
        inherit [_] map_eval_ctx

        method! visit_abs _ abs =
          match abs.kind with
          | Loop (loop_id', rg_id', LoopSynthInput) ->
              (* We only allow to end the loop synth input abs for the region
                 group [rg_id] *)
              sanity_check __FILE__ __LINE__
                (if Option.is_some loop_id then loop_id = Some loop_id'
                 else true)
                fdef.item_meta.span;
              (* Loop abstractions *)
              let rg_id' = Option.get rg_id' in
              if rg_id' = back_id && inside_loop then
                { abs with can_end = true }
              else abs
          | Loop (loop_id', _, LoopCall) ->
              (* We can end all the loop call abstractions *)
              sanity_check __FILE__ __LINE__ (loop_id = Some loop_id')
                fdef.item_meta.span;
              { abs with can_end = true }
          | SynthInput rg_id' ->
              if rg_id' = back_id && end_fun_synth_input then
                { abs with can_end = true }
              else abs
          | _ ->
              (* Other abstractions *)
              abs
      end
    in
    visit_loop_abs#visit_eval_ctx () ctx
  in

  let current_abs_id =
    match current_abs_id with
    | None -> []
    | Some id -> [ id ]
  in
  let target_abs_ids = List.append parent_input_abs_ids current_abs_id in
  let ctx, cc =
    comp cc
      (fold_left_apply_continuation
         (fun id ctx -> end_abstraction config fdef.item_meta.span id ctx)
         target_abs_ids ctx)
  in
  (* Generate the Return node *)
  let return_expr =
    match loop_id with
    | None -> SA.Return (ctx, None)
    | Some loop_id -> SA.ReturnWithLoop (loop_id, inside_loop)
  in
  (* Apply *)
  cc return_expr

(** Evaluate a function with the symbolic interpreter.

    We return:
    - the list of symbolic values introduced for the input values (this is
      useful for the synthesis)
    - the symbolic AST generated by the symbolic execution

   If [synthesize] is [true]: we synthesize the symbolic AST that is used for
   the translation. Otherwise, we do not (the symbolic execution then simply
   borrow-checks the function).
 *)
let evaluate_function_symbolic (synthesize : bool) (ctx : decls_ctx)
    (fdef : fun_decl) : symbolic_value list * SA.expression option =
  (* Debug *)
  let name_to_string () =
    Print.Types.name_to_string
      (Print.Contexts.decls_ctx_to_fmt_env ctx)
      fdef.item_meta.name
  in
  log#ldebug (lazy ("evaluate_function_symbolic: " ^ name_to_string ()));

  (* Create the evaluation context *)
  let ctx, input_svs, inst_sg = initialize_symbolic_context_for_fun ctx fdef in

  let regions_hierarchy =
    FunIdMap.find (FRegular fdef.def_id) ctx.fun_ctx.regions_hierarchies
  in

  (* Create the continuation to finish the evaluation *)
  let config = mk_config SymbolicMode in
  let finish (res : statement_eval_res) (ctx : eval_ctx) =
    let ctx0 = ctx in
    log#ldebug
      (lazy
        ("evaluate_function_symbolic: cf_finish: "
        ^ Cps.show_statement_eval_res res));

    match res with
    | Return | LoopReturn _ ->
        (* We have to "play different endings":
         * - one execution for the forward function
         * - one execution per backward function
         * We then group everything together.
         *)
        (* There are two cases:
         * - if this is a forward translation, we retrieve the returned value.
         * - if this is a backward translation, we introduce "return"
         *   abstractions to consume the return value, then end all the
         *   abstractions up to the one in which we are interested.
         *)
        (* Forward translation: retrieve the returned value *)
        let fwd_e =
          (* Pop the frame and retrieve the returned value at the same time *)
          let pop_return_value = true in
          let ret_value, ctx, cc_pop =
            pop_frame config fdef.item_meta.span pop_return_value ctx
          in
          (* Generate the Return node *)
          cc_pop (SA.Return (ctx, ret_value))
        in
        (* Backward translation: introduce "return"
           abstractions to consume the return value, then end all the
           abstractions up to the one in which we are interested.
        *)
        let loop_id =
          match res with
          | Return -> None
          | LoopReturn loop_id -> Some loop_id
          | _ -> craise __FILE__ __LINE__ fdef.item_meta.span "Unreachable"
        in
        let is_regular_return = true in
        let inside_loop = Option.is_some loop_id in
        let finish_back_eval back_id =
          evaluate_function_symbolic_synthesize_backward_from_return config fdef
            inst_sg back_id loop_id is_regular_return inside_loop ctx
        in
        let back_el =
          RegionGroupId.mapi
            (fun gid _ -> (gid, finish_back_eval gid))
            regions_hierarchy
        in
        let back_el = RegionGroupId.Map.of_list back_el in
        (* Put everything together *)
        synthesize_forward_end ctx0 None fwd_e back_el
    | EndEnterLoop (loop_id, loop_input_values)
    | EndContinue (loop_id, loop_input_values) ->
        (* Similar to [Return]: we have to play different endings *)
        let inside_loop =
          match res with
          | EndEnterLoop _ -> false
          | EndContinue _ -> true
          | _ -> craise __FILE__ __LINE__ fdef.item_meta.span "Unreachable"
        in
        (* Forward translation *)
        let fwd_e =
          (* Pop the frame - there is no returned value to pop: in the
             translation we will simply call the loop function *)
          let pop_return_value = false in
          let _ret_value, _ctx, cc_pop =
            pop_frame config fdef.item_meta.span pop_return_value ctx
          in
          (* Generate the Return node *)
          cc_pop (SA.ReturnWithLoop (loop_id, inside_loop))
        in
        (* Backward translation: introduce "return"
           abstractions to consume the return value, then end all the
           abstractions up to the one in which we are interested.
        *)
        let is_regular_return = false in
        let finish_back_eval back_id =
          evaluate_function_symbolic_synthesize_backward_from_return config fdef
            inst_sg back_id (Some loop_id) is_regular_return inside_loop ctx
        in
        let back_el =
          RegionGroupId.mapi
            (fun gid _ -> (gid, finish_back_eval gid))
            regions_hierarchy
        in
        let back_el = RegionGroupId.Map.of_list back_el in
        (* Put everything together *)
        synthesize_forward_end ctx0 (Some loop_input_values) fwd_e back_el
    | Panic ->
        (* Note that as we explore all the execution branches, one of
         * the executions can lead to a panic *)
        SA.Panic
    | Unit | Break _ | Continue _ ->
        craise __FILE__ __LINE__ fdef.item_meta.span
          ("evaluate_function_symbolic failed on: " ^ name_to_string ())
  in

  (* Evaluate the function *)
  let symbolic =
    try
      let ctx_resl, cc =
        eval_function_body config (Option.get fdef.body).body ctx
      in
      let el = List.map (fun (ctx, res) -> finish res ctx) ctx_resl in
      (* Finish synthesizing *)
      if synthesize then Some (cc el) else None
    with CFailure (span, msg) ->
      if synthesize then Some (Error (span, msg)) else None
  in
  (* Return *)
  (input_svs, symbolic)

module Test = struct
  (** Test a unit function (taking no arguments) by evaluating it in an empty
      environment.
   *)
  let test_unit_function (crate : crate) (decls_ctx : decls_ctx)
      (fid : FunDeclId.id) : unit =
    (* Retrieve the function declaration *)
    let fdef = FunDeclId.Map.find fid crate.fun_decls in
    let body = Option.get fdef.body in

    (* Debug *)
    log#ldebug
      (lazy
        ("test_unit_function: "
        ^ Print.Types.name_to_string
            (Print.Contexts.decls_ctx_to_fmt_env decls_ctx)
            fdef.item_meta.name));

    (* Sanity check - *)
    sanity_check __FILE__ __LINE__
      (fdef.signature.generics = empty_generic_params)
      fdef.item_meta.span;
    sanity_check __FILE__ __LINE__ (body.arg_count = 0) fdef.item_meta.span;

    (* Create the evaluation context *)
    let ctx = initialize_eval_ctx fdef.item_meta.span decls_ctx [] [] [] in

    (* Insert the (uninitialized) local variables *)
    let ctx = ctx_push_uninitialized_vars fdef.item_meta.span ctx body.locals in

    (* Create the continuation to check the function's result *)
    let config = mk_config ConcreteMode in
    let check (res : statement_eval_res) (ctx : eval_ctx) =
      match res with
      | Return ->
          (* Ok: drop the local variables and finish *)
          let pop_return_value = true in
          pop_frame config fdef.item_meta.span pop_return_value ctx
      | _ ->
          craise __FILE__ __LINE__ fdef.item_meta.span
            ("Unit test failed (concrete execution) on: "
            ^ Print.Types.name_to_string
                (Print.Contexts.decls_ctx_to_fmt_env decls_ctx)
                fdef.item_meta.name)
    in
    (* Evaluate the function *)
    let ctx_resl, _ = eval_function_body config body.body ctx in
    let _ = List.map (fun (ctx, res) -> check res ctx) ctx_resl in
    ()

  (** Small helper: return true if the function is a *transparent* unit function
      (no parameters, no arguments) - TODO: move *)
  let fun_decl_is_transparent_unit (def : fun_decl) : bool =
    Option.is_some def.body
    && def.signature.generics = empty_generic_params
    && def.signature.inputs = []

  (** Test all the unit functions in a list of function definitions *)
  let test_unit_functions (crate : crate) : unit =
    let unit_funs =
      FunDeclId.Map.filter
        (fun _ -> fun_decl_is_transparent_unit)
        crate.fun_decls
    in
    let decls_ctx = compute_contexts crate in
    let test_unit_fun _ (def : fun_decl) : unit =
      test_unit_function crate decls_ctx def.def_id
    in
    FunDeclId.Map.iter test_unit_fun unit_funs
end
