(** [betree_main]: function definitions *)
open primitivesLib divDefLib
open betreeMain_TypesTheory betreeMain_OpaqueTheory

val _ = new_theory "betreeMain_Funs"


val betree_load_internal_node_fwd_def = Define ‘
  (** [betree_main::betree::load_internal_node]: forward function *)
  betree_load_internal_node_fwd
    (id : u64) (st : state) :
    (state # (u64 # betree_message_t) betree_list_t) result
    =
    betree_utils_load_internal_node_fwd id st
’

val betree_store_internal_node_fwd_def = Define ‘
  (** [betree_main::betree::store_internal_node]: forward function *)
  betree_store_internal_node_fwd
    (id : u64) (content : (u64 # betree_message_t) betree_list_t) (st : state)
    :
    (state # unit) result
    =
    do
    (st0, _) <- betree_utils_store_internal_node_fwd id content st;
    Return (st0, ())
    od
’

val betree_load_leaf_node_fwd_def = Define ‘
  (** [betree_main::betree::load_leaf_node]: forward function *)
  betree_load_leaf_node_fwd
    (id : u64) (st : state) : (state # (u64 # u64) betree_list_t) result =
    betree_utils_load_leaf_node_fwd id st
’

val betree_store_leaf_node_fwd_def = Define ‘
  (** [betree_main::betree::store_leaf_node]: forward function *)
  betree_store_leaf_node_fwd
    (id : u64) (content : (u64 # u64) betree_list_t) (st : state) :
    (state # unit) result
    =
    do
    (st0, _) <- betree_utils_store_leaf_node_fwd id content st;
    Return (st0, ())
    od
’

val betree_fresh_node_id_fwd_def = Define ‘
  (** [betree_main::betree::fresh_node_id]: forward function *)
  betree_fresh_node_id_fwd (counter : u64) : u64 result =
    do
    _ <- u64_add counter (int_to_u64 1);
    Return counter
    od
’

val betree_fresh_node_id_back_def = Define ‘
  (** [betree_main::betree::fresh_node_id]: backward function 0 *)
  betree_fresh_node_id_back (counter : u64) : u64 result =
    u64_add counter (int_to_u64 1)
’

val betree_node_id_counter_new_fwd_def = Define ‘
  (** [betree_main::betree::NodeIdCounter::{0}::new]: forward function *)
  betree_node_id_counter_new_fwd : betree_node_id_counter_t result =
    Return (<| betree_node_id_counter_next_node_id := (int_to_u64 0) |>)
’

val betree_node_id_counter_fresh_id_fwd_def = Define ‘
  (** [betree_main::betree::NodeIdCounter::{0}::fresh_id]: forward function *)
  betree_node_id_counter_fresh_id_fwd
    (self : betree_node_id_counter_t) : u64 result =
    do
    _ <- u64_add self.betree_node_id_counter_next_node_id (int_to_u64 1);
    Return self.betree_node_id_counter_next_node_id
    od
’

val betree_node_id_counter_fresh_id_back_def = Define ‘
  (** [betree_main::betree::NodeIdCounter::{0}::fresh_id]: backward function 0 *)
  betree_node_id_counter_fresh_id_back
    (self : betree_node_id_counter_t) : betree_node_id_counter_t result =
    do
    i <- u64_add self.betree_node_id_counter_next_node_id (int_to_u64 1);
    Return (<| betree_node_id_counter_next_node_id := i |>)
    od
’

val betree_upsert_update_fwd_def = Define ‘
  (** [betree_main::betree::upsert_update]: forward function *)
  betree_upsert_update_fwd
    (prev : u64 option) (st : betree_upsert_fun_state_t) : u64 result =
    (case prev of
    | NONE =>
      (case st of
      | BetreeUpsertFunStateAdd v => Return v
      | BetreeUpsertFunStateSub i => Return (int_to_u64 0))
    | SOME prev0 =>
      (case st of
      | BetreeUpsertFunStateAdd v =>
        do
        margin <- u64_sub core_u64_max prev0;
        if u64_ge margin v then u64_add prev0 v else Return core_u64_max
        od
      | BetreeUpsertFunStateSub v =>
        if u64_ge prev0 v then u64_sub prev0 v else Return (int_to_u64 0)))
’

val [betree_list_len_fwd_def] = DefineDiv ‘
  (** [betree_main::betree::List::{1}::len]: forward function *)
  betree_list_len_fwd (self : 't betree_list_t) : u64 result =
    (case self of
    | BetreeListCons t tl =>
      do
      i <- betree_list_len_fwd tl;
      u64_add (int_to_u64 1) i
      od
    | BetreeListNil => Return (int_to_u64 0))
’

val [betree_list_split_at_fwd_def] = DefineDiv ‘
  (** [betree_main::betree::List::{1}::split_at]: forward function *)
  betree_list_split_at_fwd
    (self : 't betree_list_t) (n : u64) :
    ('t betree_list_t # 't betree_list_t) result
    =
    if n = int_to_u64 0
    then Return (BetreeListNil, self)
    else
      (case self of
      | BetreeListCons hd tl =>
        do
        i <- u64_sub n (int_to_u64 1);
        p <- betree_list_split_at_fwd tl i;
        let (ls0, ls1) = p in let l = ls0 in Return (BetreeListCons hd l, ls1)
        od
      | BetreeListNil => Fail Failure)
’

val betree_list_push_front_fwd_back_def = Define ‘
  (** [betree_main::betree::List::{1}::push_front]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  betree_list_push_front_fwd_back
    (self : 't betree_list_t) (x : 't) : 't betree_list_t result =
    let tl = mem_replace_fwd self BetreeListNil in
    let l = tl in
    Return (BetreeListCons x l)
’

val betree_list_pop_front_fwd_def = Define ‘
  (** [betree_main::betree::List::{1}::pop_front]: forward function *)
  betree_list_pop_front_fwd (self : 't betree_list_t) : 't result =
    let ls = mem_replace_fwd self BetreeListNil in
    (case ls of
    | BetreeListCons x tl => Return x
    | BetreeListNil => Fail Failure)
’

val betree_list_pop_front_back_def = Define ‘
  (** [betree_main::betree::List::{1}::pop_front]: backward function 0 *)
  betree_list_pop_front_back
    (self : 't betree_list_t) : 't betree_list_t result =
    let ls = mem_replace_fwd self BetreeListNil in
    (case ls of
    | BetreeListCons x tl => Return tl
    | BetreeListNil => Fail Failure)
’

val betree_list_hd_fwd_def = Define ‘
  (** [betree_main::betree::List::{1}::hd]: forward function *)
  betree_list_hd_fwd (self : 't betree_list_t) : 't result =
    (case self of
    | BetreeListCons hd l => Return hd
    | BetreeListNil => Fail Failure)
’

val betree_list_head_has_key_fwd_def = Define ‘
  (** [betree_main::betree::List::{2}::head_has_key]: forward function *)
  betree_list_head_has_key_fwd
    (self : (u64 # 't) betree_list_t) (key : u64) : bool result =
    (case self of
    | BetreeListCons hd l => let (i, _) = hd in Return (i = key)
    | BetreeListNil => Return F)
’

val [betree_list_partition_at_pivot_fwd_def] = DefineDiv ‘
  (** [betree_main::betree::List::{2}::partition_at_pivot]: forward function *)
  betree_list_partition_at_pivot_fwd
    (self : (u64 # 't) betree_list_t) (pivot : u64) :
    ((u64 # 't) betree_list_t # (u64 # 't) betree_list_t) result
    =
    (case self of
    | BetreeListCons hd tl =>
      let (i, t) = hd in
      if u64_ge i pivot
      then Return (BetreeListNil, BetreeListCons (i, t) tl)
      else (
        do
        p <- betree_list_partition_at_pivot_fwd tl pivot;
        let (ls0, ls1) = p in
        let l = ls0 in
        Return (BetreeListCons (i, t) l, ls1)
        od)
    | BetreeListNil => Return (BetreeListNil, BetreeListNil))
’

val betree_leaf_split_fwd_def = Define ‘
  (** [betree_main::betree::Leaf::{3}::split]: forward function *)
  betree_leaf_split_fwd
    (self : betree_leaf_t) (content : (u64 # u64) betree_list_t)
    (params : betree_params_t) (node_id_cnt : betree_node_id_counter_t)
    (st : state) :
    (state # betree_internal_t) result
    =
    do
    p <- betree_list_split_at_fwd content params.betree_params_split_size;
    let (content0, content1) = p in
    do
    p0 <- betree_list_hd_fwd content1;
    let (pivot, _) = p0 in
    do
    id0 <- betree_node_id_counter_fresh_id_fwd node_id_cnt;
    node_id_cnt0 <- betree_node_id_counter_fresh_id_back node_id_cnt;
    id1 <- betree_node_id_counter_fresh_id_fwd node_id_cnt0;
    (st0, _) <- betree_store_leaf_node_fwd id0 content0 st;
    (st1, _) <- betree_store_leaf_node_fwd id1 content1 st0;
    let n = BetreeNodeLeaf
      (<|
         betree_leaf_id := id0;
         betree_leaf_size := params.betree_params_split_size
         |>) in
    let n0 = BetreeNodeLeaf
      (<|
         betree_leaf_id := id1;
         betree_leaf_size := params.betree_params_split_size
         |>) in
    Return (st1,
      <|
        betree_internal_id := self.betree_leaf_id;
        betree_internal_pivot := pivot;
        betree_internal_left := n;
        betree_internal_right := n0
        |>)
    od
    od
    od
’

val betree_leaf_split_back_def = Define ‘
  (** [betree_main::betree::Leaf::{3}::split]: backward function 2 *)
  betree_leaf_split_back
    (self : betree_leaf_t) (content : (u64 # u64) betree_list_t)
    (params : betree_params_t) (node_id_cnt : betree_node_id_counter_t)
    (st : state) :
    betree_node_id_counter_t result
    =
    do
    p <- betree_list_split_at_fwd content params.betree_params_split_size;
    let (content0, content1) = p in
    do
    _ <- betree_list_hd_fwd content1;
    id0 <- betree_node_id_counter_fresh_id_fwd node_id_cnt;
    node_id_cnt0 <- betree_node_id_counter_fresh_id_back node_id_cnt;
    id1 <- betree_node_id_counter_fresh_id_fwd node_id_cnt0;
    (st0, _) <- betree_store_leaf_node_fwd id0 content0 st;
    _ <- betree_store_leaf_node_fwd id1 content1 st0;
    betree_node_id_counter_fresh_id_back node_id_cnt0
    od
    od
’

val [betree_node_lookup_first_message_for_key_fwd_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::lookup_first_message_for_key]: forward function *)
  betree_node_lookup_first_message_for_key_fwd
    (key : u64) (msgs : (u64 # betree_message_t) betree_list_t) :
    (u64 # betree_message_t) betree_list_t result
    =
    (case msgs of
    | BetreeListCons x next_msgs =>
      let (i, m) = x in
      if u64_ge i key
      then Return (BetreeListCons (i, m) next_msgs)
      else betree_node_lookup_first_message_for_key_fwd key next_msgs
    | BetreeListNil => Return BetreeListNil)
’

val [betree_node_lookup_first_message_for_key_back_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::lookup_first_message_for_key]: backward function 0 *)
  betree_node_lookup_first_message_for_key_back
    (key : u64) (msgs : (u64 # betree_message_t) betree_list_t)
    (ret : (u64 # betree_message_t) betree_list_t) :
    (u64 # betree_message_t) betree_list_t result
    =
    (case msgs of
    | BetreeListCons x next_msgs =>
      let (i, m) = x in
      if u64_ge i key
      then Return ret
      else (
        do
        next_msgs0 <-
          betree_node_lookup_first_message_for_key_back key next_msgs ret;
        Return (BetreeListCons (i, m) next_msgs0)
        od)
    | BetreeListNil => Return ret)
’

val [betree_node_apply_upserts_fwd_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::apply_upserts]: forward function *)
  betree_node_apply_upserts_fwd
    (msgs : (u64 # betree_message_t) betree_list_t) (prev : u64 option)
    (key : u64) (st : state) :
    (state # u64) result
    =
    do
    b <- betree_list_head_has_key_fwd msgs key;
    if b
    then (
      do
      msg <- betree_list_pop_front_fwd msgs;
      let (_, m) = msg in
      (case m of
      | BetreeMessageInsert i => Fail Failure
      | BetreeMessageDelete => Fail Failure
      | BetreeMessageUpsert s =>
        do
        v <- betree_upsert_update_fwd prev s;
        msgs0 <- betree_list_pop_front_back msgs;
        betree_node_apply_upserts_fwd msgs0 (SOME v) key st
        od)
      od)
    else (
      do
      (st0, v) <- core_option_option_unwrap_fwd prev st;
      _ <- betree_list_push_front_fwd_back msgs (key, BetreeMessageInsert v);
      Return (st0, v)
      od)
    od
’

val [betree_node_apply_upserts_back_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::apply_upserts]: backward function 0 *)
  betree_node_apply_upserts_back
    (msgs : (u64 # betree_message_t) betree_list_t) (prev : u64 option)
    (key : u64) (st : state) :
    (u64 # betree_message_t) betree_list_t result
    =
    do
    b <- betree_list_head_has_key_fwd msgs key;
    if b
    then (
      do
      msg <- betree_list_pop_front_fwd msgs;
      let (_, m) = msg in
      (case m of
      | BetreeMessageInsert i => Fail Failure
      | BetreeMessageDelete => Fail Failure
      | BetreeMessageUpsert s =>
        do
        v <- betree_upsert_update_fwd prev s;
        msgs0 <- betree_list_pop_front_back msgs;
        betree_node_apply_upserts_back msgs0 (SOME v) key st
        od)
      od)
    else (
      do
      (_, v) <- core_option_option_unwrap_fwd prev st;
      betree_list_push_front_fwd_back msgs (key, BetreeMessageInsert v)
      od)
    od
’

val [betree_node_lookup_in_bindings_fwd_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::lookup_in_bindings]: forward function *)
  betree_node_lookup_in_bindings_fwd
    (key : u64) (bindings : (u64 # u64) betree_list_t) : u64 option result =
    (case bindings of
    | BetreeListCons hd tl =>
      let (i, i0) = hd in
      if i = key
      then Return (SOME i0)
      else
        if u64_gt i key
        then Return NONE
        else betree_node_lookup_in_bindings_fwd key tl
    | BetreeListNil => Return NONE)
’

val [betree_internal_lookup_in_children_fwd_def, betree_internal_lookup_in_children_back_def, betree_node_lookup_fwd_def, betree_node_lookup_back_def] = DefineDiv ‘
  (** [betree_main::betree::Internal::{4}::lookup_in_children]: forward function *)
  (betree_internal_lookup_in_children_fwd
     (self : betree_internal_t) (key : u64) (st : state) :
     (state # u64 option) result
     =
    if u64_lt key self.betree_internal_pivot
    then betree_node_lookup_fwd self.betree_internal_left key st
    else betree_node_lookup_fwd self.betree_internal_right key st)
  /\
  
  (** [betree_main::betree::Internal::{4}::lookup_in_children]: backward function 0 *)
  (betree_internal_lookup_in_children_back
     (self : betree_internal_t) (key : u64) (st : state) :
     betree_internal_t result
     =
    if u64_lt key self.betree_internal_pivot
    then (
      do
      n <- betree_node_lookup_back self.betree_internal_left key st;
      Return (self with <| betree_internal_left := n |>)
      od)
    else (
      do
      n <- betree_node_lookup_back self.betree_internal_right key st;
      Return (self with <| betree_internal_right := n |>)
      od))
  /\
  
  (** [betree_main::betree::Node::{5}::lookup]: forward function *)
  (betree_node_lookup_fwd
     (self : betree_node_t) (key : u64) (st : state) :
     (state # u64 option) result
     =
    (case self of
    | BetreeNodeInternal node =>
      do
      (st0, msgs) <- betree_load_internal_node_fwd node.betree_internal_id st;
      pending <- betree_node_lookup_first_message_for_key_fwd key msgs;
      (case pending of
      | BetreeListCons p l =>
        let (k, msg) = p in
        if k <> key
        then (
          do
          (st1, opt) <- betree_internal_lookup_in_children_fwd node key st0;
          _ <-
            betree_node_lookup_first_message_for_key_back key msgs
              (BetreeListCons (k, msg) l);
          Return (st1, opt)
          od)
        else
          (case msg of
          | BetreeMessageInsert v =>
            do
            _ <-
              betree_node_lookup_first_message_for_key_back key msgs
                (BetreeListCons (k, BetreeMessageInsert v) l);
            Return (st0, SOME v)
            od
          | BetreeMessageDelete =>
            do
            _ <-
              betree_node_lookup_first_message_for_key_back key msgs
                (BetreeListCons (k, BetreeMessageDelete) l);
            Return (st0, NONE)
            od
          | BetreeMessageUpsert ufs =>
            do
            (st1, v) <- betree_internal_lookup_in_children_fwd node key st0;
            (st2, v0) <-
              betree_node_apply_upserts_fwd (BetreeListCons (k,
                BetreeMessageUpsert ufs) l) v key st1;
            node0 <- betree_internal_lookup_in_children_back node key st0;
            pending0 <-
              betree_node_apply_upserts_back (BetreeListCons (k,
                BetreeMessageUpsert ufs) l) v key st1;
            msgs0 <-
              betree_node_lookup_first_message_for_key_back key msgs pending0;
            (st3, _) <-
              betree_store_internal_node_fwd node0.betree_internal_id msgs0 st2;
            Return (st3, SOME v0)
            od)
      | BetreeListNil =>
        do
        (st1, opt) <- betree_internal_lookup_in_children_fwd node key st0;
        _ <-
          betree_node_lookup_first_message_for_key_back key msgs BetreeListNil;
        Return (st1, opt)
        od)
      od
    | BetreeNodeLeaf node =>
      do
      (st0, bindings) <- betree_load_leaf_node_fwd node.betree_leaf_id st;
      opt <- betree_node_lookup_in_bindings_fwd key bindings;
      Return (st0, opt)
      od))
  /\
  
  (** [betree_main::betree::Node::{5}::lookup]: backward function 0 *)
  betree_node_lookup_back
    (self : betree_node_t) (key : u64) (st : state) : betree_node_t result =
    (case self of
    | BetreeNodeInternal node =>
      do
      (st0, msgs) <- betree_load_internal_node_fwd node.betree_internal_id st;
      pending <- betree_node_lookup_first_message_for_key_fwd key msgs;
      (case pending of
      | BetreeListCons p l =>
        let (k, msg) = p in
        if k <> key
        then (
          do
          _ <-
            betree_node_lookup_first_message_for_key_back key msgs
              (BetreeListCons (k, msg) l);
          node0 <- betree_internal_lookup_in_children_back node key st0;
          Return (BetreeNodeInternal node0)
          od)
        else
          (case msg of
          | BetreeMessageInsert v =>
            do
            _ <-
              betree_node_lookup_first_message_for_key_back key msgs
                (BetreeListCons (k, BetreeMessageInsert v) l);
            Return (BetreeNodeInternal node)
            od
          | BetreeMessageDelete =>
            do
            _ <-
              betree_node_lookup_first_message_for_key_back key msgs
                (BetreeListCons (k, BetreeMessageDelete) l);
            Return (BetreeNodeInternal node)
            od
          | BetreeMessageUpsert ufs =>
            do
            (st1, v) <- betree_internal_lookup_in_children_fwd node key st0;
            (st2, _) <-
              betree_node_apply_upserts_fwd (BetreeListCons (k,
                BetreeMessageUpsert ufs) l) v key st1;
            node0 <- betree_internal_lookup_in_children_back node key st0;
            pending0 <-
              betree_node_apply_upserts_back (BetreeListCons (k,
                BetreeMessageUpsert ufs) l) v key st1;
            msgs0 <-
              betree_node_lookup_first_message_for_key_back key msgs pending0;
            _ <-
              betree_store_internal_node_fwd node0.betree_internal_id msgs0 st2;
            Return (BetreeNodeInternal node0)
            od)
      | BetreeListNil =>
        do
        _ <-
          betree_node_lookup_first_message_for_key_back key msgs BetreeListNil;
        node0 <- betree_internal_lookup_in_children_back node key st0;
        Return (BetreeNodeInternal node0)
        od)
      od
    | BetreeNodeLeaf node =>
      do
      (_, bindings) <- betree_load_leaf_node_fwd node.betree_leaf_id st;
      _ <- betree_node_lookup_in_bindings_fwd key bindings;
      Return (BetreeNodeLeaf node)
      od)
’

val [betree_node_filter_messages_for_key_fwd_back_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::filter_messages_for_key]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  betree_node_filter_messages_for_key_fwd_back
    (key : u64) (msgs : (u64 # betree_message_t) betree_list_t) :
    (u64 # betree_message_t) betree_list_t result
    =
    (case msgs of
    | BetreeListCons p l =>
      let (k, m) = p in
      if k = key
      then (
        do
        msgs0 <- betree_list_pop_front_back (BetreeListCons (k, m) l);
        betree_node_filter_messages_for_key_fwd_back key msgs0
        od)
      else Return (BetreeListCons (k, m) l)
    | BetreeListNil => Return BetreeListNil)
’

val [betree_node_lookup_first_message_after_key_fwd_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::lookup_first_message_after_key]: forward function *)
  betree_node_lookup_first_message_after_key_fwd
    (key : u64) (msgs : (u64 # betree_message_t) betree_list_t) :
    (u64 # betree_message_t) betree_list_t result
    =
    (case msgs of
    | BetreeListCons p next_msgs =>
      let (k, m) = p in
      if k = key
      then betree_node_lookup_first_message_after_key_fwd key next_msgs
      else Return (BetreeListCons (k, m) next_msgs)
    | BetreeListNil => Return BetreeListNil)
’

val [betree_node_lookup_first_message_after_key_back_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::lookup_first_message_after_key]: backward function 0 *)
  betree_node_lookup_first_message_after_key_back
    (key : u64) (msgs : (u64 # betree_message_t) betree_list_t)
    (ret : (u64 # betree_message_t) betree_list_t) :
    (u64 # betree_message_t) betree_list_t result
    =
    (case msgs of
    | BetreeListCons p next_msgs =>
      let (k, m) = p in
      if k = key
      then (
        do
        next_msgs0 <-
          betree_node_lookup_first_message_after_key_back key next_msgs ret;
        Return (BetreeListCons (k, m) next_msgs0)
        od)
      else Return ret
    | BetreeListNil => Return ret)
’

val betree_node_apply_to_internal_fwd_back_def = Define ‘
  (** [betree_main::betree::Node::{5}::apply_to_internal]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  betree_node_apply_to_internal_fwd_back
    (msgs : (u64 # betree_message_t) betree_list_t) (key : u64)
    (new_msg : betree_message_t) :
    (u64 # betree_message_t) betree_list_t result
    =
    do
    msgs0 <- betree_node_lookup_first_message_for_key_fwd key msgs;
    b <- betree_list_head_has_key_fwd msgs0 key;
    if b
    then
      (case new_msg of
      | BetreeMessageInsert i =>
        do
        msgs1 <- betree_node_filter_messages_for_key_fwd_back key msgs0;
        msgs2 <-
          betree_list_push_front_fwd_back msgs1 (key, BetreeMessageInsert i);
        betree_node_lookup_first_message_for_key_back key msgs msgs2
        od
      | BetreeMessageDelete =>
        do
        msgs1 <- betree_node_filter_messages_for_key_fwd_back key msgs0;
        msgs2 <-
          betree_list_push_front_fwd_back msgs1 (key, BetreeMessageDelete);
        betree_node_lookup_first_message_for_key_back key msgs msgs2
        od
      | BetreeMessageUpsert s =>
        do
        p <- betree_list_hd_fwd msgs0;
        let (_, m) = p in
        (case m of
        | BetreeMessageInsert prev =>
          do
          v <- betree_upsert_update_fwd (SOME prev) s;
          msgs1 <- betree_list_pop_front_back msgs0;
          msgs2 <-
            betree_list_push_front_fwd_back msgs1 (key, BetreeMessageInsert v);
          betree_node_lookup_first_message_for_key_back key msgs msgs2
          od
        | BetreeMessageDelete =>
          do
          v <- betree_upsert_update_fwd NONE s;
          msgs1 <- betree_list_pop_front_back msgs0;
          msgs2 <-
            betree_list_push_front_fwd_back msgs1 (key, BetreeMessageInsert v);
          betree_node_lookup_first_message_for_key_back key msgs msgs2
          od
        | BetreeMessageUpsert ufs =>
          do
          msgs1 <- betree_node_lookup_first_message_after_key_fwd key msgs0;
          msgs2 <-
            betree_list_push_front_fwd_back msgs1 (key, BetreeMessageUpsert s);
          msgs3 <-
            betree_node_lookup_first_message_after_key_back key msgs0 msgs2;
          betree_node_lookup_first_message_for_key_back key msgs msgs3
          od)
        od)
    else (
      do
      msgs1 <- betree_list_push_front_fwd_back msgs0 (key, new_msg);
      betree_node_lookup_first_message_for_key_back key msgs msgs1
      od)
    od
’

val [betree_node_apply_messages_to_internal_fwd_back_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::apply_messages_to_internal]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  betree_node_apply_messages_to_internal_fwd_back
    (msgs : (u64 # betree_message_t) betree_list_t)
    (new_msgs : (u64 # betree_message_t) betree_list_t) :
    (u64 # betree_message_t) betree_list_t result
    =
    (case new_msgs of
    | BetreeListCons new_msg new_msgs_tl =>
      let (i, m) = new_msg in
      do
      msgs0 <- betree_node_apply_to_internal_fwd_back msgs i m;
      betree_node_apply_messages_to_internal_fwd_back msgs0 new_msgs_tl
      od
    | BetreeListNil => Return msgs)
’

val [betree_node_lookup_mut_in_bindings_fwd_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::lookup_mut_in_bindings]: forward function *)
  betree_node_lookup_mut_in_bindings_fwd
    (key : u64) (bindings : (u64 # u64) betree_list_t) :
    (u64 # u64) betree_list_t result
    =
    (case bindings of
    | BetreeListCons hd tl =>
      let (i, i0) = hd in
      if u64_ge i key
      then Return (BetreeListCons (i, i0) tl)
      else betree_node_lookup_mut_in_bindings_fwd key tl
    | BetreeListNil => Return BetreeListNil)
’

val [betree_node_lookup_mut_in_bindings_back_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::lookup_mut_in_bindings]: backward function 0 *)
  betree_node_lookup_mut_in_bindings_back
    (key : u64) (bindings : (u64 # u64) betree_list_t)
    (ret : (u64 # u64) betree_list_t) :
    (u64 # u64) betree_list_t result
    =
    (case bindings of
    | BetreeListCons hd tl =>
      let (i, i0) = hd in
      if u64_ge i key
      then Return ret
      else (
        do
        tl0 <- betree_node_lookup_mut_in_bindings_back key tl ret;
        Return (BetreeListCons (i, i0) tl0)
        od)
    | BetreeListNil => Return ret)
’

val betree_node_apply_to_leaf_fwd_back_def = Define ‘
  (** [betree_main::betree::Node::{5}::apply_to_leaf]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  betree_node_apply_to_leaf_fwd_back
    (bindings : (u64 # u64) betree_list_t) (key : u64)
    (new_msg : betree_message_t) :
    (u64 # u64) betree_list_t result
    =
    do
    bindings0 <- betree_node_lookup_mut_in_bindings_fwd key bindings;
    b <- betree_list_head_has_key_fwd bindings0 key;
    if b
    then (
      do
      hd <- betree_list_pop_front_fwd bindings0;
      (case new_msg of
      | BetreeMessageInsert v =>
        do
        bindings1 <- betree_list_pop_front_back bindings0;
        bindings2 <- betree_list_push_front_fwd_back bindings1 (key, v);
        betree_node_lookup_mut_in_bindings_back key bindings bindings2
        od
      | BetreeMessageDelete =>
        do
        bindings1 <- betree_list_pop_front_back bindings0;
        betree_node_lookup_mut_in_bindings_back key bindings bindings1
        od
      | BetreeMessageUpsert s =>
        let (_, i) = hd in
        do
        v <- betree_upsert_update_fwd (SOME i) s;
        bindings1 <- betree_list_pop_front_back bindings0;
        bindings2 <- betree_list_push_front_fwd_back bindings1 (key, v);
        betree_node_lookup_mut_in_bindings_back key bindings bindings2
        od)
      od)
    else
      (case new_msg of
      | BetreeMessageInsert v =>
        do
        bindings1 <- betree_list_push_front_fwd_back bindings0 (key, v);
        betree_node_lookup_mut_in_bindings_back key bindings bindings1
        od
      | BetreeMessageDelete =>
        betree_node_lookup_mut_in_bindings_back key bindings bindings0
      | BetreeMessageUpsert s =>
        do
        v <- betree_upsert_update_fwd NONE s;
        bindings1 <- betree_list_push_front_fwd_back bindings0 (key, v);
        betree_node_lookup_mut_in_bindings_back key bindings bindings1
        od)
    od
’

val [betree_node_apply_messages_to_leaf_fwd_back_def] = DefineDiv ‘
  (** [betree_main::betree::Node::{5}::apply_messages_to_leaf]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  betree_node_apply_messages_to_leaf_fwd_back
    (bindings : (u64 # u64) betree_list_t)
    (new_msgs : (u64 # betree_message_t) betree_list_t) :
    (u64 # u64) betree_list_t result
    =
    (case new_msgs of
    | BetreeListCons new_msg new_msgs_tl =>
      let (i, m) = new_msg in
      do
      bindings0 <- betree_node_apply_to_leaf_fwd_back bindings i m;
      betree_node_apply_messages_to_leaf_fwd_back bindings0 new_msgs_tl
      od
    | BetreeListNil => Return bindings)
’

val [betree_internal_flush_fwd_def, betree_internal_flush_back_def, betree_node_apply_messages_fwd_def, betree_node_apply_messages_back_def] = DefineDiv ‘
  (** [betree_main::betree::Internal::{4}::flush]: forward function *)
  (betree_internal_flush_fwd
     (self : betree_internal_t) (params : betree_params_t)
     (node_id_cnt : betree_node_id_counter_t)
     (content : (u64 # betree_message_t) betree_list_t) (st : state) :
     (state # (u64 # betree_message_t) betree_list_t) result
     =
    do
    p <- betree_list_partition_at_pivot_fwd content self.betree_internal_pivot;
    let (msgs_left, msgs_right) = p in
    do
    len_left <- betree_list_len_fwd msgs_left;
    if u64_ge len_left params.betree_params_min_flush_size
    then (
      do
      (st0, _) <-
        betree_node_apply_messages_fwd self.betree_internal_left params
          node_id_cnt msgs_left st;
      (_, node_id_cnt0) <-
        betree_node_apply_messages_back self.betree_internal_left params
          node_id_cnt msgs_left st;
      len_right <- betree_list_len_fwd msgs_right;
      if u64_ge len_right params.betree_params_min_flush_size
      then (
        do
        (st1, _) <-
          betree_node_apply_messages_fwd self.betree_internal_right params
            node_id_cnt0 msgs_right st0;
        _ <-
          betree_node_apply_messages_back self.betree_internal_right params
            node_id_cnt0 msgs_right st0;
        Return (st1, BetreeListNil)
        od)
      else Return (st0, msgs_right)
      od)
    else (
      do
      (st0, _) <-
        betree_node_apply_messages_fwd self.betree_internal_right params
          node_id_cnt msgs_right st;
      _ <-
        betree_node_apply_messages_back self.betree_internal_right params
          node_id_cnt msgs_right st;
      Return (st0, msgs_left)
      od)
    od
    od)
  /\
  
  (** [betree_main::betree::Internal::{4}::flush]: backward function 0 *)
  (betree_internal_flush_back
     (self : betree_internal_t) (params : betree_params_t)
     (node_id_cnt : betree_node_id_counter_t)
     (content : (u64 # betree_message_t) betree_list_t) (st : state) :
     (betree_internal_t # betree_node_id_counter_t) result
     =
    do
    p <- betree_list_partition_at_pivot_fwd content self.betree_internal_pivot;
    let (msgs_left, msgs_right) = p in
    do
    len_left <- betree_list_len_fwd msgs_left;
    if u64_ge len_left params.betree_params_min_flush_size
    then (
      do
      (st0, _) <-
        betree_node_apply_messages_fwd self.betree_internal_left params
          node_id_cnt msgs_left st;
      (n, node_id_cnt0) <-
        betree_node_apply_messages_back self.betree_internal_left params
          node_id_cnt msgs_left st;
      len_right <- betree_list_len_fwd msgs_right;
      if u64_ge len_right params.betree_params_min_flush_size
      then (
        do
        (n0, node_id_cnt1) <-
          betree_node_apply_messages_back self.betree_internal_right params
            node_id_cnt0 msgs_right st0;
        Return
          (self
             with
             <|
             betree_internal_left := n; betree_internal_right := n0
             |>, node_id_cnt1)
        od)
      else Return (self with <| betree_internal_left := n |>, node_id_cnt0)
      od)
    else (
      do
      (n, node_id_cnt0) <-
        betree_node_apply_messages_back self.betree_internal_right params
          node_id_cnt msgs_right st;
      Return (self with <| betree_internal_right := n |>, node_id_cnt0)
      od)
    od
    od)
  /\
  
  (** [betree_main::betree::Node::{5}::apply_messages]: forward function *)
  (betree_node_apply_messages_fwd
     (self : betree_node_t) (params : betree_params_t)
     (node_id_cnt : betree_node_id_counter_t)
     (msgs : (u64 # betree_message_t) betree_list_t) (st : state) :
     (state # unit) result
     =
    (case self of
    | BetreeNodeInternal node =>
      do
      (st0, content) <-
        betree_load_internal_node_fwd node.betree_internal_id st;
      content0 <- betree_node_apply_messages_to_internal_fwd_back content msgs;
      num_msgs <- betree_list_len_fwd content0;
      if u64_ge num_msgs params.betree_params_min_flush_size
      then (
        do
        (st1, content1) <-
          betree_internal_flush_fwd node params node_id_cnt content0 st0;
        (node0, _) <-
          betree_internal_flush_back node params node_id_cnt content0 st0;
        (st2, _) <-
          betree_store_internal_node_fwd node0.betree_internal_id content1 st1;
        Return (st2, ())
        od)
      else (
        do
        (st1, _) <-
          betree_store_internal_node_fwd node.betree_internal_id content0 st0;
        Return (st1, ())
        od)
      od
    | BetreeNodeLeaf node =>
      do
      (st0, content) <- betree_load_leaf_node_fwd node.betree_leaf_id st;
      content0 <- betree_node_apply_messages_to_leaf_fwd_back content msgs;
      len <- betree_list_len_fwd content0;
      i <- u64_mul (int_to_u64 2) params.betree_params_split_size;
      if u64_ge len i
      then (
        do
        (st1, _) <- betree_leaf_split_fwd node content0 params node_id_cnt st0;
        (st2, _) <-
          betree_store_leaf_node_fwd node.betree_leaf_id BetreeListNil st1;
        Return (st2, ())
        od)
      else (
        do
        (st1, _) <-
          betree_store_leaf_node_fwd node.betree_leaf_id content0 st0;
        Return (st1, ())
        od)
      od))
  /\
  
  (** [betree_main::betree::Node::{5}::apply_messages]: backward function 0 *)
  betree_node_apply_messages_back
    (self : betree_node_t) (params : betree_params_t)
    (node_id_cnt : betree_node_id_counter_t)
    (msgs : (u64 # betree_message_t) betree_list_t) (st : state) :
    (betree_node_t # betree_node_id_counter_t) result
    =
    (case self of
    | BetreeNodeInternal node =>
      do
      (st0, content) <-
        betree_load_internal_node_fwd node.betree_internal_id st;
      content0 <- betree_node_apply_messages_to_internal_fwd_back content msgs;
      num_msgs <- betree_list_len_fwd content0;
      if u64_ge num_msgs params.betree_params_min_flush_size
      then (
        do
        (st1, content1) <-
          betree_internal_flush_fwd node params node_id_cnt content0 st0;
        (node0, node_id_cnt0) <-
          betree_internal_flush_back node params node_id_cnt content0 st0;
        _ <-
          betree_store_internal_node_fwd node0.betree_internal_id content1 st1;
        Return (BetreeNodeInternal node0, node_id_cnt0)
        od)
      else (
        do
        _ <-
          betree_store_internal_node_fwd node.betree_internal_id content0 st0;
        Return (BetreeNodeInternal node, node_id_cnt)
        od)
      od
    | BetreeNodeLeaf node =>
      do
      (st0, content) <- betree_load_leaf_node_fwd node.betree_leaf_id st;
      content0 <- betree_node_apply_messages_to_leaf_fwd_back content msgs;
      len <- betree_list_len_fwd content0;
      i <- u64_mul (int_to_u64 2) params.betree_params_split_size;
      if u64_ge len i
      then (
        do
        (st1, new_node) <-
          betree_leaf_split_fwd node content0 params node_id_cnt st0;
        _ <- betree_store_leaf_node_fwd node.betree_leaf_id BetreeListNil st1;
        node_id_cnt0 <-
          betree_leaf_split_back node content0 params node_id_cnt st0;
        Return (BetreeNodeInternal new_node, node_id_cnt0)
        od)
      else (
        do
        _ <- betree_store_leaf_node_fwd node.betree_leaf_id content0 st0;
        Return (BetreeNodeLeaf (node with <| betree_leaf_size := len |>),
          node_id_cnt)
        od)
      od)
’

val betree_node_apply_fwd_def = Define ‘
  (** [betree_main::betree::Node::{5}::apply]: forward function *)
  betree_node_apply_fwd
    (self : betree_node_t) (params : betree_params_t)
    (node_id_cnt : betree_node_id_counter_t) (key : u64)
    (new_msg : betree_message_t) (st : state) :
    (state # unit) result
    =
    let l = BetreeListNil in
    do
    (st0, _) <-
      betree_node_apply_messages_fwd self params node_id_cnt (BetreeListCons
        (key, new_msg) l) st;
    _ <-
      betree_node_apply_messages_back self params node_id_cnt (BetreeListCons
        (key, new_msg) l) st;
    Return (st0, ())
    od
’

val betree_node_apply_back_def = Define ‘
  (** [betree_main::betree::Node::{5}::apply]: backward function 0 *)
  betree_node_apply_back
    (self : betree_node_t) (params : betree_params_t)
    (node_id_cnt : betree_node_id_counter_t) (key : u64)
    (new_msg : betree_message_t) (st : state) :
    (betree_node_t # betree_node_id_counter_t) result
    =
    let l = BetreeListNil in
    betree_node_apply_messages_back self params node_id_cnt (BetreeListCons
      (key, new_msg) l) st
’

val betree_be_tree_new_fwd_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::new]: forward function *)
  betree_be_tree_new_fwd
    (min_flush_size : u64) (split_size : u64) (st : state) :
    (state # betree_be_tree_t) result
    =
    do
    node_id_cnt <- betree_node_id_counter_new_fwd;
    id <- betree_node_id_counter_fresh_id_fwd node_id_cnt;
    (st0, _) <- betree_store_leaf_node_fwd id BetreeListNil st;
    node_id_cnt0 <- betree_node_id_counter_fresh_id_back node_id_cnt;
    Return (st0,
      <|
        betree_be_tree_params :=
          (<|
             betree_params_min_flush_size := min_flush_size;
             betree_params_split_size := split_size
             |>);
        betree_be_tree_node_id_cnt := node_id_cnt0;
        betree_be_tree_root :=
          (BetreeNodeLeaf
            (<| betree_leaf_id := id; betree_leaf_size := (int_to_u64 0) |>))
        |>)
    od
’

val betree_be_tree_apply_fwd_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::apply]: forward function *)
  betree_be_tree_apply_fwd
    (self : betree_be_tree_t) (key : u64) (msg : betree_message_t) (st : state)
    :
    (state # unit) result
    =
    do
    (st0, _) <-
      betree_node_apply_fwd self.betree_be_tree_root self.betree_be_tree_params
        self.betree_be_tree_node_id_cnt key msg st;
    _ <-
      betree_node_apply_back self.betree_be_tree_root
        self.betree_be_tree_params self.betree_be_tree_node_id_cnt key msg st;
    Return (st0, ())
    od
’

val betree_be_tree_apply_back_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::apply]: backward function 0 *)
  betree_be_tree_apply_back
    (self : betree_be_tree_t) (key : u64) (msg : betree_message_t) (st : state)
    :
    betree_be_tree_t result
    =
    do
    (n, nic) <-
      betree_node_apply_back self.betree_be_tree_root
        self.betree_be_tree_params self.betree_be_tree_node_id_cnt key msg st;
    Return
      (self
         with
         <|
         betree_be_tree_node_id_cnt := nic; betree_be_tree_root := n
         |>)
    od
’

val betree_be_tree_insert_fwd_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::insert]: forward function *)
  betree_be_tree_insert_fwd
    (self : betree_be_tree_t) (key : u64) (value : u64) (st : state) :
    (state # unit) result
    =
    do
    (st0, _) <-
      betree_be_tree_apply_fwd self key (BetreeMessageInsert value) st;
    _ <- betree_be_tree_apply_back self key (BetreeMessageInsert value) st;
    Return (st0, ())
    od
’

val betree_be_tree_insert_back_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::insert]: backward function 0 *)
  betree_be_tree_insert_back
    (self : betree_be_tree_t) (key : u64) (value : u64) (st : state) :
    betree_be_tree_t result
    =
    betree_be_tree_apply_back self key (BetreeMessageInsert value) st
’

val betree_be_tree_delete_fwd_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::delete]: forward function *)
  betree_be_tree_delete_fwd
    (self : betree_be_tree_t) (key : u64) (st : state) :
    (state # unit) result
    =
    do
    (st0, _) <- betree_be_tree_apply_fwd self key BetreeMessageDelete st;
    _ <- betree_be_tree_apply_back self key BetreeMessageDelete st;
    Return (st0, ())
    od
’

val betree_be_tree_delete_back_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::delete]: backward function 0 *)
  betree_be_tree_delete_back
    (self : betree_be_tree_t) (key : u64) (st : state) :
    betree_be_tree_t result
    =
    betree_be_tree_apply_back self key BetreeMessageDelete st
’

val betree_be_tree_upsert_fwd_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::upsert]: forward function *)
  betree_be_tree_upsert_fwd
    (self : betree_be_tree_t) (key : u64) (upd : betree_upsert_fun_state_t)
    (st : state) :
    (state # unit) result
    =
    do
    (st0, _) <- betree_be_tree_apply_fwd self key (BetreeMessageUpsert upd) st;
    _ <- betree_be_tree_apply_back self key (BetreeMessageUpsert upd) st;
    Return (st0, ())
    od
’

val betree_be_tree_upsert_back_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::upsert]: backward function 0 *)
  betree_be_tree_upsert_back
    (self : betree_be_tree_t) (key : u64) (upd : betree_upsert_fun_state_t)
    (st : state) :
    betree_be_tree_t result
    =
    betree_be_tree_apply_back self key (BetreeMessageUpsert upd) st
’

val betree_be_tree_lookup_fwd_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::lookup]: forward function *)
  betree_be_tree_lookup_fwd
    (self : betree_be_tree_t) (key : u64) (st : state) :
    (state # u64 option) result
    =
    betree_node_lookup_fwd self.betree_be_tree_root key st
’

val betree_be_tree_lookup_back_def = Define ‘
  (** [betree_main::betree::BeTree::{6}::lookup]: backward function 0 *)
  betree_be_tree_lookup_back
    (self : betree_be_tree_t) (key : u64) (st : state) :
    betree_be_tree_t result
    =
    do
    n <- betree_node_lookup_back self.betree_be_tree_root key st;
    Return (self with <| betree_be_tree_root := n |>)
    od
’

val main_fwd_def = Define ‘
  (** [betree_main::main]: forward function *)
  main_fwd : unit result =
    Return ()
’

(** Unit test for [betree_main::main] *)
val _ = assert_return (“main_fwd”)

val _ = export_theory ()
