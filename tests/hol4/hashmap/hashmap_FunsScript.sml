(** [hashmap]: function definitions *)
open primitivesLib divDefLib
open hashmap_TypesTheory

val _ = new_theory "hashmap_Funs"


val hash_key_fwd_def = Define ‘
  (** [hashmap::hash_key]: forward function *)
  hash_key_fwd (k : usize) : usize result =
    Return k
’

val [hash_map_allocate_slots_loop_fwd_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::allocate_slots]: loop 0: forward function *)
  hash_map_allocate_slots_loop_fwd
    (slots : 't list_t vec) (n : usize) : 't list_t vec result =
    if usize_gt n (int_to_usize 0)
    then (
      do
      slots0 <- vec_push_back slots ListNil;
      n0 <- usize_sub n (int_to_usize 1);
      hash_map_allocate_slots_loop_fwd slots0 n0
      od)
    else Return slots
’

val hash_map_allocate_slots_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::allocate_slots]: forward function *)
  hash_map_allocate_slots_fwd
    (slots : 't list_t vec) (n : usize) : 't list_t vec result =
    hash_map_allocate_slots_loop_fwd slots n
’

val hash_map_new_with_capacity_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::new_with_capacity]: forward function *)
  hash_map_new_with_capacity_fwd
    (capacity : usize) (max_load_dividend : usize) (max_load_divisor : usize) :
    't hash_map_t result
    =
    let v = vec_new in
    do
    slots <- hash_map_allocate_slots_fwd v capacity;
    i <- usize_mul capacity max_load_dividend;
    i0 <- usize_div i max_load_divisor;
    Return
      (<|
         hash_map_num_entries := (int_to_usize 0);
         hash_map_max_load_factor := (max_load_dividend, max_load_divisor);
         hash_map_max_load := i0;
         hash_map_slots := slots
         |>)
    od
’

val hash_map_new_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::new]: forward function *)
  hash_map_new_fwd : 't hash_map_t result =
    hash_map_new_with_capacity_fwd (int_to_usize 32) (int_to_usize 4)
      (int_to_usize 5)
’

val [hash_map_clear_loop_fwd_back_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::clear]: loop 0: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  hash_map_clear_loop_fwd_back
    (slots : 't list_t vec) (i : usize) : 't list_t vec result =
    let i0 = vec_len slots in
    if usize_lt i i0
    then (
      do
      i1 <- usize_add i (int_to_usize 1);
      slots0 <- vec_index_mut_back slots i ListNil;
      hash_map_clear_loop_fwd_back slots0 i1
      od)
    else Return slots
’

val hash_map_clear_fwd_back_def = Define ‘
  (** [hashmap::HashMap::{0}::clear]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  hash_map_clear_fwd_back (self : 't hash_map_t) : 't hash_map_t result =
    do
    v <- hash_map_clear_loop_fwd_back self.hash_map_slots (int_to_usize 0);
    Return
      (self
         with
         <|
         hash_map_num_entries := (int_to_usize 0); hash_map_slots := v
         |>)
    od
’

val hash_map_len_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::len]: forward function *)
  hash_map_len_fwd (self : 't hash_map_t) : usize result =
    Return self.hash_map_num_entries
’

val [hash_map_insert_in_list_loop_fwd_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::insert_in_list]: loop 0: forward function *)
  hash_map_insert_in_list_loop_fwd
    (key : usize) (value : 't) (ls : 't list_t) : bool result =
    (case ls of
    | ListCons ckey cvalue tl =>
      if ckey = key
      then Return F
      else hash_map_insert_in_list_loop_fwd key value tl
    | ListNil => Return T)
’

val hash_map_insert_in_list_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::insert_in_list]: forward function *)
  hash_map_insert_in_list_fwd
    (key : usize) (value : 't) (ls : 't list_t) : bool result =
    hash_map_insert_in_list_loop_fwd key value ls
’

val [hash_map_insert_in_list_loop_back_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::insert_in_list]: loop 0: backward function 0 *)
  hash_map_insert_in_list_loop_back
    (key : usize) (value : 't) (ls : 't list_t) : 't list_t result =
    (case ls of
    | ListCons ckey cvalue tl =>
      if ckey = key
      then Return (ListCons ckey value tl)
      else (
        do
        tl0 <- hash_map_insert_in_list_loop_back key value tl;
        Return (ListCons ckey cvalue tl0)
        od)
    | ListNil => let l = ListNil in Return (ListCons key value l))
’

val hash_map_insert_in_list_back_def = Define ‘
  (** [hashmap::HashMap::{0}::insert_in_list]: backward function 0 *)
  hash_map_insert_in_list_back
    (key : usize) (value : 't) (ls : 't list_t) : 't list_t result =
    hash_map_insert_in_list_loop_back key value ls
’

val hash_map_insert_no_resize_fwd_back_def = Define ‘
  (** [hashmap::HashMap::{0}::insert_no_resize]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  hash_map_insert_no_resize_fwd_back
    (self : 't hash_map_t) (key : usize) (value : 't) : 't hash_map_t result =
    do
    hash <- hash_key_fwd key;
    let i = vec_len self.hash_map_slots in
    do
    hash_mod <- usize_rem hash i;
    l <- vec_index_mut_fwd self.hash_map_slots hash_mod;
    inserted <- hash_map_insert_in_list_fwd key value l;
    if inserted
    then (
      do
      i0 <- usize_add self.hash_map_num_entries (int_to_usize 1);
      l0 <- hash_map_insert_in_list_back key value l;
      v <- vec_index_mut_back self.hash_map_slots hash_mod l0;
      Return (self with <| hash_map_num_entries := i0; hash_map_slots := v |>)
      od)
    else (
      do
      l0 <- hash_map_insert_in_list_back key value l;
      v <- vec_index_mut_back self.hash_map_slots hash_mod l0;
      Return (self with <| hash_map_slots := v |>)
      od)
    od
    od
’

val [hash_map_move_elements_from_list_loop_fwd_back_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::move_elements_from_list]: loop 0: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  hash_map_move_elements_from_list_loop_fwd_back
    (ntable : 't hash_map_t) (ls : 't list_t) : 't hash_map_t result =
    (case ls of
    | ListCons k v tl =>
      do
      ntable0 <- hash_map_insert_no_resize_fwd_back ntable k v;
      hash_map_move_elements_from_list_loop_fwd_back ntable0 tl
      od
    | ListNil => Return ntable)
’

val hash_map_move_elements_from_list_fwd_back_def = Define ‘
  (** [hashmap::HashMap::{0}::move_elements_from_list]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  hash_map_move_elements_from_list_fwd_back
    (ntable : 't hash_map_t) (ls : 't list_t) : 't hash_map_t result =
    hash_map_move_elements_from_list_loop_fwd_back ntable ls
’

val [hash_map_move_elements_loop_fwd_back_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::move_elements]: loop 0: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  hash_map_move_elements_loop_fwd_back
    (ntable : 't hash_map_t) (slots : 't list_t vec) (i : usize) :
    ('t hash_map_t # 't list_t vec) result
    =
    let i0 = vec_len slots in
    if usize_lt i i0
    then (
      do
      l <- vec_index_mut_fwd slots i;
      let ls = mem_replace_fwd l ListNil in
      do
      ntable0 <- hash_map_move_elements_from_list_fwd_back ntable ls;
      i1 <- usize_add i (int_to_usize 1);
      let l0 = mem_replace_back l ListNil in
      do
      slots0 <- vec_index_mut_back slots i l0;
      hash_map_move_elements_loop_fwd_back ntable0 slots0 i1
      od
      od
      od)
    else Return (ntable, slots)
’

val hash_map_move_elements_fwd_back_def = Define ‘
  (** [hashmap::HashMap::{0}::move_elements]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  hash_map_move_elements_fwd_back
    (ntable : 't hash_map_t) (slots : 't list_t vec) (i : usize) :
    ('t hash_map_t # 't list_t vec) result
    =
    hash_map_move_elements_loop_fwd_back ntable slots i
’

val hash_map_try_resize_fwd_back_def = Define ‘
  (** [hashmap::HashMap::{0}::try_resize]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  hash_map_try_resize_fwd_back (self : 't hash_map_t) : 't hash_map_t result =
    do
    max_usize <- mk_usize (u32_to_int core_u32_max);
    let capacity = vec_len self.hash_map_slots in
    do
    n1 <- usize_div max_usize (int_to_usize 2);
    let (i, i0) = self.hash_map_max_load_factor in
    do
    i1 <- usize_div n1 i;
    if usize_le capacity i1
    then (
      do
      i2 <- usize_mul capacity (int_to_usize 2);
      ntable <- hash_map_new_with_capacity_fwd i2 i i0;
      (ntable0, _) <-
        hash_map_move_elements_fwd_back ntable self.hash_map_slots
          (int_to_usize 0);
      Return
        (ntable0
           with
           <|
           hash_map_num_entries := self.hash_map_num_entries;
           hash_map_max_load_factor := (i, i0)
           |>)
      od)
    else Return (self with <| hash_map_max_load_factor := (i, i0) |>)
    od
    od
    od
’

val hash_map_insert_fwd_back_def = Define ‘
  (** [hashmap::HashMap::{0}::insert]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  hash_map_insert_fwd_back
    (self : 't hash_map_t) (key : usize) (value : 't) : 't hash_map_t result =
    do
    self0 <- hash_map_insert_no_resize_fwd_back self key value;
    i <- hash_map_len_fwd self0;
    if usize_gt i self0.hash_map_max_load
    then hash_map_try_resize_fwd_back self0
    else Return self0
    od
’

val [hash_map_contains_key_in_list_loop_fwd_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::contains_key_in_list]: loop 0: forward function *)
  hash_map_contains_key_in_list_loop_fwd
    (key : usize) (ls : 't list_t) : bool result =
    (case ls of
    | ListCons ckey t tl =>
      if ckey = key
      then Return T
      else hash_map_contains_key_in_list_loop_fwd key tl
    | ListNil => Return F)
’

val hash_map_contains_key_in_list_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::contains_key_in_list]: forward function *)
  hash_map_contains_key_in_list_fwd
    (key : usize) (ls : 't list_t) : bool result =
    hash_map_contains_key_in_list_loop_fwd key ls
’

val hash_map_contains_key_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::contains_key]: forward function *)
  hash_map_contains_key_fwd
    (self : 't hash_map_t) (key : usize) : bool result =
    do
    hash <- hash_key_fwd key;
    let i = vec_len self.hash_map_slots in
    do
    hash_mod <- usize_rem hash i;
    l <- vec_index_fwd self.hash_map_slots hash_mod;
    hash_map_contains_key_in_list_fwd key l
    od
    od
’

val [hash_map_get_in_list_loop_fwd_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::get_in_list]: loop 0: forward function *)
  hash_map_get_in_list_loop_fwd (key : usize) (ls : 't list_t) : 't result =
    (case ls of
    | ListCons ckey cvalue tl =>
      if ckey = key
      then Return cvalue
      else hash_map_get_in_list_loop_fwd key tl
    | ListNil => Fail Failure)
’

val hash_map_get_in_list_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::get_in_list]: forward function *)
  hash_map_get_in_list_fwd (key : usize) (ls : 't list_t) : 't result =
    hash_map_get_in_list_loop_fwd key ls
’

val hash_map_get_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::get]: forward function *)
  hash_map_get_fwd (self : 't hash_map_t) (key : usize) : 't result =
    do
    hash <- hash_key_fwd key;
    let i = vec_len self.hash_map_slots in
    do
    hash_mod <- usize_rem hash i;
    l <- vec_index_fwd self.hash_map_slots hash_mod;
    hash_map_get_in_list_fwd key l
    od
    od
’

val [hash_map_get_mut_in_list_loop_fwd_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::get_mut_in_list]: loop 0: forward function *)
  hash_map_get_mut_in_list_loop_fwd
    (ls : 't list_t) (key : usize) : 't result =
    (case ls of
    | ListCons ckey cvalue tl =>
      if ckey = key
      then Return cvalue
      else hash_map_get_mut_in_list_loop_fwd tl key
    | ListNil => Fail Failure)
’

val hash_map_get_mut_in_list_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::get_mut_in_list]: forward function *)
  hash_map_get_mut_in_list_fwd (ls : 't list_t) (key : usize) : 't result =
    hash_map_get_mut_in_list_loop_fwd ls key
’

val [hash_map_get_mut_in_list_loop_back_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::get_mut_in_list]: loop 0: backward function 0 *)
  hash_map_get_mut_in_list_loop_back
    (ls : 't list_t) (key : usize) (ret : 't) : 't list_t result =
    (case ls of
    | ListCons ckey cvalue tl =>
      if ckey = key
      then Return (ListCons ckey ret tl)
      else (
        do
        tl0 <- hash_map_get_mut_in_list_loop_back tl key ret;
        Return (ListCons ckey cvalue tl0)
        od)
    | ListNil => Fail Failure)
’

val hash_map_get_mut_in_list_back_def = Define ‘
  (** [hashmap::HashMap::{0}::get_mut_in_list]: backward function 0 *)
  hash_map_get_mut_in_list_back
    (ls : 't list_t) (key : usize) (ret : 't) : 't list_t result =
    hash_map_get_mut_in_list_loop_back ls key ret
’

val hash_map_get_mut_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::get_mut]: forward function *)
  hash_map_get_mut_fwd (self : 't hash_map_t) (key : usize) : 't result =
    do
    hash <- hash_key_fwd key;
    let i = vec_len self.hash_map_slots in
    do
    hash_mod <- usize_rem hash i;
    l <- vec_index_mut_fwd self.hash_map_slots hash_mod;
    hash_map_get_mut_in_list_fwd l key
    od
    od
’

val hash_map_get_mut_back_def = Define ‘
  (** [hashmap::HashMap::{0}::get_mut]: backward function 0 *)
  hash_map_get_mut_back
    (self : 't hash_map_t) (key : usize) (ret : 't) : 't hash_map_t result =
    do
    hash <- hash_key_fwd key;
    let i = vec_len self.hash_map_slots in
    do
    hash_mod <- usize_rem hash i;
    l <- vec_index_mut_fwd self.hash_map_slots hash_mod;
    l0 <- hash_map_get_mut_in_list_back l key ret;
    v <- vec_index_mut_back self.hash_map_slots hash_mod l0;
    Return (self with <| hash_map_slots := v |>)
    od
    od
’

val [hash_map_remove_from_list_loop_fwd_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::remove_from_list]: loop 0: forward function *)
  hash_map_remove_from_list_loop_fwd
    (key : usize) (ls : 't list_t) : 't option result =
    (case ls of
    | ListCons ckey t tl =>
      if ckey = key
      then
        let mv_ls = mem_replace_fwd (ListCons ckey t tl) ListNil in
        (case mv_ls of
        | ListCons i cvalue tl0 => Return (SOME cvalue)
        | ListNil => Fail Failure)
      else hash_map_remove_from_list_loop_fwd key tl
    | ListNil => Return NONE)
’

val hash_map_remove_from_list_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::remove_from_list]: forward function *)
  hash_map_remove_from_list_fwd
    (key : usize) (ls : 't list_t) : 't option result =
    hash_map_remove_from_list_loop_fwd key ls
’

val [hash_map_remove_from_list_loop_back_def] = DefineDiv ‘
  (** [hashmap::HashMap::{0}::remove_from_list]: loop 0: backward function 1 *)
  hash_map_remove_from_list_loop_back
    (key : usize) (ls : 't list_t) : 't list_t result =
    (case ls of
    | ListCons ckey t tl =>
      if ckey = key
      then
        let mv_ls = mem_replace_fwd (ListCons ckey t tl) ListNil in
        (case mv_ls of
        | ListCons i cvalue tl0 => Return tl0
        | ListNil => Fail Failure)
      else (
        do
        tl0 <- hash_map_remove_from_list_loop_back key tl;
        Return (ListCons ckey t tl0)
        od)
    | ListNil => Return ListNil)
’

val hash_map_remove_from_list_back_def = Define ‘
  (** [hashmap::HashMap::{0}::remove_from_list]: backward function 1 *)
  hash_map_remove_from_list_back
    (key : usize) (ls : 't list_t) : 't list_t result =
    hash_map_remove_from_list_loop_back key ls
’

val hash_map_remove_fwd_def = Define ‘
  (** [hashmap::HashMap::{0}::remove]: forward function *)
  hash_map_remove_fwd (self : 't hash_map_t) (key : usize) : 't option result =
    do
    hash <- hash_key_fwd key;
    let i = vec_len self.hash_map_slots in
    do
    hash_mod <- usize_rem hash i;
    l <- vec_index_mut_fwd self.hash_map_slots hash_mod;
    x <- hash_map_remove_from_list_fwd key l;
    (case x of
    | NONE => Return NONE
    | SOME x0 =>
      do
      _ <- usize_sub self.hash_map_num_entries (int_to_usize 1);
      Return (SOME x0)
      od)
    od
    od
’

val hash_map_remove_back_def = Define ‘
  (** [hashmap::HashMap::{0}::remove]: backward function 0 *)
  hash_map_remove_back
    (self : 't hash_map_t) (key : usize) : 't hash_map_t result =
    do
    hash <- hash_key_fwd key;
    let i = vec_len self.hash_map_slots in
    do
    hash_mod <- usize_rem hash i;
    l <- vec_index_mut_fwd self.hash_map_slots hash_mod;
    x <- hash_map_remove_from_list_fwd key l;
    (case x of
    | NONE =>
      do
      l0 <- hash_map_remove_from_list_back key l;
      v <- vec_index_mut_back self.hash_map_slots hash_mod l0;
      Return (self with <| hash_map_slots := v |>)
      od
    | SOME x0 =>
      do
      i0 <- usize_sub self.hash_map_num_entries (int_to_usize 1);
      l0 <- hash_map_remove_from_list_back key l;
      v <- vec_index_mut_back self.hash_map_slots hash_mod l0;
      Return (self with <| hash_map_num_entries := i0; hash_map_slots := v |>)
      od)
    od
    od
’

val test1_fwd_def = Define ‘
  (** [hashmap::test1]: forward function *)
  test1_fwd : unit result =
    do
    hm <- hash_map_new_fwd;
    hm0 <- hash_map_insert_fwd_back hm (int_to_usize 0) (int_to_u64 42);
    hm1 <- hash_map_insert_fwd_back hm0 (int_to_usize 128) (int_to_u64 18);
    hm2 <- hash_map_insert_fwd_back hm1 (int_to_usize 1024) (int_to_u64 138);
    hm3 <- hash_map_insert_fwd_back hm2 (int_to_usize 1056) (int_to_u64 256);
    i <- hash_map_get_fwd hm3 (int_to_usize 128);
    if ~ (i = int_to_u64 18)
    then Fail Failure
    else (
      do
      hm4 <- hash_map_get_mut_back hm3 (int_to_usize 1024) (int_to_u64 56);
      i0 <- hash_map_get_fwd hm4 (int_to_usize 1024);
      if ~ (i0 = int_to_u64 56)
      then Fail Failure
      else (
        do
        x <- hash_map_remove_fwd hm4 (int_to_usize 1024);
        (case x of
        | NONE => Fail Failure
        | SOME x0 =>
          if ~ (x0 = int_to_u64 56)
          then Fail Failure
          else (
            do
            hm5 <- hash_map_remove_back hm4 (int_to_usize 1024);
            i1 <- hash_map_get_fwd hm5 (int_to_usize 0);
            if ~ (i1 = int_to_u64 42)
            then Fail Failure
            else (
              do
              i2 <- hash_map_get_fwd hm5 (int_to_usize 128);
              if ~ (i2 = int_to_u64 18)
              then Fail Failure
              else (
                do
                i3 <- hash_map_get_fwd hm5 (int_to_usize 1056);
                if ~ (i3 = int_to_u64 256) then Fail Failure else Return ()
                od)
              od)
            od))
        od)
      od)
    od
’

(** Unit test for [hashmap::test1] *)
val _ = assert_return (“test1_fwd”)

val _ = export_theory ()
