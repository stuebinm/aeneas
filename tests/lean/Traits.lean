-- THIS FILE WAS AUTOMATICALLY GENERATED BY AENEAS
-- [traits]
import Base
open Primitives

namespace traits

/- Trait declaration: [traits::BoolTrait]
   Source: 'src/traits.rs', lines 1:0-1:19 -/
structure BoolTrait (Self : Type) where
  get_bool : Self → Result Bool

/- [traits::{bool}::get_bool]:
   Source: 'src/traits.rs', lines 12:4-12:30 -/
def Bool.get_bool (self : Bool) : Result Bool :=
  Result.ret self

/- Trait implementation: [traits::{bool}]
   Source: 'src/traits.rs', lines 11:0-11:23 -/
def traits.BoolTraitBoolInst : BoolTrait Bool := {
  get_bool := Bool.get_bool
}

/- [traits::BoolTrait::ret_true]:
   Source: 'src/traits.rs', lines 6:4-6:30 -/
def BoolTrait.ret_true
  {Self : Type} (self_clause : BoolTrait Self) (self : Self) : Result Bool :=
  Result.ret true

/- [traits::test_bool_trait_bool]:
   Source: 'src/traits.rs', lines 17:0-17:44 -/
def test_bool_trait_bool (x : Bool) : Result Bool :=
  do
  let b ← Bool.get_bool x
  if b
  then BoolTrait.ret_true traits.BoolTraitBoolInst x
  else Result.ret false

/- [traits::{core::option::Option<T>#1}::get_bool]:
   Source: 'src/traits.rs', lines 23:4-23:30 -/
def Option.get_bool (T : Type) (self : Option T) : Result Bool :=
  match self with
  | none => Result.ret false
  | some _ => Result.ret true

/- Trait implementation: [traits::{core::option::Option<T>#1}]
   Source: 'src/traits.rs', lines 22:0-22:31 -/
def traits.BoolTraitcoreoptionOptionTInst (T : Type) : BoolTrait (Option T)
  := {
  get_bool := Option.get_bool T
}

/- [traits::test_bool_trait_option]:
   Source: 'src/traits.rs', lines 31:0-31:54 -/
def test_bool_trait_option (T : Type) (x : Option T) : Result Bool :=
  do
  let b ← Option.get_bool T x
  if b
  then BoolTrait.ret_true (traits.BoolTraitcoreoptionOptionTInst T) x
  else Result.ret false

/- [traits::test_bool_trait]:
   Source: 'src/traits.rs', lines 35:0-35:50 -/
def test_bool_trait
  (T : Type) (BoolTraitTInst : BoolTrait T) (x : T) : Result Bool :=
  BoolTraitTInst.get_bool x

/- Trait declaration: [traits::ToU64]
   Source: 'src/traits.rs', lines 39:0-39:15 -/
structure ToU64 (Self : Type) where
  to_u64 : Self → Result U64

/- [traits::{u64#2}::to_u64]:
   Source: 'src/traits.rs', lines 44:4-44:26 -/
def U64.to_u64 (self : U64) : Result U64 :=
  Result.ret self

/- Trait implementation: [traits::{u64#2}]
   Source: 'src/traits.rs', lines 43:0-43:18 -/
def traits.ToU64U64Inst : ToU64 U64 := {
  to_u64 := U64.to_u64
}

/- [traits::{(A, A)#3}::to_u64]:
   Source: 'src/traits.rs', lines 50:4-50:26 -/
def Pair.to_u64
  (A : Type) (ToU64AInst : ToU64 A) (self : (A × A)) : Result U64 :=
  do
  let (t, t1) := self
  let i ← ToU64AInst.to_u64 t
  let i1 ← ToU64AInst.to_u64 t1
  i + i1

/- Trait implementation: [traits::{(A, A)#3}]
   Source: 'src/traits.rs', lines 49:0-49:31 -/
def traits.ToU64TupleAAInst (A : Type) (ToU64AInst : ToU64 A) : ToU64 (A × A)
  := {
  to_u64 := Pair.to_u64 A ToU64AInst
}

/- [traits::f]:
   Source: 'src/traits.rs', lines 55:0-55:36 -/
def f (T : Type) (ToU64TInst : ToU64 T) (x : (T × T)) : Result U64 :=
  Pair.to_u64 T ToU64TInst x

/- [traits::g]:
   Source: 'src/traits.rs', lines 59:0-61:18 -/
def g
  (T : Type) (ToU64TupleTTInst : ToU64 (T × T)) (x : (T × T)) : Result U64 :=
  ToU64TupleTTInst.to_u64 x

/- [traits::h0]:
   Source: 'src/traits.rs', lines 66:0-66:24 -/
def h0 (x : U64) : Result U64 :=
  U64.to_u64 x

/- [traits::Wrapper]
   Source: 'src/traits.rs', lines 70:0-70:21 -/
structure Wrapper (T : Type) where
  x : T

/- [traits::{traits::Wrapper<T>#4}::to_u64]:
   Source: 'src/traits.rs', lines 75:4-75:26 -/
def Wrapper.to_u64
  (T : Type) (ToU64TInst : ToU64 T) (self : Wrapper T) : Result U64 :=
  ToU64TInst.to_u64 self.x

/- Trait implementation: [traits::{traits::Wrapper<T>#4}]
   Source: 'src/traits.rs', lines 74:0-74:35 -/
def traits.ToU64traitsWrapperTInst (T : Type) (ToU64TInst : ToU64 T) : ToU64
  (Wrapper T) := {
  to_u64 := Wrapper.to_u64 T ToU64TInst
}

/- [traits::h1]:
   Source: 'src/traits.rs', lines 80:0-80:33 -/
def h1 (x : Wrapper U64) : Result U64 :=
  Wrapper.to_u64 U64 traits.ToU64U64Inst x

/- [traits::h2]:
   Source: 'src/traits.rs', lines 84:0-84:41 -/
def h2 (T : Type) (ToU64TInst : ToU64 T) (x : Wrapper T) : Result U64 :=
  Wrapper.to_u64 T ToU64TInst x

/- Trait declaration: [traits::ToType]
   Source: 'src/traits.rs', lines 88:0-88:19 -/
structure ToType (Self T : Type) where
  to_type : Self → Result T

/- [traits::{u64#5}::to_type]:
   Source: 'src/traits.rs', lines 93:4-93:28 -/
def U64.to_type (self : U64) : Result Bool :=
  Result.ret (self > 0#u64)

/- Trait implementation: [traits::{u64#5}]
   Source: 'src/traits.rs', lines 92:0-92:25 -/
def traits.ToTypeU64BoolInst : ToType U64 Bool := {
  to_type := U64.to_type
}

/- Trait declaration: [traits::OfType]
   Source: 'src/traits.rs', lines 98:0-98:16 -/
structure OfType (Self : Type) where
  of_type : forall (T : Type) (ToTypeTSelfInst : ToType T Self), T → Result
    Self

/- [traits::h3]:
   Source: 'src/traits.rs', lines 104:0-104:50 -/
def h3
  (T1 T2 : Type) (OfTypeT1Inst : OfType T1) (ToTypeT2T1Inst : ToType T2 T1)
  (y : T2) :
  Result T1
  :=
  OfTypeT1Inst.of_type T2 ToTypeT2T1Inst y

/- Trait declaration: [traits::OfTypeBis]
   Source: 'src/traits.rs', lines 109:0-109:36 -/
structure OfTypeBis (Self T : Type) where
  ToTypeTSelfInst : ToType T Self
  of_type : T → Result Self

/- [traits::h4]:
   Source: 'src/traits.rs', lines 118:0-118:57 -/
def h4
  (T1 T2 : Type) (OfTypeBisT1T2Inst : OfTypeBis T1 T2) (ToTypeT2T1Inst : ToType
  T2 T1) (y : T2) :
  Result T1
  :=
  OfTypeBisT1T2Inst.of_type y

/- [traits::TestType]
   Source: 'src/traits.rs', lines 122:0-122:22 -/
@[reducible] def TestType (T : Type) := T

/- [traits::{traits::TestType<T>#6}::test::TestType1]
   Source: 'src/traits.rs', lines 127:8-127:24 -/
@[reducible] def TestType.test.TestType1 := U64

/- Trait declaration: [traits::{traits::TestType<T>#6}::test::TestTrait]
   Source: 'src/traits.rs', lines 128:8-128:23 -/
structure TestType.test.TestTrait (Self : Type) where
  test : Self → Result Bool

/- [traits::{traits::TestType<T>#6}::test::{traits::{traits::TestType<T>#6}::test::TestType1}::test]:
   Source: 'src/traits.rs', lines 139:12-139:34 -/
def TestType.test.TestType1.test
  (self : TestType.test.TestType1) : Result Bool :=
  Result.ret (self > 1#u64)

/- Trait implementation: [traits::{traits::TestType<T>#6}::test::{traits::{traits::TestType<T>#6}::test::TestType1}]
   Source: 'src/traits.rs', lines 138:8-138:36 -/
def traits.TestType.test.TestTraittraitstraitsTestTypeTtestTestType1Inst :
  TestType.test.TestTrait TestType.test.TestType1 := {
  test := TestType.test.TestType1.test
}

/- [traits::{traits::TestType<T>#6}::test]:
   Source: 'src/traits.rs', lines 126:4-126:36 -/
def TestType.test
  (T : Type) (ToU64TInst : ToU64 T) (self : TestType T) (x : T) :
  Result Bool
  :=
  do
  let x1 ← ToU64TInst.to_u64 x
  if x1 > 0#u64
  then TestType.test.TestType1.test 0#u64
  else Result.ret false

/- [traits::BoolWrapper]
   Source: 'src/traits.rs', lines 150:0-150:22 -/
@[reducible] def BoolWrapper := Bool

/- [traits::{traits::BoolWrapper#7}::to_type]:
   Source: 'src/traits.rs', lines 156:4-156:25 -/
def BoolWrapper.to_type
  (T : Type) (ToTypeBoolTInst : ToType Bool T) (self : BoolWrapper) :
  Result T
  :=
  ToTypeBoolTInst.to_type self

/- Trait implementation: [traits::{traits::BoolWrapper#7}]
   Source: 'src/traits.rs', lines 152:0-152:33 -/
def traits.ToTypetraitsBoolWrapperTInst (T : Type) (ToTypeBoolTInst : ToType
  Bool T) : ToType BoolWrapper T := {
  to_type := BoolWrapper.to_type T ToTypeBoolTInst
}

/- [traits::WithConstTy::LEN2]
   Source: 'src/traits.rs', lines 164:4-164:21 -/
def with_const_ty_len2_body : Result Usize := Result.ret 32#usize
def with_const_ty_len2_c : Usize := eval_global with_const_ty_len2_body

/- Trait declaration: [traits::WithConstTy]
   Source: 'src/traits.rs', lines 161:0-161:39 -/
structure WithConstTy (Self : Type) (LEN : Usize) where
  LEN1 : Usize
  LEN2 : Usize
  V : Type
  W : Type
  W_clause_0 : ToU64 W
  f : W → Array U8 LEN → Result W

/- [traits::{bool#8}::LEN1]
   Source: 'src/traits.rs', lines 175:4-175:21 -/
def bool_len1_body : Result Usize := Result.ret 12#usize
def bool_len1_c : Usize := eval_global bool_len1_body

/- [traits::{bool#8}::f]:
   Source: 'src/traits.rs', lines 180:4-180:39 -/
def Bool.f (i : U64) (a : Array U8 32#usize) : Result U64 :=
  Result.ret i

/- Trait implementation: [traits::{bool#8}]
   Source: 'src/traits.rs', lines 174:0-174:29 -/
def traits.WithConstTyBool32Inst : WithConstTy Bool 32#usize := {
  LEN1 := bool_len1_c
  LEN2 := with_const_ty_len2_c
  V := U8
  W := U64
  W_clause_0 := traits.ToU64U64Inst
  f := Bool.f
}

/- [traits::use_with_const_ty1]:
   Source: 'src/traits.rs', lines 183:0-183:75 -/
def use_with_const_ty1
  (H : Type) (LEN : Usize) (WithConstTyHLENInst : WithConstTy H LEN) :
  Result Usize
  :=
  Result.ret WithConstTyHLENInst.LEN1

/- [traits::use_with_const_ty2]:
   Source: 'src/traits.rs', lines 187:0-187:73 -/
def use_with_const_ty2
  (H : Type) (LEN : Usize) (WithConstTyHLENInst : WithConstTy H LEN)
  (w : WithConstTyHLENInst.W) :
  Result Unit
  :=
  Result.ret ()

/- [traits::use_with_const_ty3]:
   Source: 'src/traits.rs', lines 189:0-189:80 -/
def use_with_const_ty3
  (H : Type) (LEN : Usize) (WithConstTyHLENInst : WithConstTy H LEN)
  (x : WithConstTyHLENInst.W) :
  Result U64
  :=
  WithConstTyHLENInst.W_clause_0.to_u64 x

/- [traits::test_where1]:
   Source: 'src/traits.rs', lines 193:0-193:40 -/
def test_where1 (T : Type) (_x : T) : Result Unit :=
  Result.ret ()

/- [traits::test_where2]:
   Source: 'src/traits.rs', lines 194:0-194:57 -/
def test_where2
  (T : Type) (WithConstTyT32Inst : WithConstTy T 32#usize) (_x : U32) :
  Result Unit
  :=
  Result.ret ()

/- Trait declaration: [traits::ParentTrait0]
   Source: 'src/traits.rs', lines 200:0-200:22 -/
structure ParentTrait0 (Self : Type) where
  W : Type
  get_name : Self → Result String
  get_w : Self → Result W

/- Trait declaration: [traits::ParentTrait1]
   Source: 'src/traits.rs', lines 205:0-205:22 -/
structure ParentTrait1 (Self : Type) where

/- Trait declaration: [traits::ChildTrait]
   Source: 'src/traits.rs', lines 206:0-206:49 -/
structure ChildTrait (Self : Type) where
  ParentTrait0SelfInst : ParentTrait0 Self
  ParentTrait1SelfInst : ParentTrait1 Self

/- [traits::test_child_trait1]:
   Source: 'src/traits.rs', lines 209:0-209:56 -/
def test_child_trait1
  (T : Type) (ChildTraitTInst : ChildTrait T) (x : T) : Result String :=
  ChildTraitTInst.ParentTrait0SelfInst.get_name x

/- [traits::test_child_trait2]:
   Source: 'src/traits.rs', lines 213:0-213:54 -/
def test_child_trait2
  (T : Type) (ChildTraitTInst : ChildTrait T) (x : T) :
  Result ChildTraitTInst.ParentTrait0SelfInst.W
  :=
  ChildTraitTInst.ParentTrait0SelfInst.get_w x

/- [traits::order1]:
   Source: 'src/traits.rs', lines 219:0-219:59 -/
def order1
  (T U : Type) (ParentTrait0TInst : ParentTrait0 T) (ParentTrait0UInst :
  ParentTrait0 U) :
  Result Unit
  :=
  Result.ret ()

/- Trait declaration: [traits::ChildTrait1]
   Source: 'src/traits.rs', lines 222:0-222:35 -/
structure ChildTrait1 (Self : Type) where
  ParentTrait1SelfInst : ParentTrait1 Self

/- Trait implementation: [traits::{usize#9}]
   Source: 'src/traits.rs', lines 224:0-224:27 -/
def traits.ParentTrait1UsizeInst : ParentTrait1 Usize := {
}

/- Trait implementation: [traits::{usize#10}]
   Source: 'src/traits.rs', lines 225:0-225:26 -/
def traits.ChildTrait1UsizeInst : ChildTrait1 Usize := {
  ParentTrait1SelfInst := traits.ParentTrait1UsizeInst
}

/- Trait declaration: [traits::Iterator]
   Source: 'src/traits.rs', lines 229:0-229:18 -/
structure Iterator (Self : Type) where
  Item : Type

/- Trait declaration: [traits::IntoIterator]
   Source: 'src/traits.rs', lines 233:0-233:22 -/
structure IntoIterator (Self : Type) where
  Item : Type
  IntoIter : Type
  IntoIter_clause_0 : Iterator IntoIter
  into_iter : Self → Result IntoIter

/- Trait declaration: [traits::FromResidual]
   Source: 'src/traits.rs', lines 250:0-250:21 -/
structure FromResidual (Self T : Type) where

/- Trait declaration: [traits::Try]
   Source: 'src/traits.rs', lines 246:0-246:48 -/
structure Try (Self : Type) where
  Residual : Type
  FromResidualSelftraitsTrySelfResidualInst : FromResidual Self Residual

/- Trait declaration: [traits::WithTarget]
   Source: 'src/traits.rs', lines 252:0-252:20 -/
structure WithTarget (Self : Type) where
  Target : Type

/- Trait declaration: [traits::ParentTrait2]
   Source: 'src/traits.rs', lines 256:0-256:22 -/
structure ParentTrait2 (Self : Type) where
  U : Type
  U_clause_0 : WithTarget U

/- Trait declaration: [traits::ChildTrait2]
   Source: 'src/traits.rs', lines 260:0-260:35 -/
structure ChildTrait2 (Self : Type) where
  ParentTrait2SelfInst : ParentTrait2 Self
  convert : ParentTrait2SelfInst.U → Result
    ParentTrait2SelfInst.U_clause_0.Target

/- Trait implementation: [traits::{u32#11}]
   Source: 'src/traits.rs', lines 264:0-264:23 -/
def traits.WithTargetU32Inst : WithTarget U32 := {
  Target := U32
}

/- Trait implementation: [traits::{u32#12}]
   Source: 'src/traits.rs', lines 268:0-268:25 -/
def traits.ParentTrait2U32Inst : ParentTrait2 U32 := {
  U := U32
  U_clause_0 := traits.WithTargetU32Inst
}

/- [traits::{u32#13}::convert]:
   Source: 'src/traits.rs', lines 273:4-273:29 -/
def U32.convert (x : U32) : Result U32 :=
  Result.ret x

/- Trait implementation: [traits::{u32#13}]
   Source: 'src/traits.rs', lines 272:0-272:24 -/
def traits.ChildTrait2U32Inst : ChildTrait2 U32 := {
  ParentTrait2SelfInst := traits.ParentTrait2U32Inst
  convert := U32.convert
}

/- Trait declaration: [traits::CFnOnce]
   Source: 'src/traits.rs', lines 286:0-286:23 -/
structure CFnOnce (Self Args : Type) where
  Output : Type
  call_once : Self → Args → Result Output

/- Trait declaration: [traits::CFnMut]
   Source: 'src/traits.rs', lines 292:0-292:37 -/
structure CFnMut (Self Args : Type) where
  CFnOnceSelfArgsInst : CFnOnce Self Args
  call_mut : Self → Args → Result (CFnOnceSelfArgsInst.Output × Self)

/- Trait declaration: [traits::CFn]
   Source: 'src/traits.rs', lines 296:0-296:33 -/
structure CFn (Self Args : Type) where
  CFnMutSelfArgsInst : CFnMut Self Args
  call : Self → Args → Result CFnMutSelfArgsInst.CFnOnceSelfArgsInst.Output

/- Trait declaration: [traits::GetTrait]
   Source: 'src/traits.rs', lines 300:0-300:18 -/
structure GetTrait (Self : Type) where
  W : Type
  get_w : Self → Result W

/- [traits::test_get_trait]:
   Source: 'src/traits.rs', lines 305:0-305:49 -/
def test_get_trait
  (T : Type) (GetTraitTInst : GetTrait T) (x : T) : Result GetTraitTInst.W :=
  GetTraitTInst.get_w x

end traits
