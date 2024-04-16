(** [loops]: function definitions *)
open primitivesLib divDefLib
open loops_TypesTheory

val _ = new_theory "loops_Funs"


val [sum_loop_fwd_def] = DefineDiv ‘
  (** [loops::sum]: loop 0: forward function *)
  sum_loop_fwd (max : u32) (i : u32) (s : u32) : u32 result =
    if u32_lt i max
    then (
      do
      s0 <- u32_add s i;
      i0 <- u32_add i (int_to_u32 1);
      sum_loop_fwd max i0 s0
      od)
    else u32_mul s (int_to_u32 2)
’

val sum_fwd_def = Define ‘
  (** [loops::sum]: forward function *)
  sum_fwd (max : u32) : u32 result =
    sum_loop_fwd max (int_to_u32 0) (int_to_u32 0)
’

val [sum_with_mut_borrows_loop_fwd_def] = DefineDiv ‘
  (** [loops::sum_with_mut_borrows]: loop 0: forward function *)
  sum_with_mut_borrows_loop_fwd
    (max : u32) (mi : u32) (ms : u32) : u32 result =
    if u32_lt mi max
    then (
      do
      ms0 <- u32_add ms mi;
      mi0 <- u32_add mi (int_to_u32 1);
      sum_with_mut_borrows_loop_fwd max mi0 ms0
      od)
    else u32_mul ms (int_to_u32 2)
’

val sum_with_mut_borrows_fwd_def = Define ‘
  (** [loops::sum_with_mut_borrows]: forward function *)
  sum_with_mut_borrows_fwd (max : u32) : u32 result =
    sum_with_mut_borrows_loop_fwd max (int_to_u32 0) (int_to_u32 0)
’

val [sum_with_shared_borrows_loop_fwd_def] = DefineDiv ‘
  (** [loops::sum_with_shared_borrows]: loop 0: forward function *)
  sum_with_shared_borrows_loop_fwd
    (max : u32) (i : u32) (s : u32) : u32 result =
    if u32_lt i max
    then (
      do
      i0 <- u32_add i (int_to_u32 1);
      s0 <- u32_add s i0;
      sum_with_shared_borrows_loop_fwd max i0 s0
      od)
    else u32_mul s (int_to_u32 2)
’

val sum_with_shared_borrows_fwd_def = Define ‘
  (** [loops::sum_with_shared_borrows]: forward function *)
  sum_with_shared_borrows_fwd (max : u32) : u32 result =
    sum_with_shared_borrows_loop_fwd max (int_to_u32 0) (int_to_u32 0)
’

val [clear_loop_fwd_back_def] = DefineDiv ‘
  (** [loops::clear]: loop 0: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  clear_loop_fwd_back (v : u32 vec) (i : usize) : u32 vec result =
    let i0 = vec_len v in
    if usize_lt i i0
    then (
      do
      i1 <- usize_add i (int_to_usize 1);
      v0 <- vec_index_mut_back v i (int_to_u32 0);
      clear_loop_fwd_back v0 i1
      od)
    else Return v
’

val clear_fwd_back_def = Define ‘
  (** [loops::clear]: merged forward/backward function
      (there is a single backward function, and the forward function returns ()) *)
  clear_fwd_back (v : u32 vec) : u32 vec result =
    clear_loop_fwd_back v (int_to_usize 0)
’

val [list_mem_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_mem]: loop 0: forward function *)
  list_mem_loop_fwd (x : u32) (ls : u32 list_t) : bool result =
    (case ls of
    | ListCons y tl => if y = x then Return T else list_mem_loop_fwd x tl
    | ListNil => Return F)
’

val list_mem_fwd_def = Define ‘
  (** [loops::list_mem]: forward function *)
  list_mem_fwd (x : u32) (ls : u32 list_t) : bool result =
    list_mem_loop_fwd x ls
’

val [list_nth_mut_loop_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_mut_loop]: loop 0: forward function *)
  list_nth_mut_loop_loop_fwd (ls : 't list_t) (i : u32) : 't result =
    (case ls of
    | ListCons x tl =>
      if i = int_to_u32 0
      then Return x
      else (
        do
        i0 <- u32_sub i (int_to_u32 1);
        list_nth_mut_loop_loop_fwd tl i0
        od)
    | ListNil => Fail Failure)
’

val list_nth_mut_loop_fwd_def = Define ‘
  (** [loops::list_nth_mut_loop]: forward function *)
  list_nth_mut_loop_fwd (ls : 't list_t) (i : u32) : 't result =
    list_nth_mut_loop_loop_fwd ls i
’

val [list_nth_mut_loop_loop_back_def] = DefineDiv ‘
  (** [loops::list_nth_mut_loop]: loop 0: backward function 0 *)
  list_nth_mut_loop_loop_back
    (ls : 't list_t) (i : u32) (ret : 't) : 't list_t result =
    (case ls of
    | ListCons x tl =>
      if i = int_to_u32 0
      then Return (ListCons ret tl)
      else (
        do
        i0 <- u32_sub i (int_to_u32 1);
        tl0 <- list_nth_mut_loop_loop_back tl i0 ret;
        Return (ListCons x tl0)
        od)
    | ListNil => Fail Failure)
’

val list_nth_mut_loop_back_def = Define ‘
  (** [loops::list_nth_mut_loop]: backward function 0 *)
  list_nth_mut_loop_back
    (ls : 't list_t) (i : u32) (ret : 't) : 't list_t result =
    list_nth_mut_loop_loop_back ls i ret
’

val [list_nth_shared_loop_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_shared_loop]: loop 0: forward function *)
  list_nth_shared_loop_loop_fwd (ls : 't list_t) (i : u32) : 't result =
    (case ls of
    | ListCons x tl =>
      if i = int_to_u32 0
      then Return x
      else (
        do
        i0 <- u32_sub i (int_to_u32 1);
        list_nth_shared_loop_loop_fwd tl i0
        od)
    | ListNil => Fail Failure)
’

val list_nth_shared_loop_fwd_def = Define ‘
  (** [loops::list_nth_shared_loop]: forward function *)
  list_nth_shared_loop_fwd (ls : 't list_t) (i : u32) : 't result =
    list_nth_shared_loop_loop_fwd ls i
’

val [get_elem_mut_loop_fwd_def] = DefineDiv ‘
  (** [loops::get_elem_mut]: loop 0: forward function *)
  get_elem_mut_loop_fwd (x : usize) (ls : usize list_t) : usize result =
    (case ls of
    | ListCons y tl => if y = x then Return y else get_elem_mut_loop_fwd x tl
    | ListNil => Fail Failure)
’

val get_elem_mut_fwd_def = Define ‘
  (** [loops::get_elem_mut]: forward function *)
  get_elem_mut_fwd (slots : usize list_t vec) (x : usize) : usize result =
    do
    l <- vec_index_mut_fwd slots (int_to_usize 0);
    get_elem_mut_loop_fwd x l
    od
’

val [get_elem_mut_loop_back_def] = DefineDiv ‘
  (** [loops::get_elem_mut]: loop 0: backward function 0 *)
  get_elem_mut_loop_back
    (x : usize) (ls : usize list_t) (ret : usize) : usize list_t result =
    (case ls of
    | ListCons y tl =>
      if y = x
      then Return (ListCons ret tl)
      else (
        do
        tl0 <- get_elem_mut_loop_back x tl ret;
        Return (ListCons y tl0)
        od)
    | ListNil => Fail Failure)
’

val get_elem_mut_back_def = Define ‘
  (** [loops::get_elem_mut]: backward function 0 *)
  get_elem_mut_back
    (slots : usize list_t vec) (x : usize) (ret : usize) :
    usize list_t vec result
    =
    do
    l <- vec_index_mut_fwd slots (int_to_usize 0);
    l0 <- get_elem_mut_loop_back x l ret;
    vec_index_mut_back slots (int_to_usize 0) l0
    od
’

val [get_elem_shared_loop_fwd_def] = DefineDiv ‘
  (** [loops::get_elem_shared]: loop 0: forward function *)
  get_elem_shared_loop_fwd (x : usize) (ls : usize list_t) : usize result =
    (case ls of
    | ListCons y tl =>
      if y = x then Return y else get_elem_shared_loop_fwd x tl
    | ListNil => Fail Failure)
’

val get_elem_shared_fwd_def = Define ‘
  (** [loops::get_elem_shared]: forward function *)
  get_elem_shared_fwd (slots : usize list_t vec) (x : usize) : usize result =
    do
    l <- vec_index_fwd slots (int_to_usize 0);
    get_elem_shared_loop_fwd x l
    od
’

val id_mut_fwd_def = Define ‘
  (** [loops::id_mut]: forward function *)
  id_mut_fwd (ls : 't list_t) : 't list_t result =
    Return ls
’

val id_mut_back_def = Define ‘
  (** [loops::id_mut]: backward function 0 *)
  id_mut_back (ls : 't list_t) (ret : 't list_t) : 't list_t result =
    Return ret
’

val id_shared_fwd_def = Define ‘
  (** [loops::id_shared]: forward function *)
  id_shared_fwd (ls : 't list_t) : 't list_t result =
    Return ls
’

val [list_nth_mut_loop_with_id_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_mut_loop_with_id]: loop 0: forward function *)
  list_nth_mut_loop_with_id_loop_fwd (i : u32) (ls : 't list_t) : 't result =
    (case ls of
    | ListCons x tl =>
      if i = int_to_u32 0
      then Return x
      else (
        do
        i0 <- u32_sub i (int_to_u32 1);
        list_nth_mut_loop_with_id_loop_fwd i0 tl
        od)
    | ListNil => Fail Failure)
’

val list_nth_mut_loop_with_id_fwd_def = Define ‘
  (** [loops::list_nth_mut_loop_with_id]: forward function *)
  list_nth_mut_loop_with_id_fwd (ls : 't list_t) (i : u32) : 't result =
    do
    ls0 <- id_mut_fwd ls;
    list_nth_mut_loop_with_id_loop_fwd i ls0
    od
’

val [list_nth_mut_loop_with_id_loop_back_def] = DefineDiv ‘
  (** [loops::list_nth_mut_loop_with_id]: loop 0: backward function 0 *)
  list_nth_mut_loop_with_id_loop_back
    (i : u32) (ls : 't list_t) (ret : 't) : 't list_t result =
    (case ls of
    | ListCons x tl =>
      if i = int_to_u32 0
      then Return (ListCons ret tl)
      else (
        do
        i0 <- u32_sub i (int_to_u32 1);
        tl0 <- list_nth_mut_loop_with_id_loop_back i0 tl ret;
        Return (ListCons x tl0)
        od)
    | ListNil => Fail Failure)
’

val list_nth_mut_loop_with_id_back_def = Define ‘
  (** [loops::list_nth_mut_loop_with_id]: backward function 0 *)
  list_nth_mut_loop_with_id_back
    (ls : 't list_t) (i : u32) (ret : 't) : 't list_t result =
    do
    ls0 <- id_mut_fwd ls;
    l <- list_nth_mut_loop_with_id_loop_back i ls0 ret;
    id_mut_back ls l
    od
’

val [list_nth_shared_loop_with_id_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_shared_loop_with_id]: loop 0: forward function *)
  list_nth_shared_loop_with_id_loop_fwd
    (i : u32) (ls : 't list_t) : 't result =
    (case ls of
    | ListCons x tl =>
      if i = int_to_u32 0
      then Return x
      else (
        do
        i0 <- u32_sub i (int_to_u32 1);
        list_nth_shared_loop_with_id_loop_fwd i0 tl
        od)
    | ListNil => Fail Failure)
’

val list_nth_shared_loop_with_id_fwd_def = Define ‘
  (** [loops::list_nth_shared_loop_with_id]: forward function *)
  list_nth_shared_loop_with_id_fwd (ls : 't list_t) (i : u32) : 't result =
    do
    ls0 <- id_shared_fwd ls;
    list_nth_shared_loop_with_id_loop_fwd i ls0
    od
’

val [list_nth_mut_loop_pair_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_mut_loop_pair]: loop 0: forward function *)
  list_nth_mut_loop_pair_loop_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (x0, x1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          list_nth_mut_loop_pair_loop_fwd tl0 tl1 i0
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_mut_loop_pair_fwd_def = Define ‘
  (** [loops::list_nth_mut_loop_pair]: forward function *)
  list_nth_mut_loop_pair_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    list_nth_mut_loop_pair_loop_fwd ls0 ls1 i
’

val [list_nth_mut_loop_pair_loop_back'a_def] = DefineDiv ‘
  (** [loops::list_nth_mut_loop_pair]: loop 0: backward function 0 *)
  list_nth_mut_loop_pair_loop_back'a
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (ListCons ret tl0)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          tl00 <- list_nth_mut_loop_pair_loop_back'a tl0 tl1 i0 ret;
          Return (ListCons x0 tl00)
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_mut_loop_pair_back'a_def = Define ‘
  (** [loops::list_nth_mut_loop_pair]: backward function 0 *)
  list_nth_mut_loop_pair_back'a
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    list_nth_mut_loop_pair_loop_back'a ls0 ls1 i ret
’

val [list_nth_mut_loop_pair_loop_back'b_def] = DefineDiv ‘
  (** [loops::list_nth_mut_loop_pair]: loop 0: backward function 1 *)
  list_nth_mut_loop_pair_loop_back'b
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (ListCons ret tl1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          tl10 <- list_nth_mut_loop_pair_loop_back'b tl0 tl1 i0 ret;
          Return (ListCons x1 tl10)
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_mut_loop_pair_back'b_def = Define ‘
  (** [loops::list_nth_mut_loop_pair]: backward function 1 *)
  list_nth_mut_loop_pair_back'b
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    list_nth_mut_loop_pair_loop_back'b ls0 ls1 i ret
’

val [list_nth_shared_loop_pair_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_shared_loop_pair]: loop 0: forward function *)
  list_nth_shared_loop_pair_loop_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (x0, x1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          list_nth_shared_loop_pair_loop_fwd tl0 tl1 i0
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_shared_loop_pair_fwd_def = Define ‘
  (** [loops::list_nth_shared_loop_pair]: forward function *)
  list_nth_shared_loop_pair_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    list_nth_shared_loop_pair_loop_fwd ls0 ls1 i
’

val [list_nth_mut_loop_pair_merge_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_mut_loop_pair_merge]: loop 0: forward function *)
  list_nth_mut_loop_pair_merge_loop_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (x0, x1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          list_nth_mut_loop_pair_merge_loop_fwd tl0 tl1 i0
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_mut_loop_pair_merge_fwd_def = Define ‘
  (** [loops::list_nth_mut_loop_pair_merge]: forward function *)
  list_nth_mut_loop_pair_merge_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    list_nth_mut_loop_pair_merge_loop_fwd ls0 ls1 i
’

val [list_nth_mut_loop_pair_merge_loop_back_def] = DefineDiv ‘
  (** [loops::list_nth_mut_loop_pair_merge]: loop 0: backward function 0 *)
  list_nth_mut_loop_pair_merge_loop_back
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : ('t # 't)) :
    ('t list_t # 't list_t) result
    =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then let (t, t0) = ret in Return (ListCons t tl0, ListCons t0 tl1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          (tl00, tl10) <-
            list_nth_mut_loop_pair_merge_loop_back tl0 tl1 i0 ret;
          Return (ListCons x0 tl00, ListCons x1 tl10)
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_mut_loop_pair_merge_back_def = Define ‘
  (** [loops::list_nth_mut_loop_pair_merge]: backward function 0 *)
  list_nth_mut_loop_pair_merge_back
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : ('t # 't)) :
    ('t list_t # 't list_t) result
    =
    list_nth_mut_loop_pair_merge_loop_back ls0 ls1 i ret
’

val [list_nth_shared_loop_pair_merge_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_shared_loop_pair_merge]: loop 0: forward function *)
  list_nth_shared_loop_pair_merge_loop_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (x0, x1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          list_nth_shared_loop_pair_merge_loop_fwd tl0 tl1 i0
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_shared_loop_pair_merge_fwd_def = Define ‘
  (** [loops::list_nth_shared_loop_pair_merge]: forward function *)
  list_nth_shared_loop_pair_merge_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    list_nth_shared_loop_pair_merge_loop_fwd ls0 ls1 i
’

val [list_nth_mut_shared_loop_pair_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_mut_shared_loop_pair]: loop 0: forward function *)
  list_nth_mut_shared_loop_pair_loop_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (x0, x1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          list_nth_mut_shared_loop_pair_loop_fwd tl0 tl1 i0
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_mut_shared_loop_pair_fwd_def = Define ‘
  (** [loops::list_nth_mut_shared_loop_pair]: forward function *)
  list_nth_mut_shared_loop_pair_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    list_nth_mut_shared_loop_pair_loop_fwd ls0 ls1 i
’

val [list_nth_mut_shared_loop_pair_loop_back_def] = DefineDiv ‘
  (** [loops::list_nth_mut_shared_loop_pair]: loop 0: backward function 0 *)
  list_nth_mut_shared_loop_pair_loop_back
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (ListCons ret tl0)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          tl00 <- list_nth_mut_shared_loop_pair_loop_back tl0 tl1 i0 ret;
          Return (ListCons x0 tl00)
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_mut_shared_loop_pair_back_def = Define ‘
  (** [loops::list_nth_mut_shared_loop_pair]: backward function 0 *)
  list_nth_mut_shared_loop_pair_back
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    list_nth_mut_shared_loop_pair_loop_back ls0 ls1 i ret
’

val [list_nth_mut_shared_loop_pair_merge_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_mut_shared_loop_pair_merge]: loop 0: forward function *)
  list_nth_mut_shared_loop_pair_merge_loop_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (x0, x1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          list_nth_mut_shared_loop_pair_merge_loop_fwd tl0 tl1 i0
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_mut_shared_loop_pair_merge_fwd_def = Define ‘
  (** [loops::list_nth_mut_shared_loop_pair_merge]: forward function *)
  list_nth_mut_shared_loop_pair_merge_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    list_nth_mut_shared_loop_pair_merge_loop_fwd ls0 ls1 i
’

val [list_nth_mut_shared_loop_pair_merge_loop_back_def] = DefineDiv ‘
  (** [loops::list_nth_mut_shared_loop_pair_merge]: loop 0: backward function 0 *)
  list_nth_mut_shared_loop_pair_merge_loop_back
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (ListCons ret tl0)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          tl00 <- list_nth_mut_shared_loop_pair_merge_loop_back tl0 tl1 i0 ret;
          Return (ListCons x0 tl00)
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_mut_shared_loop_pair_merge_back_def = Define ‘
  (** [loops::list_nth_mut_shared_loop_pair_merge]: backward function 0 *)
  list_nth_mut_shared_loop_pair_merge_back
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    list_nth_mut_shared_loop_pair_merge_loop_back ls0 ls1 i ret
’

val [list_nth_shared_mut_loop_pair_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_shared_mut_loop_pair]: loop 0: forward function *)
  list_nth_shared_mut_loop_pair_loop_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (x0, x1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          list_nth_shared_mut_loop_pair_loop_fwd tl0 tl1 i0
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_shared_mut_loop_pair_fwd_def = Define ‘
  (** [loops::list_nth_shared_mut_loop_pair]: forward function *)
  list_nth_shared_mut_loop_pair_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    list_nth_shared_mut_loop_pair_loop_fwd ls0 ls1 i
’

val [list_nth_shared_mut_loop_pair_loop_back_def] = DefineDiv ‘
  (** [loops::list_nth_shared_mut_loop_pair]: loop 0: backward function 1 *)
  list_nth_shared_mut_loop_pair_loop_back
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (ListCons ret tl1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          tl10 <- list_nth_shared_mut_loop_pair_loop_back tl0 tl1 i0 ret;
          Return (ListCons x1 tl10)
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_shared_mut_loop_pair_back_def = Define ‘
  (** [loops::list_nth_shared_mut_loop_pair]: backward function 1 *)
  list_nth_shared_mut_loop_pair_back
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    list_nth_shared_mut_loop_pair_loop_back ls0 ls1 i ret
’

val [list_nth_shared_mut_loop_pair_merge_loop_fwd_def] = DefineDiv ‘
  (** [loops::list_nth_shared_mut_loop_pair_merge]: loop 0: forward function *)
  list_nth_shared_mut_loop_pair_merge_loop_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (x0, x1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          list_nth_shared_mut_loop_pair_merge_loop_fwd tl0 tl1 i0
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_shared_mut_loop_pair_merge_fwd_def = Define ‘
  (** [loops::list_nth_shared_mut_loop_pair_merge]: forward function *)
  list_nth_shared_mut_loop_pair_merge_fwd
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) : ('t # 't) result =
    list_nth_shared_mut_loop_pair_merge_loop_fwd ls0 ls1 i
’

val [list_nth_shared_mut_loop_pair_merge_loop_back_def] = DefineDiv ‘
  (** [loops::list_nth_shared_mut_loop_pair_merge]: loop 0: backward function 0 *)
  list_nth_shared_mut_loop_pair_merge_loop_back
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    (case ls0 of
    | ListCons x0 tl0 =>
      (case ls1 of
      | ListCons x1 tl1 =>
        if i = int_to_u32 0
        then Return (ListCons ret tl1)
        else (
          do
          i0 <- u32_sub i (int_to_u32 1);
          tl10 <- list_nth_shared_mut_loop_pair_merge_loop_back tl0 tl1 i0 ret;
          Return (ListCons x1 tl10)
          od)
      | ListNil => Fail Failure)
    | ListNil => Fail Failure)
’

val list_nth_shared_mut_loop_pair_merge_back_def = Define ‘
  (** [loops::list_nth_shared_mut_loop_pair_merge]: backward function 0 *)
  list_nth_shared_mut_loop_pair_merge_back
    (ls0 : 't list_t) (ls1 : 't list_t) (i : u32) (ret : 't) :
    't list_t result
    =
    list_nth_shared_mut_loop_pair_merge_loop_back ls0 ls1 i ret
’

val _ = export_theory ()
