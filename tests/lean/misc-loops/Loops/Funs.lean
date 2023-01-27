-- THIS FILE WAS AUTOMATICALLY GENERATED BY AENEAS
-- [loops]: function definitions
import Base.Primitives
import Loops.Types
import Loops.Clauses.Clauses

/- [loops::sum] -/
def sum_loop_fwd (max : U32) (i : U32) (s : U32) : (Result U32) :=
  if h: i < max
  then
    do
      let s0 ← s + i
      let i0 ← i + (U32.ofInt 1 (by intlit))
      sum_loop_fwd max i0 s0
  else s * (U32.ofInt 2 (by intlit))
termination_by sum_loop_fwd max i s => sum_loop_terminates max i s
decreasing_by sum_loop_decreases max i s

/- [loops::sum] -/
def sum_fwd (max : U32) : Result U32 :=
  sum_loop_fwd max (U32.ofInt 0 (by intlit)) (U32.ofInt 0 (by intlit))

/- [loops::sum_with_mut_borrows] -/
def sum_with_mut_borrows_loop_fwd
  (max : U32) (mi : U32) (ms : U32) : (Result U32) :=
  if h: mi < max
  then
    do
      let ms0 ← ms + mi
      let mi0 ← mi + (U32.ofInt 1 (by intlit))
      sum_with_mut_borrows_loop_fwd max mi0 ms0
  else ms * (U32.ofInt 2 (by intlit))
termination_by sum_with_mut_borrows_loop_fwd max mi ms =>
  sum_with_mut_borrows_loop_terminates max mi ms
decreasing_by sum_with_mut_borrows_loop_decreases max mi ms

/- [loops::sum_with_mut_borrows] -/
def sum_with_mut_borrows_fwd (max : U32) : Result U32 :=
  sum_with_mut_borrows_loop_fwd max (U32.ofInt 0 (by intlit))
    (U32.ofInt 0 (by intlit))

/- [loops::sum_with_shared_borrows] -/
def sum_with_shared_borrows_loop_fwd
  (max : U32) (i : U32) (s : U32) : (Result U32) :=
  if h: i < max
  then
    do
      let i0 ← i + (U32.ofInt 1 (by intlit))
      let s0 ← s + i0
      sum_with_shared_borrows_loop_fwd max i0 s0
  else s * (U32.ofInt 2 (by intlit))
termination_by sum_with_shared_borrows_loop_fwd max i s =>
  sum_with_shared_borrows_loop_terminates max i s
decreasing_by sum_with_shared_borrows_loop_decreases max i s

/- [loops::sum_with_shared_borrows] -/
def sum_with_shared_borrows_fwd (max : U32) : Result U32 :=
  sum_with_shared_borrows_loop_fwd max (U32.ofInt 0 (by intlit))
    (U32.ofInt 0 (by intlit))

/- [loops::clear] -/
def clear_loop_fwd_back (v : Vec U32) (i : Usize) : (Result (Vec U32)) :=
  let i0 := vec_len U32 v
  if h: i < i0
  then
    do
      let i1 ← i + (Usize.ofInt 1 (by intlit))
      let v0 ← vec_index_mut_back U32 v i (U32.ofInt 0 (by intlit))
      clear_loop_fwd_back v0 i1
  else Result.ret v
termination_by clear_loop_fwd_back v i => clear_loop_terminates v i
decreasing_by clear_loop_decreases v i

/- [loops::clear] -/
def clear_fwd_back (v : Vec U32) : Result (Vec U32) :=
  clear_loop_fwd_back v (Usize.ofInt 0 (by intlit))

/- [loops::list_mem] -/
def list_mem_loop_fwd (x : U32) (ls : list_t U32) : (Result Bool) :=
  match h: ls with
  | list_t.Cons y tl =>
    if h: y = x
    then Result.ret true
    else list_mem_loop_fwd x tl
  | list_t.Nil => Result.ret false
termination_by list_mem_loop_fwd x ls => list_mem_loop_terminates x ls
decreasing_by list_mem_loop_decreases x ls

/- [loops::list_mem] -/
def list_mem_fwd (x : U32) (ls : list_t U32) : Result Bool :=
  list_mem_loop_fwd x ls

/- [loops::list_nth_mut_loop] -/
def list_nth_mut_loop_loop_fwd
  (T : Type) (ls : list_t T) (i : U32) : (Result T) :=
  match h: ls with
  | list_t.Cons x tl =>
    if h: i = (U32.ofInt 0 (by intlit))
    then Result.ret x
    else
      do
        let i0 ← i - (U32.ofInt 1 (by intlit))
        list_nth_mut_loop_loop_fwd T tl i0
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_loop_loop_fwd ls i =>
  list_nth_mut_loop_loop_terminates T ls i
decreasing_by list_nth_mut_loop_loop_decreases ls i

/- [loops::list_nth_mut_loop] -/
def list_nth_mut_loop_fwd (T : Type) (ls : list_t T) (i : U32) : Result T :=
  list_nth_mut_loop_loop_fwd T ls i

/- [loops::list_nth_mut_loop] -/
def list_nth_mut_loop_loop_back
  (T : Type) (ls : list_t T) (i : U32) (ret0 : T) : (Result (list_t T)) :=
  match h: ls with
  | list_t.Cons x tl =>
    if h: i = (U32.ofInt 0 (by intlit))
    then Result.ret (list_t.Cons ret0 tl)
    else
      do
        let i0 ← i - (U32.ofInt 1 (by intlit))
        let tl0 ← list_nth_mut_loop_loop_back T tl i0 ret0
        Result.ret (list_t.Cons x tl0)
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_loop_loop_back ls i ret0 =>
  list_nth_mut_loop_loop_terminates T ls i
decreasing_by list_nth_mut_loop_loop_decreases ls i

/- [loops::list_nth_mut_loop] -/
def list_nth_mut_loop_back
  (T : Type) (ls : list_t T) (i : U32) (ret0 : T) : Result (list_t T) :=
  list_nth_mut_loop_loop_back T ls i ret0

/- [loops::list_nth_shared_loop] -/
def list_nth_shared_loop_loop_fwd
  (T : Type) (ls : list_t T) (i : U32) : (Result T) :=
  match h: ls with
  | list_t.Cons x tl =>
    if h: i = (U32.ofInt 0 (by intlit))
    then Result.ret x
    else
      do
        let i0 ← i - (U32.ofInt 1 (by intlit))
        list_nth_shared_loop_loop_fwd T tl i0
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_shared_loop_loop_fwd ls i =>
  list_nth_shared_loop_loop_terminates T ls i
decreasing_by list_nth_shared_loop_loop_decreases ls i

/- [loops::list_nth_shared_loop] -/
def list_nth_shared_loop_fwd (T : Type) (ls : list_t T) (i : U32) : Result T :=
  list_nth_shared_loop_loop_fwd T ls i

/- [loops::get_elem_mut] -/
def get_elem_mut_loop_fwd (x : Usize) (ls : list_t Usize) : (Result Usize) :=
  match h: ls with
  | list_t.Cons y tl =>
    if h: y = x
    then Result.ret y
    else get_elem_mut_loop_fwd x tl
  | list_t.Nil => Result.fail Error.panic
termination_by get_elem_mut_loop_fwd x ls => get_elem_mut_loop_terminates x ls
decreasing_by get_elem_mut_loop_decreases x ls

/- [loops::get_elem_mut] -/
def get_elem_mut_fwd (slots : Vec (list_t Usize)) (x : Usize) : Result Usize :=
  do
    let l ←
      vec_index_mut_fwd (list_t Usize) slots (Usize.ofInt 0 (by intlit))
    get_elem_mut_loop_fwd x l

/- [loops::get_elem_mut] -/
def get_elem_mut_loop_back
  (x : Usize) (ls : list_t Usize) (ret0 : Usize) : (Result (list_t Usize)) :=
  match h: ls with
  | list_t.Cons y tl =>
    if h: y = x
    then Result.ret (list_t.Cons ret0 tl)
    else
      do
        let tl0 ← get_elem_mut_loop_back x tl ret0
        Result.ret (list_t.Cons y tl0)
  | list_t.Nil => Result.fail Error.panic
termination_by get_elem_mut_loop_back x ls ret0 =>
  get_elem_mut_loop_terminates x ls
decreasing_by get_elem_mut_loop_decreases x ls

/- [loops::get_elem_mut] -/
def get_elem_mut_back
  (slots : Vec (list_t Usize)) (x : Usize) (ret0 : Usize) :
  Result (Vec (list_t Usize))
  :=
  do
    let l ←
      vec_index_mut_fwd (list_t Usize) slots (Usize.ofInt 0 (by intlit))
    let l0 ← get_elem_mut_loop_back x l ret0
    vec_index_mut_back (list_t Usize) slots (Usize.ofInt 0 (by intlit)) l0

/- [loops::get_elem_shared] -/
def get_elem_shared_loop_fwd
  (x : Usize) (ls : list_t Usize) : (Result Usize) :=
  match h: ls with
  | list_t.Cons y tl =>
    if h: y = x
    then Result.ret y
    else get_elem_shared_loop_fwd x tl
  | list_t.Nil => Result.fail Error.panic
termination_by get_elem_shared_loop_fwd x ls =>
  get_elem_shared_loop_terminates x ls
decreasing_by get_elem_shared_loop_decreases x ls

/- [loops::get_elem_shared] -/
def get_elem_shared_fwd
  (slots : Vec (list_t Usize)) (x : Usize) : Result Usize :=
  do
    let l ← vec_index_fwd (list_t Usize) slots (Usize.ofInt 0 (by intlit))
    get_elem_shared_loop_fwd x l

/- [loops::id_mut] -/
def id_mut_fwd (T : Type) (ls : list_t T) : Result (list_t T) :=
  Result.ret ls

/- [loops::id_mut] -/
def id_mut_back
  (T : Type) (ls : list_t T) (ret0 : list_t T) : Result (list_t T) :=
  Result.ret ret0

/- [loops::id_shared] -/
def id_shared_fwd (T : Type) (ls : list_t T) : Result (list_t T) :=
  Result.ret ls

/- [loops::list_nth_mut_loop_with_id] -/
def list_nth_mut_loop_with_id_loop_fwd
  (T : Type) (i : U32) (ls : list_t T) : (Result T) :=
  match h: ls with
  | list_t.Cons x tl =>
    if h: i = (U32.ofInt 0 (by intlit))
    then Result.ret x
    else
      do
        let i0 ← i - (U32.ofInt 1 (by intlit))
        list_nth_mut_loop_with_id_loop_fwd T i0 tl
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_loop_with_id_loop_fwd i ls =>
  list_nth_mut_loop_with_id_loop_terminates T i ls
decreasing_by list_nth_mut_loop_with_id_loop_decreases i ls

/- [loops::list_nth_mut_loop_with_id] -/
def list_nth_mut_loop_with_id_fwd
  (T : Type) (ls : list_t T) (i : U32) : Result T :=
  do
    let ls0 ← id_mut_fwd T ls
    list_nth_mut_loop_with_id_loop_fwd T i ls0

/- [loops::list_nth_mut_loop_with_id] -/
def list_nth_mut_loop_with_id_loop_back
  (T : Type) (i : U32) (ls : list_t T) (ret0 : T) : (Result (list_t T)) :=
  match h: ls with
  | list_t.Cons x tl =>
    if h: i = (U32.ofInt 0 (by intlit))
    then Result.ret (list_t.Cons ret0 tl)
    else
      do
        let i0 ← i - (U32.ofInt 1 (by intlit))
        let tl0 ← list_nth_mut_loop_with_id_loop_back T i0 tl ret0
        Result.ret (list_t.Cons x tl0)
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_loop_with_id_loop_back i ls ret0 =>
  list_nth_mut_loop_with_id_loop_terminates T i ls
decreasing_by list_nth_mut_loop_with_id_loop_decreases i ls

/- [loops::list_nth_mut_loop_with_id] -/
def list_nth_mut_loop_with_id_back
  (T : Type) (ls : list_t T) (i : U32) (ret0 : T) : Result (list_t T) :=
  do
    let ls0 ← id_mut_fwd T ls
    let l ← list_nth_mut_loop_with_id_loop_back T i ls0 ret0
    id_mut_back T ls l

/- [loops::list_nth_shared_loop_with_id] -/
def list_nth_shared_loop_with_id_loop_fwd
  (T : Type) (i : U32) (ls : list_t T) : (Result T) :=
  match h: ls with
  | list_t.Cons x tl =>
    if h: i = (U32.ofInt 0 (by intlit))
    then Result.ret x
    else
      do
        let i0 ← i - (U32.ofInt 1 (by intlit))
        list_nth_shared_loop_with_id_loop_fwd T i0 tl
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_shared_loop_with_id_loop_fwd i ls =>
  list_nth_shared_loop_with_id_loop_terminates T i ls
decreasing_by list_nth_shared_loop_with_id_loop_decreases i ls

/- [loops::list_nth_shared_loop_with_id] -/
def list_nth_shared_loop_with_id_fwd
  (T : Type) (ls : list_t T) (i : U32) : Result T :=
  do
    let ls0 ← id_shared_fwd T ls
    list_nth_shared_loop_with_id_loop_fwd T i ls0

/- [loops::list_nth_mut_loop_pair] -/
def list_nth_mut_loop_pair_loop_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : (Result (T × T)) :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (x0, x1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          list_nth_mut_loop_pair_loop_fwd T tl0 tl1 i0
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_loop_pair_loop_fwd ls0 ls1 i =>
  list_nth_mut_loop_pair_loop_terminates T ls0 ls1 i
decreasing_by list_nth_mut_loop_pair_loop_decreases ls0 ls1 i

/- [loops::list_nth_mut_loop_pair] -/
def list_nth_mut_loop_pair_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : Result (T × T) :=
  list_nth_mut_loop_pair_loop_fwd T ls0 ls1 i

/- [loops::list_nth_mut_loop_pair] -/
def list_nth_mut_loop_pair_loop_back'a
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  (Result (list_t T))
  :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (list_t.Cons ret0 tl0)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          let tl00 ← list_nth_mut_loop_pair_loop_back'a T tl0 tl1 i0 ret0
          Result.ret (list_t.Cons x0 tl00)
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_loop_pair_loop_back'a ls0 ls1 i ret0 =>
  list_nth_mut_loop_pair_loop_terminates T ls0 ls1 i
decreasing_by list_nth_mut_loop_pair_loop_decreases ls0 ls1 i

/- [loops::list_nth_mut_loop_pair] -/
def list_nth_mut_loop_pair_back'a
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  Result (list_t T)
  :=
  list_nth_mut_loop_pair_loop_back'a T ls0 ls1 i ret0

/- [loops::list_nth_mut_loop_pair] -/
def list_nth_mut_loop_pair_loop_back'b
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  (Result (list_t T))
  :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (list_t.Cons ret0 tl1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          let tl10 ← list_nth_mut_loop_pair_loop_back'b T tl0 tl1 i0 ret0
          Result.ret (list_t.Cons x1 tl10)
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_loop_pair_loop_back'b ls0 ls1 i ret0 =>
  list_nth_mut_loop_pair_loop_terminates T ls0 ls1 i
decreasing_by list_nth_mut_loop_pair_loop_decreases ls0 ls1 i

/- [loops::list_nth_mut_loop_pair] -/
def list_nth_mut_loop_pair_back'b
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  Result (list_t T)
  :=
  list_nth_mut_loop_pair_loop_back'b T ls0 ls1 i ret0

/- [loops::list_nth_shared_loop_pair] -/
def list_nth_shared_loop_pair_loop_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : (Result (T × T)) :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (x0, x1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          list_nth_shared_loop_pair_loop_fwd T tl0 tl1 i0
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_shared_loop_pair_loop_fwd ls0 ls1 i =>
  list_nth_shared_loop_pair_loop_terminates T ls0 ls1 i
decreasing_by list_nth_shared_loop_pair_loop_decreases ls0 ls1 i

/- [loops::list_nth_shared_loop_pair] -/
def list_nth_shared_loop_pair_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : Result (T × T) :=
  list_nth_shared_loop_pair_loop_fwd T ls0 ls1 i

/- [loops::list_nth_mut_loop_pair_merge] -/
def list_nth_mut_loop_pair_merge_loop_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : (Result (T × T)) :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (x0, x1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          list_nth_mut_loop_pair_merge_loop_fwd T tl0 tl1 i0
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_loop_pair_merge_loop_fwd ls0 ls1 i =>
  list_nth_mut_loop_pair_merge_loop_terminates T ls0 ls1 i
decreasing_by list_nth_mut_loop_pair_merge_loop_decreases ls0 ls1 i

/- [loops::list_nth_mut_loop_pair_merge] -/
def list_nth_mut_loop_pair_merge_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : Result (T × T) :=
  list_nth_mut_loop_pair_merge_loop_fwd T ls0 ls1 i

/- [loops::list_nth_mut_loop_pair_merge] -/
def list_nth_mut_loop_pair_merge_loop_back
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : (T × T)) :
  (Result ((list_t T) × (list_t T)))
  :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then
        let (t, t0) := ret0
        Result.ret (list_t.Cons t tl0, list_t.Cons t0 tl1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          let (tl00, tl10) ←
            list_nth_mut_loop_pair_merge_loop_back T tl0 tl1 i0 ret0
          Result.ret (list_t.Cons x0 tl00, list_t.Cons x1 tl10)
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_loop_pair_merge_loop_back ls0 ls1 i ret0 =>
  list_nth_mut_loop_pair_merge_loop_terminates T ls0 ls1 i
decreasing_by list_nth_mut_loop_pair_merge_loop_decreases ls0 ls1 i

/- [loops::list_nth_mut_loop_pair_merge] -/
def list_nth_mut_loop_pair_merge_back
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : (T × T)) :
  Result ((list_t T) × (list_t T))
  :=
  list_nth_mut_loop_pair_merge_loop_back T ls0 ls1 i ret0

/- [loops::list_nth_shared_loop_pair_merge] -/
def list_nth_shared_loop_pair_merge_loop_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : (Result (T × T)) :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (x0, x1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          list_nth_shared_loop_pair_merge_loop_fwd T tl0 tl1 i0
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_shared_loop_pair_merge_loop_fwd ls0 ls1 i =>
  list_nth_shared_loop_pair_merge_loop_terminates T ls0 ls1 i
decreasing_by list_nth_shared_loop_pair_merge_loop_decreases ls0 ls1 i

/- [loops::list_nth_shared_loop_pair_merge] -/
def list_nth_shared_loop_pair_merge_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : Result (T × T) :=
  list_nth_shared_loop_pair_merge_loop_fwd T ls0 ls1 i

/- [loops::list_nth_mut_shared_loop_pair] -/
def list_nth_mut_shared_loop_pair_loop_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : (Result (T × T)) :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (x0, x1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          list_nth_mut_shared_loop_pair_loop_fwd T tl0 tl1 i0
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_shared_loop_pair_loop_fwd ls0 ls1 i =>
  list_nth_mut_shared_loop_pair_loop_terminates T ls0 ls1 i
decreasing_by list_nth_mut_shared_loop_pair_loop_decreases ls0 ls1 i

/- [loops::list_nth_mut_shared_loop_pair] -/
def list_nth_mut_shared_loop_pair_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : Result (T × T) :=
  list_nth_mut_shared_loop_pair_loop_fwd T ls0 ls1 i

/- [loops::list_nth_mut_shared_loop_pair] -/
def list_nth_mut_shared_loop_pair_loop_back
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  (Result (list_t T))
  :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (list_t.Cons ret0 tl0)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          let tl00 ←
            list_nth_mut_shared_loop_pair_loop_back T tl0 tl1 i0 ret0
          Result.ret (list_t.Cons x0 tl00)
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_shared_loop_pair_loop_back ls0 ls1 i ret0 =>
  list_nth_mut_shared_loop_pair_loop_terminates T ls0 ls1 i
decreasing_by list_nth_mut_shared_loop_pair_loop_decreases ls0 ls1 i

/- [loops::list_nth_mut_shared_loop_pair] -/
def list_nth_mut_shared_loop_pair_back
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  Result (list_t T)
  :=
  list_nth_mut_shared_loop_pair_loop_back T ls0 ls1 i ret0

/- [loops::list_nth_mut_shared_loop_pair_merge] -/
def list_nth_mut_shared_loop_pair_merge_loop_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : (Result (T × T)) :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (x0, x1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          list_nth_mut_shared_loop_pair_merge_loop_fwd T tl0 tl1 i0
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_shared_loop_pair_merge_loop_fwd ls0 ls1 i =>
  list_nth_mut_shared_loop_pair_merge_loop_terminates T ls0 ls1 i
decreasing_by list_nth_mut_shared_loop_pair_merge_loop_decreases ls0 ls1 i

/- [loops::list_nth_mut_shared_loop_pair_merge] -/
def list_nth_mut_shared_loop_pair_merge_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : Result (T × T) :=
  list_nth_mut_shared_loop_pair_merge_loop_fwd T ls0 ls1 i

/- [loops::list_nth_mut_shared_loop_pair_merge] -/
def list_nth_mut_shared_loop_pair_merge_loop_back
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  (Result (list_t T))
  :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (list_t.Cons ret0 tl0)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          let tl00 ←
            list_nth_mut_shared_loop_pair_merge_loop_back T tl0 tl1 i0 ret0
          Result.ret (list_t.Cons x0 tl00)
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_mut_shared_loop_pair_merge_loop_back ls0 ls1 i ret0 =>
  list_nth_mut_shared_loop_pair_merge_loop_terminates T ls0 ls1 i
decreasing_by list_nth_mut_shared_loop_pair_merge_loop_decreases ls0 ls1 i

/- [loops::list_nth_mut_shared_loop_pair_merge] -/
def list_nth_mut_shared_loop_pair_merge_back
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  Result (list_t T)
  :=
  list_nth_mut_shared_loop_pair_merge_loop_back T ls0 ls1 i ret0

/- [loops::list_nth_shared_mut_loop_pair] -/
def list_nth_shared_mut_loop_pair_loop_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : (Result (T × T)) :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (x0, x1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          list_nth_shared_mut_loop_pair_loop_fwd T tl0 tl1 i0
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_shared_mut_loop_pair_loop_fwd ls0 ls1 i =>
  list_nth_shared_mut_loop_pair_loop_terminates T ls0 ls1 i
decreasing_by list_nth_shared_mut_loop_pair_loop_decreases ls0 ls1 i

/- [loops::list_nth_shared_mut_loop_pair] -/
def list_nth_shared_mut_loop_pair_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : Result (T × T) :=
  list_nth_shared_mut_loop_pair_loop_fwd T ls0 ls1 i

/- [loops::list_nth_shared_mut_loop_pair] -/
def list_nth_shared_mut_loop_pair_loop_back
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  (Result (list_t T))
  :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (list_t.Cons ret0 tl1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          let tl10 ←
            list_nth_shared_mut_loop_pair_loop_back T tl0 tl1 i0 ret0
          Result.ret (list_t.Cons x1 tl10)
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_shared_mut_loop_pair_loop_back ls0 ls1 i ret0 =>
  list_nth_shared_mut_loop_pair_loop_terminates T ls0 ls1 i
decreasing_by list_nth_shared_mut_loop_pair_loop_decreases ls0 ls1 i

/- [loops::list_nth_shared_mut_loop_pair] -/
def list_nth_shared_mut_loop_pair_back
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  Result (list_t T)
  :=
  list_nth_shared_mut_loop_pair_loop_back T ls0 ls1 i ret0

/- [loops::list_nth_shared_mut_loop_pair_merge] -/
def list_nth_shared_mut_loop_pair_merge_loop_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : (Result (T × T)) :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (x0, x1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          list_nth_shared_mut_loop_pair_merge_loop_fwd T tl0 tl1 i0
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_shared_mut_loop_pair_merge_loop_fwd ls0 ls1 i =>
  list_nth_shared_mut_loop_pair_merge_loop_terminates T ls0 ls1 i
decreasing_by list_nth_shared_mut_loop_pair_merge_loop_decreases ls0 ls1 i

/- [loops::list_nth_shared_mut_loop_pair_merge] -/
def list_nth_shared_mut_loop_pair_merge_fwd
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) : Result (T × T) :=
  list_nth_shared_mut_loop_pair_merge_loop_fwd T ls0 ls1 i

/- [loops::list_nth_shared_mut_loop_pair_merge] -/
def list_nth_shared_mut_loop_pair_merge_loop_back
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  (Result (list_t T))
  :=
  match h: ls0 with
  | list_t.Cons x0 tl0 =>
    match h: ls1 with
    | list_t.Cons x1 tl1 =>
      if h: i = (U32.ofInt 0 (by intlit))
      then Result.ret (list_t.Cons ret0 tl1)
      else
        do
          let i0 ← i - (U32.ofInt 1 (by intlit))
          let tl10 ←
            list_nth_shared_mut_loop_pair_merge_loop_back T tl0 tl1 i0 ret0
          Result.ret (list_t.Cons x1 tl10)
    | list_t.Nil => Result.fail Error.panic
  | list_t.Nil => Result.fail Error.panic
termination_by list_nth_shared_mut_loop_pair_merge_loop_back ls0 ls1 i ret0 =>
  list_nth_shared_mut_loop_pair_merge_loop_terminates T ls0 ls1 i
decreasing_by list_nth_shared_mut_loop_pair_merge_loop_decreases ls0 ls1 i

/- [loops::list_nth_shared_mut_loop_pair_merge] -/
def list_nth_shared_mut_loop_pair_merge_back
  (T : Type) (ls0 : list_t T) (ls1 : list_t T) (i : U32) (ret0 : T) :
  Result (list_t T)
  :=
  list_nth_shared_mut_loop_pair_merge_loop_back T ls0 ls1 i ret0
