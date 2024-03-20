(** THIS FILE WAS AUTOMATICALLY GENERATED BY AENEAS *)
(** [hashmap_main]: function definitions *)
Require Import Primitives.
Import Primitives.
Require Import Coq.ZArith.ZArith.
Require Import List.
Import ListNotations.
Local Open Scope Primitives_scope.
Require Import HashmapMain_Types.
Include HashmapMain_Types.
Require Import HashmapMain_FunsExternal.
Include HashmapMain_FunsExternal.
Module HashmapMain_Funs.

(** [hashmap_main::hashmap::hash_key]:
    Source: 'src/hashmap.rs', lines 27:0-27:32 *)
Definition hashmap_hash_key (k : usize) : result usize :=
  Return k.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::allocate_slots]: loop 0:
    Source: 'src/hashmap.rs', lines 50:4-56:5 *)
Fixpoint hashmap_HashMap_allocate_slots_loop
  (T : Type) (n : nat) (slots : alloc_vec_Vec (hashmap_List_t T)) (n1 : usize)
  :
  result (alloc_vec_Vec (hashmap_List_t T))
  :=
  match n with
  | O => Fail_ OutOfFuel
  | S n2 =>
    if n1 s> 0%usize
    then (
      slots1 <- alloc_vec_Vec_push (hashmap_List_t T) slots Hashmap_List_Nil;
      n3 <- usize_sub n1 1%usize;
      hashmap_HashMap_allocate_slots_loop T n2 slots1 n3)
    else Return slots
  end
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::allocate_slots]:
    Source: 'src/hashmap.rs', lines 50:4-50:76 *)
Definition hashmap_HashMap_allocate_slots
  (T : Type) (n : nat) (slots : alloc_vec_Vec (hashmap_List_t T)) (n1 : usize)
  :
  result (alloc_vec_Vec (hashmap_List_t T))
  :=
  hashmap_HashMap_allocate_slots_loop T n slots n1
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::new_with_capacity]:
    Source: 'src/hashmap.rs', lines 59:4-63:13 *)
Definition hashmap_HashMap_new_with_capacity
  (T : Type) (n : nat) (capacity : usize) (max_load_dividend : usize)
  (max_load_divisor : usize) :
  result (hashmap_HashMap_t T)
  :=
  slots <-
    hashmap_HashMap_allocate_slots T n (alloc_vec_Vec_new (hashmap_List_t T))
      capacity;
  i <- usize_mul capacity max_load_dividend;
  i1 <- usize_div i max_load_divisor;
  Return
    {|
      hashmap_HashMap_num_entries := 0%usize;
      hashmap_HashMap_max_load_factor := (max_load_dividend, max_load_divisor);
      hashmap_HashMap_max_load := i1;
      hashmap_HashMap_slots := slots
    |}
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::new]:
    Source: 'src/hashmap.rs', lines 75:4-75:24 *)
Definition hashmap_HashMap_new
  (T : Type) (n : nat) : result (hashmap_HashMap_t T) :=
  hashmap_HashMap_new_with_capacity T n 32%usize 4%usize 5%usize
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::clear]: loop 0:
    Source: 'src/hashmap.rs', lines 80:4-88:5 *)
Fixpoint hashmap_HashMap_clear_loop
  (T : Type) (n : nat) (slots : alloc_vec_Vec (hashmap_List_t T)) (i : usize) :
  result (alloc_vec_Vec (hashmap_List_t T))
  :=
  match n with
  | O => Fail_ OutOfFuel
  | S n1 =>
    let i1 := alloc_vec_Vec_len (hashmap_List_t T) slots in
    if i s< i1
    then (
      p <-
        alloc_vec_Vec_index_mut (hashmap_List_t T) usize
          (core_slice_index_SliceIndexUsizeSliceTInst (hashmap_List_t T)) slots
          i;
      let (_, index_mut_back) := p in
      i2 <- usize_add i 1%usize;
      slots1 <- index_mut_back Hashmap_List_Nil;
      hashmap_HashMap_clear_loop T n1 slots1 i2)
    else Return slots
  end
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::clear]:
    Source: 'src/hashmap.rs', lines 80:4-80:27 *)
Definition hashmap_HashMap_clear
  (T : Type) (n : nat) (self : hashmap_HashMap_t T) :
  result (hashmap_HashMap_t T)
  :=
  back <- hashmap_HashMap_clear_loop T n self.(hashmap_HashMap_slots) 0%usize;
  Return
    {|
      hashmap_HashMap_num_entries := 0%usize;
      hashmap_HashMap_max_load_factor := self.(hashmap_HashMap_max_load_factor);
      hashmap_HashMap_max_load := self.(hashmap_HashMap_max_load);
      hashmap_HashMap_slots := back
    |}
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::len]:
    Source: 'src/hashmap.rs', lines 90:4-90:30 *)
Definition hashmap_HashMap_len
  (T : Type) (self : hashmap_HashMap_t T) : result usize :=
  Return self.(hashmap_HashMap_num_entries)
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::insert_in_list]: loop 0:
    Source: 'src/hashmap.rs', lines 97:4-114:5 *)
Fixpoint hashmap_HashMap_insert_in_list_loop
  (T : Type) (n : nat) (key : usize) (value : T) (ls : hashmap_List_t T) :
  result (bool * (hashmap_List_t T))
  :=
  match n with
  | O => Fail_ OutOfFuel
  | S n1 =>
    match ls with
    | Hashmap_List_Cons ckey cvalue tl =>
      if ckey s= key
      then Return (false, Hashmap_List_Cons ckey value tl)
      else (
        p <- hashmap_HashMap_insert_in_list_loop T n1 key value tl;
        let (b, back) := p in
        Return (b, Hashmap_List_Cons ckey cvalue back))
    | Hashmap_List_Nil =>
      Return (true, Hashmap_List_Cons key value Hashmap_List_Nil)
    end
  end
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::insert_in_list]:
    Source: 'src/hashmap.rs', lines 97:4-97:71 *)
Definition hashmap_HashMap_insert_in_list
  (T : Type) (n : nat) (key : usize) (value : T) (ls : hashmap_List_t T) :
  result (bool * (hashmap_List_t T))
  :=
  hashmap_HashMap_insert_in_list_loop T n key value ls
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::insert_no_resize]:
    Source: 'src/hashmap.rs', lines 117:4-117:54 *)
Definition hashmap_HashMap_insert_no_resize
  (T : Type) (n : nat) (self : hashmap_HashMap_t T) (key : usize) (value : T) :
  result (hashmap_HashMap_t T)
  :=
  hash <- hashmap_hash_key key;
  let i := alloc_vec_Vec_len (hashmap_List_t T) self.(hashmap_HashMap_slots) in
  hash_mod <- usize_rem hash i;
  p <-
    alloc_vec_Vec_index_mut (hashmap_List_t T) usize
      (core_slice_index_SliceIndexUsizeSliceTInst (hashmap_List_t T))
      self.(hashmap_HashMap_slots) hash_mod;
  let (l, index_mut_back) := p in
  p1 <- hashmap_HashMap_insert_in_list T n key value l;
  let (inserted, l1) := p1 in
  if inserted
  then (
    i1 <- usize_add self.(hashmap_HashMap_num_entries) 1%usize;
    v <- index_mut_back l1;
    Return
      {|
        hashmap_HashMap_num_entries := i1;
        hashmap_HashMap_max_load_factor :=
          self.(hashmap_HashMap_max_load_factor);
        hashmap_HashMap_max_load := self.(hashmap_HashMap_max_load);
        hashmap_HashMap_slots := v
      |})
  else (
    v <- index_mut_back l1;
    Return
      {|
        hashmap_HashMap_num_entries := self.(hashmap_HashMap_num_entries);
        hashmap_HashMap_max_load_factor :=
          self.(hashmap_HashMap_max_load_factor);
        hashmap_HashMap_max_load := self.(hashmap_HashMap_max_load);
        hashmap_HashMap_slots := v
      |})
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::move_elements_from_list]: loop 0:
    Source: 'src/hashmap.rs', lines 183:4-196:5 *)
Fixpoint hashmap_HashMap_move_elements_from_list_loop
  (T : Type) (n : nat) (ntable : hashmap_HashMap_t T) (ls : hashmap_List_t T) :
  result (hashmap_HashMap_t T)
  :=
  match n with
  | O => Fail_ OutOfFuel
  | S n1 =>
    match ls with
    | Hashmap_List_Cons k v tl =>
      ntable1 <- hashmap_HashMap_insert_no_resize T n1 ntable k v;
      hashmap_HashMap_move_elements_from_list_loop T n1 ntable1 tl
    | Hashmap_List_Nil => Return ntable
    end
  end
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::move_elements_from_list]:
    Source: 'src/hashmap.rs', lines 183:4-183:72 *)
Definition hashmap_HashMap_move_elements_from_list
  (T : Type) (n : nat) (ntable : hashmap_HashMap_t T) (ls : hashmap_List_t T) :
  result (hashmap_HashMap_t T)
  :=
  hashmap_HashMap_move_elements_from_list_loop T n ntable ls
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::move_elements]: loop 0:
    Source: 'src/hashmap.rs', lines 171:4-180:5 *)
Fixpoint hashmap_HashMap_move_elements_loop
  (T : Type) (n : nat) (ntable : hashmap_HashMap_t T)
  (slots : alloc_vec_Vec (hashmap_List_t T)) (i : usize) :
  result ((hashmap_HashMap_t T) * (alloc_vec_Vec (hashmap_List_t T)))
  :=
  match n with
  | O => Fail_ OutOfFuel
  | S n1 =>
    let i1 := alloc_vec_Vec_len (hashmap_List_t T) slots in
    if i s< i1
    then (
      p <-
        alloc_vec_Vec_index_mut (hashmap_List_t T) usize
          (core_slice_index_SliceIndexUsizeSliceTInst (hashmap_List_t T)) slots
          i;
      let (l, index_mut_back) := p in
      let (ls, l1) := core_mem_replace (hashmap_List_t T) l Hashmap_List_Nil in
      ntable1 <- hashmap_HashMap_move_elements_from_list T n1 ntable ls;
      i2 <- usize_add i 1%usize;
      slots1 <- index_mut_back l1;
      hashmap_HashMap_move_elements_loop T n1 ntable1 slots1 i2)
    else Return (ntable, slots)
  end
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::move_elements]:
    Source: 'src/hashmap.rs', lines 171:4-171:95 *)
Definition hashmap_HashMap_move_elements
  (T : Type) (n : nat) (ntable : hashmap_HashMap_t T)
  (slots : alloc_vec_Vec (hashmap_List_t T)) (i : usize) :
  result ((hashmap_HashMap_t T) * (alloc_vec_Vec (hashmap_List_t T)))
  :=
  hashmap_HashMap_move_elements_loop T n ntable slots i
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::try_resize]:
    Source: 'src/hashmap.rs', lines 140:4-140:28 *)
Definition hashmap_HashMap_try_resize
  (T : Type) (n : nat) (self : hashmap_HashMap_t T) :
  result (hashmap_HashMap_t T)
  :=
  max_usize <- scalar_cast U32 Usize core_u32_max;
  let capacity :=
    alloc_vec_Vec_len (hashmap_List_t T) self.(hashmap_HashMap_slots) in
  n1 <- usize_div max_usize 2%usize;
  let (i, i1) := self.(hashmap_HashMap_max_load_factor) in
  i2 <- usize_div n1 i;
  if capacity s<= i2
  then (
    i3 <- usize_mul capacity 2%usize;
    ntable <- hashmap_HashMap_new_with_capacity T n i3 i i1;
    p <-
      hashmap_HashMap_move_elements T n ntable self.(hashmap_HashMap_slots)
        0%usize;
    let (ntable1, _) := p in
    Return
      {|
        hashmap_HashMap_num_entries := self.(hashmap_HashMap_num_entries);
        hashmap_HashMap_max_load_factor := (i, i1);
        hashmap_HashMap_max_load := ntable1.(hashmap_HashMap_max_load);
        hashmap_HashMap_slots := ntable1.(hashmap_HashMap_slots)
      |})
  else
    Return
      {|
        hashmap_HashMap_num_entries := self.(hashmap_HashMap_num_entries);
        hashmap_HashMap_max_load_factor := (i, i1);
        hashmap_HashMap_max_load := self.(hashmap_HashMap_max_load);
        hashmap_HashMap_slots := self.(hashmap_HashMap_slots)
      |}
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::insert]:
    Source: 'src/hashmap.rs', lines 129:4-129:48 *)
Definition hashmap_HashMap_insert
  (T : Type) (n : nat) (self : hashmap_HashMap_t T) (key : usize) (value : T) :
  result (hashmap_HashMap_t T)
  :=
  self1 <- hashmap_HashMap_insert_no_resize T n self key value;
  i <- hashmap_HashMap_len T self1;
  if i s> self1.(hashmap_HashMap_max_load)
  then hashmap_HashMap_try_resize T n self1
  else Return self1
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::contains_key_in_list]: loop 0:
    Source: 'src/hashmap.rs', lines 206:4-219:5 *)
Fixpoint hashmap_HashMap_contains_key_in_list_loop
  (T : Type) (n : nat) (key : usize) (ls : hashmap_List_t T) : result bool :=
  match n with
  | O => Fail_ OutOfFuel
  | S n1 =>
    match ls with
    | Hashmap_List_Cons ckey _ tl =>
      if ckey s= key
      then Return true
      else hashmap_HashMap_contains_key_in_list_loop T n1 key tl
    | Hashmap_List_Nil => Return false
    end
  end
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::contains_key_in_list]:
    Source: 'src/hashmap.rs', lines 206:4-206:68 *)
Definition hashmap_HashMap_contains_key_in_list
  (T : Type) (n : nat) (key : usize) (ls : hashmap_List_t T) : result bool :=
  hashmap_HashMap_contains_key_in_list_loop T n key ls
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::contains_key]:
    Source: 'src/hashmap.rs', lines 199:4-199:49 *)
Definition hashmap_HashMap_contains_key
  (T : Type) (n : nat) (self : hashmap_HashMap_t T) (key : usize) :
  result bool
  :=
  hash <- hashmap_hash_key key;
  let i := alloc_vec_Vec_len (hashmap_List_t T) self.(hashmap_HashMap_slots) in
  hash_mod <- usize_rem hash i;
  l <-
    alloc_vec_Vec_index (hashmap_List_t T) usize
      (core_slice_index_SliceIndexUsizeSliceTInst (hashmap_List_t T))
      self.(hashmap_HashMap_slots) hash_mod;
  hashmap_HashMap_contains_key_in_list T n key l
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::get_in_list]: loop 0:
    Source: 'src/hashmap.rs', lines 224:4-237:5 *)
Fixpoint hashmap_HashMap_get_in_list_loop
  (T : Type) (n : nat) (key : usize) (ls : hashmap_List_t T) : result T :=
  match n with
  | O => Fail_ OutOfFuel
  | S n1 =>
    match ls with
    | Hashmap_List_Cons ckey cvalue tl =>
      if ckey s= key
      then Return cvalue
      else hashmap_HashMap_get_in_list_loop T n1 key tl
    | Hashmap_List_Nil => Fail_ Failure
    end
  end
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::get_in_list]:
    Source: 'src/hashmap.rs', lines 224:4-224:70 *)
Definition hashmap_HashMap_get_in_list
  (T : Type) (n : nat) (key : usize) (ls : hashmap_List_t T) : result T :=
  hashmap_HashMap_get_in_list_loop T n key ls
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::get]:
    Source: 'src/hashmap.rs', lines 239:4-239:55 *)
Definition hashmap_HashMap_get
  (T : Type) (n : nat) (self : hashmap_HashMap_t T) (key : usize) : result T :=
  hash <- hashmap_hash_key key;
  let i := alloc_vec_Vec_len (hashmap_List_t T) self.(hashmap_HashMap_slots) in
  hash_mod <- usize_rem hash i;
  l <-
    alloc_vec_Vec_index (hashmap_List_t T) usize
      (core_slice_index_SliceIndexUsizeSliceTInst (hashmap_List_t T))
      self.(hashmap_HashMap_slots) hash_mod;
  hashmap_HashMap_get_in_list T n key l
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::get_mut_in_list]: loop 0:
    Source: 'src/hashmap.rs', lines 245:4-254:5 *)
Fixpoint hashmap_HashMap_get_mut_in_list_loop
  (T : Type) (n : nat) (ls : hashmap_List_t T) (key : usize) :
  result (T * (T -> result (hashmap_List_t T)))
  :=
  match n with
  | O => Fail_ OutOfFuel
  | S n1 =>
    match ls with
    | Hashmap_List_Cons ckey cvalue tl =>
      if ckey s= key
      then
        let back_'a := fun (ret : T) => Return (Hashmap_List_Cons ckey ret tl)
          in
        Return (cvalue, back_'a)
      else (
        p <- hashmap_HashMap_get_mut_in_list_loop T n1 tl key;
        let (t, back_'a) := p in
        let back_'a1 :=
          fun (ret : T) =>
            tl1 <- back_'a ret; Return (Hashmap_List_Cons ckey cvalue tl1) in
        Return (t, back_'a1))
    | Hashmap_List_Nil => Fail_ Failure
    end
  end
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::get_mut_in_list]:
    Source: 'src/hashmap.rs', lines 245:4-245:86 *)
Definition hashmap_HashMap_get_mut_in_list
  (T : Type) (n : nat) (ls : hashmap_List_t T) (key : usize) :
  result (T * (T -> result (hashmap_List_t T)))
  :=
  hashmap_HashMap_get_mut_in_list_loop T n ls key
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::get_mut]:
    Source: 'src/hashmap.rs', lines 257:4-257:67 *)
Definition hashmap_HashMap_get_mut
  (T : Type) (n : nat) (self : hashmap_HashMap_t T) (key : usize) :
  result (T * (T -> result (hashmap_HashMap_t T)))
  :=
  hash <- hashmap_hash_key key;
  let i := alloc_vec_Vec_len (hashmap_List_t T) self.(hashmap_HashMap_slots) in
  hash_mod <- usize_rem hash i;
  p <-
    alloc_vec_Vec_index_mut (hashmap_List_t T) usize
      (core_slice_index_SliceIndexUsizeSliceTInst (hashmap_List_t T))
      self.(hashmap_HashMap_slots) hash_mod;
  let (l, index_mut_back) := p in
  p1 <- hashmap_HashMap_get_mut_in_list T n l key;
  let (t, get_mut_in_list_back) := p1 in
  let back_'a :=
    fun (ret : T) =>
      l1 <- get_mut_in_list_back ret;
      v <- index_mut_back l1;
      Return
        {|
          hashmap_HashMap_num_entries := self.(hashmap_HashMap_num_entries);
          hashmap_HashMap_max_load_factor :=
            self.(hashmap_HashMap_max_load_factor);
          hashmap_HashMap_max_load := self.(hashmap_HashMap_max_load);
          hashmap_HashMap_slots := v
        |} in
  Return (t, back_'a)
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::remove_from_list]: loop 0:
    Source: 'src/hashmap.rs', lines 265:4-291:5 *)
Fixpoint hashmap_HashMap_remove_from_list_loop
  (T : Type) (n : nat) (key : usize) (ls : hashmap_List_t T) :
  result ((option T) * (hashmap_List_t T))
  :=
  match n with
  | O => Fail_ OutOfFuel
  | S n1 =>
    match ls with
    | Hashmap_List_Cons ckey t tl =>
      if ckey s= key
      then
        let (mv_ls, _) :=
          core_mem_replace (hashmap_List_t T) (Hashmap_List_Cons ckey t tl)
            Hashmap_List_Nil in
        match mv_ls with
        | Hashmap_List_Cons _ cvalue tl1 => Return (Some cvalue, tl1)
        | Hashmap_List_Nil => Fail_ Failure
        end
      else (
        p <- hashmap_HashMap_remove_from_list_loop T n1 key tl;
        let (o, back) := p in
        Return (o, Hashmap_List_Cons ckey t back))
    | Hashmap_List_Nil => Return (None, Hashmap_List_Nil)
    end
  end
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::remove_from_list]:
    Source: 'src/hashmap.rs', lines 265:4-265:69 *)
Definition hashmap_HashMap_remove_from_list
  (T : Type) (n : nat) (key : usize) (ls : hashmap_List_t T) :
  result ((option T) * (hashmap_List_t T))
  :=
  hashmap_HashMap_remove_from_list_loop T n key ls
.

(** [hashmap_main::hashmap::{hashmap_main::hashmap::HashMap<T>}::remove]:
    Source: 'src/hashmap.rs', lines 294:4-294:52 *)
Definition hashmap_HashMap_remove
  (T : Type) (n : nat) (self : hashmap_HashMap_t T) (key : usize) :
  result ((option T) * (hashmap_HashMap_t T))
  :=
  hash <- hashmap_hash_key key;
  let i := alloc_vec_Vec_len (hashmap_List_t T) self.(hashmap_HashMap_slots) in
  hash_mod <- usize_rem hash i;
  p <-
    alloc_vec_Vec_index_mut (hashmap_List_t T) usize
      (core_slice_index_SliceIndexUsizeSliceTInst (hashmap_List_t T))
      self.(hashmap_HashMap_slots) hash_mod;
  let (l, index_mut_back) := p in
  p1 <- hashmap_HashMap_remove_from_list T n key l;
  let (x, l1) := p1 in
  match x with
  | None =>
    v <- index_mut_back l1;
    Return (None,
      {|
        hashmap_HashMap_num_entries := self.(hashmap_HashMap_num_entries);
        hashmap_HashMap_max_load_factor :=
          self.(hashmap_HashMap_max_load_factor);
        hashmap_HashMap_max_load := self.(hashmap_HashMap_max_load);
        hashmap_HashMap_slots := v
      |})
  | Some x1 =>
    i1 <- usize_sub self.(hashmap_HashMap_num_entries) 1%usize;
    v <- index_mut_back l1;
    Return (Some x1,
      {|
        hashmap_HashMap_num_entries := i1;
        hashmap_HashMap_max_load_factor :=
          self.(hashmap_HashMap_max_load_factor);
        hashmap_HashMap_max_load := self.(hashmap_HashMap_max_load);
        hashmap_HashMap_slots := v
      |})
  end
.

(** [hashmap_main::hashmap::test1]:
    Source: 'src/hashmap.rs', lines 315:0-315:10 *)
Definition hashmap_test1 (n : nat) : result unit :=
  hm <- hashmap_HashMap_new u64 n;
  hm1 <- hashmap_HashMap_insert u64 n hm 0%usize 42%u64;
  hm2 <- hashmap_HashMap_insert u64 n hm1 128%usize 18%u64;
  hm3 <- hashmap_HashMap_insert u64 n hm2 1024%usize 138%u64;
  hm4 <- hashmap_HashMap_insert u64 n hm3 1056%usize 256%u64;
  i <- hashmap_HashMap_get u64 n hm4 128%usize;
  if negb (i s= 18%u64)
  then Fail_ Failure
  else (
    p <- hashmap_HashMap_get_mut u64 n hm4 1024%usize;
    let (_, get_mut_back) := p in
    hm5 <- get_mut_back 56%u64;
    i1 <- hashmap_HashMap_get u64 n hm5 1024%usize;
    if negb (i1 s= 56%u64)
    then Fail_ Failure
    else (
      p1 <- hashmap_HashMap_remove u64 n hm5 1024%usize;
      let (x, hm6) := p1 in
      match x with
      | None => Fail_ Failure
      | Some x1 =>
        if negb (x1 s= 56%u64)
        then Fail_ Failure
        else (
          i2 <- hashmap_HashMap_get u64 n hm6 0%usize;
          if negb (i2 s= 42%u64)
          then Fail_ Failure
          else (
            i3 <- hashmap_HashMap_get u64 n hm6 128%usize;
            if negb (i3 s= 18%u64)
            then Fail_ Failure
            else (
              i4 <- hashmap_HashMap_get u64 n hm6 1056%usize;
              if negb (i4 s= 256%u64) then Fail_ Failure else Return tt)))
      end))
.

(** [hashmap_main::insert_on_disk]:
    Source: 'src/hashmap_main.rs', lines 7:0-7:43 *)
Definition insert_on_disk
  (n : nat) (key : usize) (value : u64) (st : state) : result (state * unit) :=
  p <- hashmap_utils_deserialize st;
  let (st1, hm) := p in
  hm1 <- hashmap_HashMap_insert u64 n hm key value;
  hashmap_utils_serialize hm1 st1
.

(** [hashmap_main::main]:
    Source: 'src/hashmap_main.rs', lines 16:0-16:13 *)
Definition main : result unit :=
  Return tt.

End HashmapMain_Funs.
