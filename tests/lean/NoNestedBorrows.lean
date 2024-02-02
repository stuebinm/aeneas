-- THIS FILE WAS AUTOMATICALLY GENERATED BY AENEAS
-- [no_nested_borrows]
import Base
open Primitives

namespace no_nested_borrows

/- [no_nested_borrows::Pair]
   Source: 'src/no_nested_borrows.rs', lines 4:0-4:23 -/
structure Pair (T1 T2 : Type) where
  x : T1
  y : T2

/- [no_nested_borrows::List]
   Source: 'src/no_nested_borrows.rs', lines 9:0-9:16 -/
inductive List (T : Type) :=
| Cons : T → List T → List T
| Nil : List T

/- [no_nested_borrows::One]
   Source: 'src/no_nested_borrows.rs', lines 20:0-20:16 -/
inductive One (T1 : Type) :=
| One : T1 → One T1

/- [no_nested_borrows::EmptyEnum]
   Source: 'src/no_nested_borrows.rs', lines 26:0-26:18 -/
inductive EmptyEnum :=
| Empty : EmptyEnum

/- [no_nested_borrows::Enum]
   Source: 'src/no_nested_borrows.rs', lines 32:0-32:13 -/
inductive Enum :=
| Variant1 : Enum
| Variant2 : Enum

/- [no_nested_borrows::EmptyStruct]
   Source: 'src/no_nested_borrows.rs', lines 39:0-39:22 -/
@[reducible] def EmptyStruct := Unit

/- [no_nested_borrows::Sum]
   Source: 'src/no_nested_borrows.rs', lines 41:0-41:20 -/
inductive Sum (T1 T2 : Type) :=
| Left : T1 → Sum T1 T2
| Right : T2 → Sum T1 T2

/- [no_nested_borrows::neg_test]:
   Source: 'src/no_nested_borrows.rs', lines 48:0-48:30 -/
def neg_test (x : I32) : Result I32 :=
  - x

/- [no_nested_borrows::add_u32]:
   Source: 'src/no_nested_borrows.rs', lines 54:0-54:37 -/
def add_u32 (x : U32) (y : U32) : Result U32 :=
  x + y

/- [no_nested_borrows::subs_u32]:
   Source: 'src/no_nested_borrows.rs', lines 60:0-60:38 -/
def subs_u32 (x : U32) (y : U32) : Result U32 :=
  x - y

/- [no_nested_borrows::div_u32]:
   Source: 'src/no_nested_borrows.rs', lines 66:0-66:37 -/
def div_u32 (x : U32) (y : U32) : Result U32 :=
  x / y

/- [no_nested_borrows::div_u32_const]:
   Source: 'src/no_nested_borrows.rs', lines 73:0-73:35 -/
def div_u32_const (x : U32) : Result U32 :=
  x / 2#u32

/- [no_nested_borrows::rem_u32]:
   Source: 'src/no_nested_borrows.rs', lines 78:0-78:37 -/
def rem_u32 (x : U32) (y : U32) : Result U32 :=
  x % y

/- [no_nested_borrows::mul_u32]:
   Source: 'src/no_nested_borrows.rs', lines 82:0-82:37 -/
def mul_u32 (x : U32) (y : U32) : Result U32 :=
  x * y

/- [no_nested_borrows::add_i32]:
   Source: 'src/no_nested_borrows.rs', lines 88:0-88:37 -/
def add_i32 (x : I32) (y : I32) : Result I32 :=
  x + y

/- [no_nested_borrows::subs_i32]:
   Source: 'src/no_nested_borrows.rs', lines 92:0-92:38 -/
def subs_i32 (x : I32) (y : I32) : Result I32 :=
  x - y

/- [no_nested_borrows::div_i32]:
   Source: 'src/no_nested_borrows.rs', lines 96:0-96:37 -/
def div_i32 (x : I32) (y : I32) : Result I32 :=
  x / y

/- [no_nested_borrows::div_i32_const]:
   Source: 'src/no_nested_borrows.rs', lines 100:0-100:35 -/
def div_i32_const (x : I32) : Result I32 :=
  x / 2#i32

/- [no_nested_borrows::rem_i32]:
   Source: 'src/no_nested_borrows.rs', lines 104:0-104:37 -/
def rem_i32 (x : I32) (y : I32) : Result I32 :=
  x % y

/- [no_nested_borrows::mul_i32]:
   Source: 'src/no_nested_borrows.rs', lines 108:0-108:37 -/
def mul_i32 (x : I32) (y : I32) : Result I32 :=
  x * y

/- [no_nested_borrows::mix_arith_u32]:
   Source: 'src/no_nested_borrows.rs', lines 112:0-112:51 -/
def mix_arith_u32 (x : U32) (y : U32) (z : U32) : Result U32 :=
  do
  let i ← x + y
  let i1 ← x / y
  let i2 ← i * i1
  let i3 ← z % y
  let i4 ← x - i3
  let i5 ← i2 + i4
  let i6 ← x + y
  let i7 ← i6 + z
  i5 % i7

/- [no_nested_borrows::mix_arith_i32]:
   Source: 'src/no_nested_borrows.rs', lines 116:0-116:51 -/
def mix_arith_i32 (x : I32) (y : I32) (z : I32) : Result I32 :=
  do
  let i ← x + y
  let i1 ← x / y
  let i2 ← i * i1
  let i3 ← z % y
  let i4 ← x - i3
  let i5 ← i2 + i4
  let i6 ← x + y
  let i7 ← i6 + z
  i5 % i7

/- [no_nested_borrows::CONST0]
   Source: 'src/no_nested_borrows.rs', lines 125:0-125:23 -/
def const0_body : Result Usize := 1#usize + 1#usize
def const0_c : Usize := eval_global const0_body (by decide)

/- [no_nested_borrows::CONST1]
   Source: 'src/no_nested_borrows.rs', lines 126:0-126:23 -/
def const1_body : Result Usize := 2#usize * 2#usize
def const1_c : Usize := eval_global const1_body (by decide)

/- [no_nested_borrows::cast_u32_to_i32]:
   Source: 'src/no_nested_borrows.rs', lines 128:0-128:37 -/
def cast_u32_to_i32 (x : U32) : Result I32 :=
  Scalar.cast .I32 x

/- [no_nested_borrows::cast_bool_to_i32]:
   Source: 'src/no_nested_borrows.rs', lines 132:0-132:39 -/
def cast_bool_to_i32 (x : Bool) : Result I32 :=
  Scalar.cast_bool .I32 x

/- [no_nested_borrows::cast_bool_to_bool]:
   Source: 'src/no_nested_borrows.rs', lines 137:0-137:41 -/
def cast_bool_to_bool (x : Bool) : Result Bool :=
  Result.ret x

/- [no_nested_borrows::test2]:
   Source: 'src/no_nested_borrows.rs', lines 142:0-142:14 -/
def test2 : Result Unit :=
  do
  let _ ← 23#u32 + 44#u32
  Result.ret ()

/- Unit test for [no_nested_borrows::test2] -/
#assert (test2 == Result.ret ())

/- [no_nested_borrows::get_max]:
   Source: 'src/no_nested_borrows.rs', lines 154:0-154:37 -/
def get_max (x : U32) (y : U32) : Result U32 :=
  if x >= y
  then Result.ret x
  else Result.ret y

/- [no_nested_borrows::test3]:
   Source: 'src/no_nested_borrows.rs', lines 162:0-162:14 -/
def test3 : Result Unit :=
  do
  let x ← get_max 4#u32 3#u32
  let y ← get_max 10#u32 11#u32
  let z ← x + y
  if not (z = 15#u32)
  then Result.fail .panic
  else Result.ret ()

/- Unit test for [no_nested_borrows::test3] -/
#assert (test3 == Result.ret ())

/- [no_nested_borrows::test_neg1]:
   Source: 'src/no_nested_borrows.rs', lines 169:0-169:18 -/
def test_neg1 : Result Unit :=
  do
  let y ← - 3#i32
  if not (y = (-(3:Int))#i32)
  then Result.fail .panic
  else Result.ret ()

/- Unit test for [no_nested_borrows::test_neg1] -/
#assert (test_neg1 == Result.ret ())

/- [no_nested_borrows::refs_test1]:
   Source: 'src/no_nested_borrows.rs', lines 176:0-176:19 -/
def refs_test1 : Result Unit :=
  if not (1#i32 = 1#i32)
  then Result.fail .panic
  else Result.ret ()

/- Unit test for [no_nested_borrows::refs_test1] -/
#assert (refs_test1 == Result.ret ())

/- [no_nested_borrows::refs_test2]:
   Source: 'src/no_nested_borrows.rs', lines 187:0-187:19 -/
def refs_test2 : Result Unit :=
  if not (2#i32 = 2#i32)
  then Result.fail .panic
  else
    if not (0#i32 = 0#i32)
    then Result.fail .panic
    else
      if not (2#i32 = 2#i32)
      then Result.fail .panic
      else if not (2#i32 = 2#i32)
           then Result.fail .panic
           else Result.ret ()

/- Unit test for [no_nested_borrows::refs_test2] -/
#assert (refs_test2 == Result.ret ())

/- [no_nested_borrows::test_list1]:
   Source: 'src/no_nested_borrows.rs', lines 203:0-203:19 -/
def test_list1 : Result Unit :=
  Result.ret ()

/- Unit test for [no_nested_borrows::test_list1] -/
#assert (test_list1 == Result.ret ())

/- [no_nested_borrows::test_box1]:
   Source: 'src/no_nested_borrows.rs', lines 208:0-208:18 -/
def test_box1 : Result Unit :=
  do
  let (_, deref_mut_back) ← alloc.boxed.Box.deref_mut I32 0#i32
  let b ← deref_mut_back 1#i32
  let x ← alloc.boxed.Box.deref I32 b
  if not (x = 1#i32)
  then Result.fail .panic
  else Result.ret ()

/- Unit test for [no_nested_borrows::test_box1] -/
#assert (test_box1 == Result.ret ())

/- [no_nested_borrows::copy_int]:
   Source: 'src/no_nested_borrows.rs', lines 218:0-218:30 -/
def copy_int (x : I32) : Result I32 :=
  Result.ret x

/- [no_nested_borrows::test_unreachable]:
   Source: 'src/no_nested_borrows.rs', lines 224:0-224:32 -/
def test_unreachable (b : Bool) : Result Unit :=
  if b
  then Result.fail .panic
  else Result.ret ()

/- [no_nested_borrows::test_panic]:
   Source: 'src/no_nested_borrows.rs', lines 232:0-232:26 -/
def test_panic (b : Bool) : Result Unit :=
  if b
  then Result.fail .panic
  else Result.ret ()

/- [no_nested_borrows::test_copy_int]:
   Source: 'src/no_nested_borrows.rs', lines 239:0-239:22 -/
def test_copy_int : Result Unit :=
  do
  let y ← copy_int 0#i32
  if not (0#i32 = y)
  then Result.fail .panic
  else Result.ret ()

/- Unit test for [no_nested_borrows::test_copy_int] -/
#assert (test_copy_int == Result.ret ())

/- [no_nested_borrows::is_cons]:
   Source: 'src/no_nested_borrows.rs', lines 246:0-246:38 -/
def is_cons (T : Type) (l : List T) : Result Bool :=
  match l with
  | List.Cons _ _ => Result.ret true
  | List.Nil => Result.ret false

/- [no_nested_borrows::test_is_cons]:
   Source: 'src/no_nested_borrows.rs', lines 253:0-253:21 -/
def test_is_cons : Result Unit :=
  do
  let b ← is_cons I32 (List.Cons 0#i32 List.Nil)
  if not b
  then Result.fail .panic
  else Result.ret ()

/- Unit test for [no_nested_borrows::test_is_cons] -/
#assert (test_is_cons == Result.ret ())

/- [no_nested_borrows::split_list]:
   Source: 'src/no_nested_borrows.rs', lines 259:0-259:48 -/
def split_list (T : Type) (l : List T) : Result (T × (List T)) :=
  match l with
  | List.Cons hd tl => Result.ret (hd, tl)
  | List.Nil => Result.fail .panic

/- [no_nested_borrows::test_split_list]:
   Source: 'src/no_nested_borrows.rs', lines 267:0-267:24 -/
def test_split_list : Result Unit :=
  do
  let p ← split_list I32 (List.Cons 0#i32 List.Nil)
  let (hd, _) := p
  if not (hd = 0#i32)
  then Result.fail .panic
  else Result.ret ()

/- Unit test for [no_nested_borrows::test_split_list] -/
#assert (test_split_list == Result.ret ())

/- [no_nested_borrows::choose]:
   Source: 'src/no_nested_borrows.rs', lines 274:0-274:70 -/
def choose
  (T : Type) (b : Bool) (x : T) (y : T) :
  Result (T × (T → Result (T × T)))
  :=
  if b
  then let back_'a := fun ret => Result.ret (ret, y)
       Result.ret (x, back_'a)
  else let back_'a := fun ret => Result.ret (x, ret)
       Result.ret (y, back_'a)

/- [no_nested_borrows::choose_test]:
   Source: 'src/no_nested_borrows.rs', lines 282:0-282:20 -/
def choose_test : Result Unit :=
  do
  let (z, choose_back) ← choose I32 true 0#i32 0#i32
  let z1 ← z + 1#i32
  if not (z1 = 1#i32)
  then Result.fail .panic
  else
    do
    let (x, y) ← choose_back z1
    if not (x = 1#i32)
    then Result.fail .panic
    else if not (y = 0#i32)
         then Result.fail .panic
         else Result.ret ()

/- Unit test for [no_nested_borrows::choose_test] -/
#assert (choose_test == Result.ret ())

/- [no_nested_borrows::test_char]:
   Source: 'src/no_nested_borrows.rs', lines 294:0-294:26 -/
def test_char : Result Char :=
  Result.ret 'a'

mutual

/- [no_nested_borrows::Tree]
   Source: 'src/no_nested_borrows.rs', lines 299:0-299:16 -/
inductive Tree (T : Type) :=
| Leaf : T → Tree T
| Node : T → NodeElem T → Tree T → Tree T

/- [no_nested_borrows::NodeElem]
   Source: 'src/no_nested_borrows.rs', lines 304:0-304:20 -/
inductive NodeElem (T : Type) :=
| Cons : Tree T → NodeElem T → NodeElem T
| Nil : NodeElem T

end

/- [no_nested_borrows::list_length]:
   Source: 'src/no_nested_borrows.rs', lines 339:0-339:48 -/
divergent def list_length (T : Type) (l : List T) : Result U32 :=
  match l with
  | List.Cons _ l1 => do
                      let i ← list_length T l1
                      1#u32 + i
  | List.Nil => Result.ret 0#u32

/- [no_nested_borrows::list_nth_shared]:
   Source: 'src/no_nested_borrows.rs', lines 347:0-347:62 -/
divergent def list_nth_shared (T : Type) (l : List T) (i : U32) : Result T :=
  match l with
  | List.Cons x tl =>
    if i = 0#u32
    then Result.ret x
    else do
         let i1 ← i - 1#u32
         list_nth_shared T tl i1
  | List.Nil => Result.fail .panic

/- [no_nested_borrows::list_nth_mut]:
   Source: 'src/no_nested_borrows.rs', lines 363:0-363:67 -/
divergent def list_nth_mut
  (T : Type) (l : List T) (i : U32) : Result (T × (T → Result (List T))) :=
  match l with
  | List.Cons x tl =>
    if i = 0#u32
    then
      let back_'a := fun ret => Result.ret (List.Cons ret tl)
      Result.ret (x, back_'a)
    else
      do
      let i1 ← i - 1#u32
      let (t, list_nth_mut_back) ← list_nth_mut T tl i1
      let back_'a :=
        fun ret =>
          do
          let tl1 ← list_nth_mut_back ret
          Result.ret (List.Cons x tl1)
      Result.ret (t, back_'a)
  | List.Nil => Result.fail .panic

/- [no_nested_borrows::list_rev_aux]:
   Source: 'src/no_nested_borrows.rs', lines 379:0-379:63 -/
divergent def list_rev_aux
  (T : Type) (li : List T) (lo : List T) : Result (List T) :=
  match li with
  | List.Cons hd tl => list_rev_aux T tl (List.Cons hd lo)
  | List.Nil => Result.ret lo

/- [no_nested_borrows::list_rev]:
   Source: 'src/no_nested_borrows.rs', lines 393:0-393:42 -/
def list_rev (T : Type) (l : List T) : Result (List T) :=
  let (li, _) := core.mem.replace (List T) l List.Nil
  list_rev_aux T li List.Nil

/- [no_nested_borrows::test_list_functions]:
   Source: 'src/no_nested_borrows.rs', lines 398:0-398:28 -/
def test_list_functions : Result Unit :=
  do
  let l := List.Cons 2#i32 List.Nil
  let l1 := List.Cons 1#i32 l
  let i ← list_length I32 (List.Cons 0#i32 l1)
  if not (i = 3#u32)
  then Result.fail .panic
  else
    do
    let i1 ← list_nth_shared I32 (List.Cons 0#i32 l1) 0#u32
    if not (i1 = 0#i32)
    then Result.fail .panic
    else
      do
      let i2 ← list_nth_shared I32 (List.Cons 0#i32 l1) 1#u32
      if not (i2 = 1#i32)
      then Result.fail .panic
      else
        do
        let i3 ← list_nth_shared I32 (List.Cons 0#i32 l1) 2#u32
        if not (i3 = 2#i32)
        then Result.fail .panic
        else
          do
          let (_, list_nth_mut_back) ←
            list_nth_mut I32 (List.Cons 0#i32 l1) 1#u32
          let ls ← list_nth_mut_back 3#i32
          let i4 ← list_nth_shared I32 ls 0#u32
          if not (i4 = 0#i32)
          then Result.fail .panic
          else
            do
            let i5 ← list_nth_shared I32 ls 1#u32
            if not (i5 = 3#i32)
            then Result.fail .panic
            else
              do
              let i6 ← list_nth_shared I32 ls 2#u32
              if not (i6 = 2#i32)
              then Result.fail .panic
              else Result.ret ()

/- Unit test for [no_nested_borrows::test_list_functions] -/
#assert (test_list_functions == Result.ret ())

/- [no_nested_borrows::id_mut_pair1]:
   Source: 'src/no_nested_borrows.rs', lines 414:0-414:89 -/
def id_mut_pair1
  (T1 T2 : Type) (x : T1) (y : T2) :
  Result ((T1 × T2) × ((T1 × T2) → Result (T1 × T2)))
  :=
  let back_'a := fun ret => let (t, t1) := ret
                            Result.ret (t, t1)
  Result.ret ((x, y), back_'a)

/- [no_nested_borrows::id_mut_pair2]:
   Source: 'src/no_nested_borrows.rs', lines 418:0-418:88 -/
def id_mut_pair2
  (T1 T2 : Type) (p : (T1 × T2)) :
  Result ((T1 × T2) × ((T1 × T2) → Result (T1 × T2)))
  :=
  let (t, t1) := p
  let back_'a := fun ret => let (t2, t3) := ret
                            Result.ret (t2, t3)
  Result.ret ((t, t1), back_'a)

/- [no_nested_borrows::id_mut_pair3]:
   Source: 'src/no_nested_borrows.rs', lines 422:0-422:93 -/
def id_mut_pair3
  (T1 T2 : Type) (x : T1) (y : T2) :
  Result ((T1 × T2) × (T1 → Result T1) × (T2 → Result T2))
  :=
  Result.ret ((x, y), Result.ret, Result.ret)

/- [no_nested_borrows::id_mut_pair4]:
   Source: 'src/no_nested_borrows.rs', lines 426:0-426:92 -/
def id_mut_pair4
  (T1 T2 : Type) (p : (T1 × T2)) :
  Result ((T1 × T2) × (T1 → Result T1) × (T2 → Result T2))
  :=
  let (t, t1) := p
  Result.ret ((t, t1), Result.ret, Result.ret)

/- [no_nested_borrows::StructWithTuple]
   Source: 'src/no_nested_borrows.rs', lines 433:0-433:34 -/
structure StructWithTuple (T1 T2 : Type) where
  p : (T1 × T2)

/- [no_nested_borrows::new_tuple1]:
   Source: 'src/no_nested_borrows.rs', lines 437:0-437:48 -/
def new_tuple1 : Result (StructWithTuple U32 U32) :=
  Result.ret { p := (1#u32, 2#u32) }

/- [no_nested_borrows::new_tuple2]:
   Source: 'src/no_nested_borrows.rs', lines 441:0-441:48 -/
def new_tuple2 : Result (StructWithTuple I16 I16) :=
  Result.ret { p := (1#i16, 2#i16) }

/- [no_nested_borrows::new_tuple3]:
   Source: 'src/no_nested_borrows.rs', lines 445:0-445:48 -/
def new_tuple3 : Result (StructWithTuple U64 I64) :=
  Result.ret { p := (1#u64, 2#i64) }

/- [no_nested_borrows::StructWithPair]
   Source: 'src/no_nested_borrows.rs', lines 450:0-450:33 -/
structure StructWithPair (T1 T2 : Type) where
  p : Pair T1 T2

/- [no_nested_borrows::new_pair1]:
   Source: 'src/no_nested_borrows.rs', lines 454:0-454:46 -/
def new_pair1 : Result (StructWithPair U32 U32) :=
  Result.ret { p := { x := 1#u32, y := 2#u32 } }

/- [no_nested_borrows::test_constants]:
   Source: 'src/no_nested_borrows.rs', lines 462:0-462:23 -/
def test_constants : Result Unit :=
  do
  let swt ← new_tuple1
  let (i, _) := swt.p
  if not (i = 1#u32)
  then Result.fail .panic
  else
    do
    let swt1 ← new_tuple2
    let (i1, _) := swt1.p
    if not (i1 = 1#i16)
    then Result.fail .panic
    else
      do
      let swt2 ← new_tuple3
      let (i2, _) := swt2.p
      if not (i2 = 1#u64)
      then Result.fail .panic
      else
        do
        let swp ← new_pair1
        if not (swp.p.x = 1#u32)
        then Result.fail .panic
        else Result.ret ()

/- Unit test for [no_nested_borrows::test_constants] -/
#assert (test_constants == Result.ret ())

/- [no_nested_borrows::test_weird_borrows1]:
   Source: 'src/no_nested_borrows.rs', lines 471:0-471:28 -/
def test_weird_borrows1 : Result Unit :=
  Result.ret ()

/- Unit test for [no_nested_borrows::test_weird_borrows1] -/
#assert (test_weird_borrows1 == Result.ret ())

/- [no_nested_borrows::test_mem_replace]:
   Source: 'src/no_nested_borrows.rs', lines 481:0-481:37 -/
def test_mem_replace (px : U32) : Result U32 :=
  let (y, _) := core.mem.replace U32 px 1#u32
  if not (y = 0#u32)
  then Result.fail .panic
  else Result.ret 2#u32

/- [no_nested_borrows::test_shared_borrow_bool1]:
   Source: 'src/no_nested_borrows.rs', lines 488:0-488:47 -/
def test_shared_borrow_bool1 (b : Bool) : Result U32 :=
  if b
  then Result.ret 0#u32
  else Result.ret 1#u32

/- [no_nested_borrows::test_shared_borrow_bool2]:
   Source: 'src/no_nested_borrows.rs', lines 501:0-501:40 -/
def test_shared_borrow_bool2 : Result U32 :=
  Result.ret 0#u32

/- [no_nested_borrows::test_shared_borrow_enum1]:
   Source: 'src/no_nested_borrows.rs', lines 516:0-516:52 -/
def test_shared_borrow_enum1 (l : List U32) : Result U32 :=
  match l with
  | List.Cons _ _ => Result.ret 1#u32
  | List.Nil => Result.ret 0#u32

/- [no_nested_borrows::test_shared_borrow_enum2]:
   Source: 'src/no_nested_borrows.rs', lines 528:0-528:40 -/
def test_shared_borrow_enum2 : Result U32 :=
  Result.ret 0#u32

/- [no_nested_borrows::incr]:
   Source: 'src/no_nested_borrows.rs', lines 539:0-539:24 -/
def incr (x : U32) : Result U32 :=
  x + 1#u32

/- [no_nested_borrows::call_incr]:
   Source: 'src/no_nested_borrows.rs', lines 543:0-543:35 -/
def call_incr (x : U32) : Result U32 :=
  incr x

/- [no_nested_borrows::read_then_incr]:
   Source: 'src/no_nested_borrows.rs', lines 548:0-548:41 -/
def read_then_incr (x : U32) : Result (U32 × U32) :=
  do
  let x1 ← x + 1#u32
  Result.ret (x, x1)

/- [no_nested_borrows::Tuple]
   Source: 'src/no_nested_borrows.rs', lines 554:0-554:24 -/
def Tuple (T1 T2 : Type) := T1 × T2

/- [no_nested_borrows::use_tuple_struct]:
   Source: 'src/no_nested_borrows.rs', lines 556:0-556:48 -/
def use_tuple_struct (x : Tuple U32 U32) : Result (Tuple U32 U32) :=
  Result.ret (1#u32, x.1)

/- [no_nested_borrows::create_tuple_struct]:
   Source: 'src/no_nested_borrows.rs', lines 560:0-560:61 -/
def create_tuple_struct (x : U32) (y : U64) : Result (Tuple U32 U64) :=
  Result.ret (x, y)

/- [no_nested_borrows::IdType]
   Source: 'src/no_nested_borrows.rs', lines 565:0-565:20 -/
@[reducible] def IdType (T : Type) := T

/- [no_nested_borrows::use_id_type]:
   Source: 'src/no_nested_borrows.rs', lines 567:0-567:40 -/
def use_id_type (T : Type) (x : IdType T) : Result T :=
  Result.ret x

/- [no_nested_borrows::create_id_type]:
   Source: 'src/no_nested_borrows.rs', lines 571:0-571:43 -/
def create_id_type (T : Type) (x : T) : Result (IdType T) :=
  Result.ret x

end no_nested_borrows
