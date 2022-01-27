(** This module defines printing functions for the types defined in Pure.ml *)

open Errors
open Identifiers
open Pure
module T = Types
module V = Values
module E = Expressions
module A = CfimAst
module TypeDefId = T.TypeDefId
module TypeVarId = T.TypeVarId
module RegionId = T.RegionId
module VariantId = T.VariantId
module FieldId = T.FieldId
module SymbolicValueId = V.SymbolicValueId
module FunDefId = A.FunDefId

type type_formatter = {
  type_var_id_to_string : TypeVarId.id -> string;
  type_def_id_to_string : TypeDefId.id -> string;
}

type value_formatter = {
  type_var_id_to_string : TypeVarId.id -> string;
  type_def_id_to_string : TypeDefId.id -> string;
  adt_variant_to_string : TypeDefId.id -> VariantId.id -> string;
  var_id_to_string : VarId.id -> string;
  adt_field_names : TypeDefId.id -> VariantId.id option -> string list option;
}

let value_to_type_formatter (fmt : value_formatter) : type_formatter =
  {
    type_var_id_to_string = fmt.type_var_id_to_string;
    type_def_id_to_string = fmt.type_def_id_to_string;
  }

type ast_formatter = {
  type_var_id_to_string : TypeVarId.id -> string;
  type_def_id_to_string : TypeDefId.id -> string;
  adt_variant_to_string : TypeDefId.id -> VariantId.id -> string;
  var_id_to_string : VarId.id -> string;
  adt_field_to_string :
    TypeDefId.id -> VariantId.id option -> FieldId.id -> string;
  adt_field_names : TypeDefId.id -> VariantId.id option -> string list option;
  fun_def_id_to_string : A.FunDefId.id -> string;
}

let ast_to_value_formatter (fmt : ast_formatter) : value_formatter =
  {
    type_var_id_to_string = fmt.type_var_id_to_string;
    type_def_id_to_string = fmt.type_def_id_to_string;
    adt_variant_to_string = fmt.adt_variant_to_string;
    var_id_to_string = fmt.var_id_to_string;
    adt_field_names = fmt.adt_field_names;
  }

let ast_to_type_formatter (fmt : ast_formatter) : type_formatter =
  let fmt = ast_to_value_formatter fmt in
  value_to_type_formatter fmt

let name_to_string = Print.name_to_string

let option_to_string = Print.option_to_string

let type_var_to_string = Print.Types.type_var_to_string

let scalar_value_to_string = Print.Values.scalar_value_to_string

(* TODO: there is a bit of duplication with Print.fun_def_to_ast_formatter.

   TODO: use the pure defs as inputs? Note that it is a bit annoying for the
   functions (there is a difference between the forward/backward functions...)
   while we only need those definitions to lookup proper names for the def ids.
*)
let fun_def_to_ast_formatter (type_defs : T.type_def TypeDefId.Map.t)
    (fun_defs : A.fun_def FunDefId.Map.t) (fdef : A.fun_def) : ast_formatter =
  let type_var_id_to_string vid =
    let var = T.TypeVarId.nth fdef.signature.type_params vid in
    type_var_to_string var
  in
  let type_def_id_to_string def_id =
    let def = T.TypeDefId.Map.find def_id type_defs in
    name_to_string def.name
  in
  let adt_variant_to_string =
    Print.Contexts.type_ctx_to_adt_variant_to_string_fun type_defs
  in
  let var_id_to_string vid =
    (* TODO: lookup in the context *)
    VarId.to_string vid
  in
  let adt_field_names =
    Print.Contexts.type_ctx_to_adt_field_names_fun type_defs
  in
  let adt_field_to_string =
    Print.CfimAst.type_ctx_to_adt_field_to_string_fun type_defs
  in
  let fun_def_id_to_string def_id =
    let def = A.FunDefId.Map.find def_id fun_defs in
    name_to_string def.name
  in
  {
    type_var_id_to_string;
    type_def_id_to_string;
    adt_variant_to_string;
    var_id_to_string;
    adt_field_names;
    adt_field_to_string;
    fun_def_id_to_string;
  }

let type_id_to_string (fmt : type_formatter) (id : T.type_id) : string =
  match id with
  | T.AdtId id -> fmt.type_def_id_to_string id
  | T.Tuple -> ""
  | T.Assumed aty -> (
      match aty with
      | Box -> (* Boxes should have been eliminated *) failwith "Unreachable")

let rec ty_to_string (fmt : type_formatter) (ty : ty) : string =
  match ty with
  | Adt (id, tys) -> (
      let tys = List.map (ty_to_string fmt) tys in
      match id with
      | T.Tuple -> "(" ^ String.concat " * " tys ^ ")"
      | T.AdtId _ | T.Assumed _ ->
          let tys = if tys = [] then "" else " " ^ String.concat " " tys in
          type_id_to_string fmt id ^ tys)
  | TypeVar tv -> fmt.type_var_id_to_string tv
  | Bool -> "bool"
  | Char -> "char"
  | Integer int_ty -> Print.Types.integer_type_to_string int_ty
  | Str -> "str"
  | Array aty -> "[" ^ ty_to_string fmt aty ^ "; ?]"
  | Slice sty -> "[" ^ ty_to_string fmt sty ^ "]"

let field_to_string fmt (f : field) : string =
  f.field_name ^ " : " ^ ty_to_string fmt f.field_ty

let variant_to_string fmt (v : variant) : string =
  v.variant_name ^ "("
  ^ String.concat ", " (List.map (field_to_string fmt) v.fields)
  ^ ")"

let type_def_to_string (type_def_id_to_string : TypeDefId.id -> string)
    (def : type_def) : string =
  let types = def.type_params in
  let type_var_id_to_string id =
    match List.find_opt (fun tv -> tv.T.index = id) types with
    | Some tv -> type_var_to_string tv
    | None -> failwith "Unreachable"
  in
  let fmt = { type_var_id_to_string; type_def_id_to_string } in
  let name = name_to_string def.name in
  let params =
    if types = [] then ""
    else " " ^ String.concat " " (List.map type_var_to_string types)
  in
  match def.kind with
  | Struct fields ->
      if List.length fields > 0 then
        let fields =
          String.concat ","
            (List.map (fun f -> "\n  " ^ field_to_string fmt f) fields)
        in
        "struct " ^ name ^ params ^ "{" ^ fields ^ "}"
      else "struct " ^ name ^ params ^ "{}"
  | Enum variants ->
      let variants =
        List.map (fun v -> "|  " ^ variant_to_string fmt v) variants
      in
      let variants = String.concat "\n" variants in
      "enum " ^ name ^ params ^ " =\n" ^ variants

let var_to_string (fmt : type_formatter) (v : var) : string =
  "(" ^ VarId.to_string v.id ^ " : " ^ ty_to_string fmt v.ty ^ ")"

let var_or_dummy_to_string (fmt : value_formatter) (v : var_or_dummy) : string =
  match v with
  | Var v -> var_to_string (value_to_type_formatter fmt) v
  | Dummy -> "_"

let rec typed_lvalue_to_string (fmt : value_formatter) (v : typed_lvalue) :
    string =
  match v.value with
  | LvVar var -> var_or_dummy_to_string fmt var
  | LvTuple values ->
      "("
      ^ String.concat ", " (List.map (typed_lvalue_to_string fmt) values)
      ^ ")"

let rec projection_to_string (fmt : ast_formatter) (inside : string)
    (p : projection) : string =
  match p with
  | [] -> inside
  | pe :: p' -> (
      let s = projection_to_string fmt inside p' in
      match pe.pkind with
      | E.ProjTuple _ -> "(" ^ s ^ ")." ^ T.FieldId.to_string pe.field_id
      | E.ProjAdt (adt_id, opt_variant_id) -> (
          let field_name =
            fmt.adt_field_to_string adt_id opt_variant_id pe.field_id
          in
          match opt_variant_id with
          | None -> "(" ^ s ^ ")." ^ field_name
          | Some variant_id ->
              let variant_name = fmt.adt_variant_to_string adt_id variant_id in
              "(" ^ s ^ " as " ^ variant_name ^ ")." ^ field_name))

let place_to_string (fmt : ast_formatter) (p : place) : string =
  let var = fmt.var_id_to_string p.var in
  projection_to_string fmt var p.projection

let rec typed_rvalue_to_string (fmt : ast_formatter) (v : typed_rvalue) : string
    =
  match v.value with
  | RvConcrete cv -> Print.Values.constant_value_to_string cv
  | RvPlace p -> place_to_string fmt p
  | RvAdt av -> (
      let field_values =
        List.map (typed_rvalue_to_string fmt) av.field_values
      in
      match v.ty with
      | Adt (T.Tuple, _) ->
          (* Tuple *)
          "(" ^ String.concat ", " field_values ^ ")"
      | Adt (T.AdtId def_id, _) ->
          (* "Regular" ADT *)
          let adt_ident =
            match av.variant_id with
            | Some vid -> fmt.adt_variant_to_string def_id vid
            | None -> fmt.type_def_id_to_string def_id
          in
          if field_values <> [] then
            match fmt.adt_field_names def_id av.variant_id with
            | None ->
                let field_values = String.concat ", " field_values in
                adt_ident ^ " (" ^ field_values ^ ")"
            | Some field_names ->
                let field_values = List.combine field_names field_values in
                let field_values =
                  List.map
                    (fun (field, value) -> field ^ " = " ^ value ^ ";")
                    field_values
                in
                let field_values = String.concat " " field_values in
                adt_ident ^ " { " ^ field_values ^ " }"
          else adt_ident
      | Adt (T.Assumed aty, _) -> (
          (* Assumed type *)
          match aty with
          | Box ->
              (* Box values should have been eliminated *)
              failwith "Unreachable")
      | _ -> failwith "Inconsistent typed value")

let fun_sig_to_string (fmt : ast_formatter) (sg : fun_sig) : string =
  let ty_fmt = ast_to_type_formatter fmt in
  let type_params = List.map type_var_to_string sg.type_params in
  let inputs = List.map (ty_to_string ty_fmt) sg.inputs in
  let outputs = List.map (ty_to_string ty_fmt) sg.outputs in
  let outputs =
    match outputs with
    | [] -> "()"
    | [ out ] -> out
    | outputs -> "(" ^ String.concat " * " outputs ^ ")"
  in
  let all_types = List.concat [ type_params; inputs; [ outputs ] ] in
  String.concat " -> " all_types

let inst_fun_sig_to_string (fmt : ast_formatter) (sg : inst_fun_sig) : string =
  let ty_fmt = ast_to_type_formatter fmt in
  let inputs = List.map (ty_to_string ty_fmt) sg.inputs in
  let outputs = List.map (ty_to_string ty_fmt) sg.outputs in
  let outputs =
    match outputs with
    | [] -> "()"
    | [ out ] -> out
    | outputs -> "(" ^ String.concat " * " outputs ^ ")"
  in
  let all_types = List.append inputs [ outputs ] in
  String.concat " -> " all_types

let rec expression_to_string (fmt : ast_formatter) (indent : string)
    (indent_incr : string) (e : expression) : string =
  match e with
  | Return v -> indent ^ "return " ^ typed_rvalue_to_string fmt v
  | Panic -> indent ^ "panic"
  | Let (lb, e) -> let_to_string fmt indent indent_incr lb e
  | Switch (scrutinee, body) ->
      switch_to_string fmt indent indent_incr scrutinee body

and let_to_string (fmt : ast_formatter) (indent : string) (indent_incr : string)
    (lb : let_bindings) (e : expression) : string =
  raise Unimplemented

and switch_to_string (fmt : ast_formatter) (indent : string)
    (indent_incr : string) (scrutinee : typed_rvalue) (body : switch_body) :
    string =
  let scrut = typed_rvalue_to_string fmt scrutinee in
  let indent1 = indent ^ indent_incr in
  match body with
  | If (e_true, e_false) ->
      let e_true = expression_to_string fmt indent1 indent_incr e_true in
      let e_false = expression_to_string fmt indent1 indent_incr e_false in
      indent ^ "if " ^ scrut ^ "\n" ^ indent ^ "then\n" ^ e_true ^ "\n" ^ indent
      ^ "else\n" ^ e_false
  | SwitchInt (_, branches, otherwise) ->
      let branches =
        List.map
          (fun (v, be) ->
            indent ^ "| " ^ scalar_value_to_string v ^ " ->\n"
            ^ expression_to_string fmt indent1 indent_incr be)
          branches
      in
      let otherwise =
        indent ^ "| _ ->\n"
        ^ expression_to_string fmt indent1 indent_incr otherwise
      in
      let all_branches = List.append branches [ otherwise ] in
      indent ^ "switch " ^ scrut ^ " with\n" ^ String.concat "\n" all_branches
  | Match branches ->
      let val_fmt = ast_to_value_formatter fmt in
      let branch_to_string (b : match_branch) : string =
        let adt_id =
          match scrutinee.ty with
          | Adt (type_id, _) -> (
              match type_id with
              | T.AdtId id -> id
              | T.Tuple | T.Assumed T.Box ->
                  (* We can't match over a tuple or a box value *)
                  failwith "Unreachable")
          | _ -> failwith "Unreachable"
        in
        let cons = fmt.adt_variant_to_string adt_id b.variant_id in
        let pats =
          if b.vars = [] then ""
          else
            " "
            ^ String.concat " "
                (List.map (var_or_dummy_to_string val_fmt) b.vars)
        in
        indent ^ "| " ^ cons ^ pats ^ " ->\n"
        ^ expression_to_string fmt indent1 indent_incr b.branch
      in
      let branches = List.map branch_to_string branches in
      indent ^ "match " ^ scrut ^ " with\n" ^ String.concat "\n" branches
