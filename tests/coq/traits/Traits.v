(** THIS FILE WAS AUTOMATICALLY GENERATED BY AENEAS *)
(** [traits] *)
Require Import Primitives.
Import Primitives.
Require Import Coq.ZArith.ZArith.
Require Import List.
Import ListNotations.
Local Open Scope Primitives_scope.
Module Traits.

(** Trait declaration: [traits::BoolTrait]
    Source: 'src/traits.rs', lines 1:0-1:19 *)
Record BoolTrait_t (Self : Type) := mkBoolTrait_t {
  BoolTrait_t_get_bool : Self -> result bool;
}.

Arguments mkBoolTrait_t { _ }.
Arguments BoolTrait_t_get_bool { _ }.

(** [traits::{(traits::BoolTrait for bool)}::get_bool]:
    Source: 'src/traits.rs', lines 12:4-12:30 *)
Definition boolTraitBool_get_bool (self : bool) : result bool :=
  Ok self.

(** Trait implementation: [traits::{(traits::BoolTrait for bool)}]
    Source: 'src/traits.rs', lines 11:0-11:23 *)
Definition BoolTraitBool : BoolTrait_t bool := {|
  BoolTrait_t_get_bool := boolTraitBool_get_bool;
|}.

(** [traits::BoolTrait::ret_true]:
    Source: 'src/traits.rs', lines 6:4-6:30 *)
Definition boolTrait_ret_true
  {Self : Type} (self_clause : BoolTrait_t Self) (self : Self) : result bool :=
  Ok true
.

(** [traits::test_bool_trait_bool]:
    Source: 'src/traits.rs', lines 17:0-17:44 *)
Definition test_bool_trait_bool (x : bool) : result bool :=
  b <- boolTraitBool_get_bool x;
  if b then boolTrait_ret_true BoolTraitBool x else Ok false
.

(** [traits::{(traits::BoolTrait for core::option::Option<T>)#1}::get_bool]:
    Source: 'src/traits.rs', lines 23:4-23:30 *)
Definition boolTraitOption_get_bool
  (T : Type) (self : option T) : result bool :=
  match self with | None => Ok false | Some _ => Ok true end
.

(** Trait implementation: [traits::{(traits::BoolTrait for core::option::Option<T>)#1}]
    Source: 'src/traits.rs', lines 22:0-22:31 *)
Definition BoolTraitOption (T : Type) : BoolTrait_t (option T) := {|
  BoolTrait_t_get_bool := boolTraitOption_get_bool T;
|}.

(** [traits::test_bool_trait_option]:
    Source: 'src/traits.rs', lines 31:0-31:54 *)
Definition test_bool_trait_option (T : Type) (x : option T) : result bool :=
  b <- boolTraitOption_get_bool T x;
  if b then boolTrait_ret_true (BoolTraitOption T) x else Ok false
.

(** [traits::test_bool_trait]:
    Source: 'src/traits.rs', lines 35:0-35:50 *)
Definition test_bool_trait
  (T : Type) (boolTraitInst : BoolTrait_t T) (x : T) : result bool :=
  boolTraitInst.(BoolTrait_t_get_bool) x
.

(** Trait declaration: [traits::ToU64]
    Source: 'src/traits.rs', lines 39:0-39:15 *)
Record ToU64_t (Self : Type) := mkToU64_t {
  ToU64_t_to_u64 : Self -> result u64;
}.

Arguments mkToU64_t { _ }.
Arguments ToU64_t_to_u64 { _ }.

(** [traits::{(traits::ToU64 for u64)#2}::to_u64]:
    Source: 'src/traits.rs', lines 44:4-44:26 *)
Definition toU64U64_to_u64 (self : u64) : result u64 :=
  Ok self.

(** Trait implementation: [traits::{(traits::ToU64 for u64)#2}]
    Source: 'src/traits.rs', lines 43:0-43:18 *)
Definition ToU64U64 : ToU64_t u64 := {| ToU64_t_to_u64 := toU64U64_to_u64; |}.

(** [traits::{(traits::ToU64 for (A, A))#3}::to_u64]:
    Source: 'src/traits.rs', lines 50:4-50:26 *)
Definition toU64Pair_to_u64
  (A : Type) (toU64Inst : ToU64_t A) (self : (A * A)) : result u64 :=
  let (t, t1) := self in
  i <- toU64Inst.(ToU64_t_to_u64) t;
  i1 <- toU64Inst.(ToU64_t_to_u64) t1;
  u64_add i i1
.

(** Trait implementation: [traits::{(traits::ToU64 for (A, A))#3}]
    Source: 'src/traits.rs', lines 49:0-49:31 *)
Definition ToU64Pair (A : Type) (toU64Inst : ToU64_t A) : ToU64_t (A * A) := {|
  ToU64_t_to_u64 := toU64Pair_to_u64 A toU64Inst;
|}.

(** [traits::f]:
    Source: 'src/traits.rs', lines 55:0-55:36 *)
Definition f (T : Type) (toU64Inst : ToU64_t T) (x : (T * T)) : result u64 :=
  toU64Pair_to_u64 T toU64Inst x
.

(** [traits::g]:
    Source: 'src/traits.rs', lines 59:0-61:18 *)
Definition g
  (T : Type) (toU64PairInst : ToU64_t (T * T)) (x : (T * T)) : result u64 :=
  toU64PairInst.(ToU64_t_to_u64) x
.

(** [traits::h0]:
    Source: 'src/traits.rs', lines 66:0-66:24 *)
Definition h0 (x : u64) : result u64 :=
  toU64U64_to_u64 x.

(** [traits::Wrapper]
    Source: 'src/traits.rs', lines 70:0-70:21 *)
Record Wrapper_t (T : Type) := mkWrapper_t { wrapper_x : T; }.

Arguments mkWrapper_t { _ }.
Arguments wrapper_x { _ }.

(** [traits::{(traits::ToU64 for traits::Wrapper<T>)#4}::to_u64]:
    Source: 'src/traits.rs', lines 75:4-75:26 *)
Definition toU64traitsWrapper_to_u64
  (T : Type) (toU64Inst : ToU64_t T) (self : Wrapper_t T) : result u64 :=
  toU64Inst.(ToU64_t_to_u64) self.(wrapper_x)
.

(** Trait implementation: [traits::{(traits::ToU64 for traits::Wrapper<T>)#4}]
    Source: 'src/traits.rs', lines 74:0-74:35 *)
Definition ToU64traitsWrapper (T : Type) (toU64Inst : ToU64_t T) : ToU64_t
  (Wrapper_t T) := {|
  ToU64_t_to_u64 := toU64traitsWrapper_to_u64 T toU64Inst;
|}.

(** [traits::h1]:
    Source: 'src/traits.rs', lines 80:0-80:33 *)
Definition h1 (x : Wrapper_t u64) : result u64 :=
  toU64traitsWrapper_to_u64 u64 ToU64U64 x
.

(** [traits::h2]:
    Source: 'src/traits.rs', lines 84:0-84:41 *)
Definition h2
  (T : Type) (toU64Inst : ToU64_t T) (x : Wrapper_t T) : result u64 :=
  toU64traitsWrapper_to_u64 T toU64Inst x
.

(** Trait declaration: [traits::ToType]
    Source: 'src/traits.rs', lines 88:0-88:19 *)
Record ToType_t (Self T : Type) := mkToType_t {
  ToType_t_to_type : Self -> result T;
}.

Arguments mkToType_t { _ _ }.
Arguments ToType_t_to_type { _ _ }.

(** [traits::{(traits::ToType<bool> for u64)#5}::to_type]:
    Source: 'src/traits.rs', lines 93:4-93:28 *)
Definition toTypeU64Bool_to_type (self : u64) : result bool :=
  Ok (self s> 0%u64)
.

(** Trait implementation: [traits::{(traits::ToType<bool> for u64)#5}]
    Source: 'src/traits.rs', lines 92:0-92:25 *)
Definition ToTypeU64Bool : ToType_t u64 bool := {|
  ToType_t_to_type := toTypeU64Bool_to_type;
|}.

(** Trait declaration: [traits::OfType]
    Source: 'src/traits.rs', lines 98:0-98:16 *)
Record OfType_t (Self : Type) := mkOfType_t {
  OfType_t_of_type : forall (T : Type) (toTypeInst : ToType_t T Self), T ->
    result Self;
}.

Arguments mkOfType_t { _ }.
Arguments OfType_t_of_type { _ }.

(** [traits::h3]:
    Source: 'src/traits.rs', lines 104:0-104:50 *)
Definition h3
  (T1 T2 : Type) (ofTypeInst : OfType_t T1) (toTypeInst : ToType_t T2 T1)
  (y : T2) :
  result T1
  :=
  ofTypeInst.(OfType_t_of_type) T2 toTypeInst y
.

(** Trait declaration: [traits::OfTypeBis]
    Source: 'src/traits.rs', lines 109:0-109:36 *)
Record OfTypeBis_t (Self T : Type) := mkOfTypeBis_t {
  OfTypeBis_tOfTypeBis_t_ToTypeInst : ToType_t T Self;
  OfTypeBis_t_of_type : T -> result Self;
}.

Arguments mkOfTypeBis_t { _ _ }.
Arguments OfTypeBis_tOfTypeBis_t_ToTypeInst { _ _ }.
Arguments OfTypeBis_t_of_type { _ _ }.

(** [traits::h4]:
    Source: 'src/traits.rs', lines 118:0-118:57 *)
Definition h4
  (T1 T2 : Type) (ofTypeBisInst : OfTypeBis_t T1 T2) (toTypeInst : ToType_t T2
  T1) (y : T2) :
  result T1
  :=
  ofTypeBisInst.(OfTypeBis_t_of_type) y
.

(** [traits::TestType]
    Source: 'src/traits.rs', lines 122:0-122:22 *)
Definition TestType_t (T : Type) : Type := T.

(** [traits::{traits::TestType<T>#6}::test::TestType1]
    Source: 'src/traits.rs', lines 127:8-127:24 *)
Definition TestType_test_TestType1_t : Type := u64.

(** Trait declaration: [traits::{traits::TestType<T>#6}::test::TestTrait]
    Source: 'src/traits.rs', lines 128:8-128:23 *)
Record TestType_test_TestTrait_t (Self : Type) := mkTestType_test_TestTrait_t {
  TestType_test_TestTrait_t_test : Self -> result bool;
}.

Arguments mkTestType_test_TestTrait_t { _ }.
Arguments TestType_test_TestTrait_t_test { _ }.

(** [traits::{traits::TestType<T>#6}::test::{(traits::{traits::TestType<T>#6}::test::TestTrait for traits::{traits::TestType<T>#6}::test::TestType1)}::test]:
    Source: 'src/traits.rs', lines 139:12-139:34 *)
Definition testType_test_TestTraittraitsTestTypetestTestType1_test
  (self : TestType_test_TestType1_t) : result bool :=
  Ok (self s> 1%u64)
.

(** Trait implementation: [traits::{traits::TestType<T>#6}::test::{(traits::{traits::TestType<T>#6}::test::TestTrait for traits::{traits::TestType<T>#6}::test::TestType1)}]
    Source: 'src/traits.rs', lines 138:8-138:36 *)
Definition TestType_test_TestTraittraitsTestTypetestTestType1 :
  TestType_test_TestTrait_t TestType_test_TestType1_t := {|
  TestType_test_TestTrait_t_test :=
    testType_test_TestTraittraitsTestTypetestTestType1_test;
|}.

(** [traits::{traits::TestType<T>#6}::test]:
    Source: 'src/traits.rs', lines 126:4-126:36 *)
Definition testType_test
  (T : Type) (toU64Inst : ToU64_t T) (self : TestType_t T) (x : T) :
  result bool
  :=
  x1 <- toU64Inst.(ToU64_t_to_u64) x;
  if x1 s> 0%u64
  then testType_test_TestTraittraitsTestTypetestTestType1_test 0%u64
  else Ok false
.

(** [traits::BoolWrapper]
    Source: 'src/traits.rs', lines 150:0-150:22 *)
Definition BoolWrapper_t : Type := bool.

(** [traits::{(traits::ToType<T> for traits::BoolWrapper)#7}::to_type]:
    Source: 'src/traits.rs', lines 156:4-156:25 *)
Definition toTypetraitsBoolWrapperT_to_type
  (T : Type) (toTypeBoolTInst : ToType_t bool T) (self : BoolWrapper_t) :
  result T
  :=
  toTypeBoolTInst.(ToType_t_to_type) self
.

(** Trait implementation: [traits::{(traits::ToType<T> for traits::BoolWrapper)#7}]
    Source: 'src/traits.rs', lines 152:0-152:33 *)
Definition ToTypetraitsBoolWrapperT (T : Type) (toTypeBoolTInst : ToType_t bool
  T) : ToType_t BoolWrapper_t T := {|
  ToType_t_to_type := toTypetraitsBoolWrapperT_to_type T toTypeBoolTInst;
|}.

(** [traits::WithConstTy::LEN2]
    Source: 'src/traits.rs', lines 164:4-164:21 *)
Definition with_const_ty_len2_default_body (Self : Type) (LEN : usize)
  : result usize :=
  Ok 32%usize
.
Definition with_const_ty_len2_default (Self : Type) (LEN : usize) : usize :=
  (with_const_ty_len2_default_body Self LEN)%global
.

(** Trait declaration: [traits::WithConstTy]
    Source: 'src/traits.rs', lines 161:0-161:39 *)
Record WithConstTy_t (Self : Type) (LEN : usize) := mkWithConstTy_t {
  WithConstTy_tWithConstTy_t_LEN1 : usize;
  WithConstTy_tWithConstTy_t_LEN2 : usize;
  WithConstTy_tWithConstTy_t_V : Type;
  WithConstTy_tWithConstTy_t_W : Type;
  WithConstTy_tWithConstTy_t_W_clause_0 : ToU64_t WithConstTy_tWithConstTy_t_W;
  WithConstTy_t_f : WithConstTy_tWithConstTy_t_W -> array u8 LEN -> result
    WithConstTy_tWithConstTy_t_W;
}.

Arguments mkWithConstTy_t { _ _ }.
Arguments WithConstTy_tWithConstTy_t_LEN1 { _ _ }.
Arguments WithConstTy_tWithConstTy_t_LEN2 { _ _ }.
Arguments WithConstTy_tWithConstTy_t_V { _ _ }.
Arguments WithConstTy_tWithConstTy_t_W { _ _ }.
Arguments WithConstTy_tWithConstTy_t_W_clause_0 { _ _ }.
Arguments WithConstTy_t_f { _ _ }.

(** [traits::{(traits::WithConstTy<32: usize> for bool)#8}::LEN1]
    Source: 'src/traits.rs', lines 175:4-175:21 *)
Definition with_const_ty_bool32_len1_body : result usize := Ok 12%usize.
Definition with_const_ty_bool32_len1 : usize :=
  with_const_ty_bool32_len1_body%global
.

(** [traits::{(traits::WithConstTy<32: usize> for bool)#8}::f]:
    Source: 'src/traits.rs', lines 180:4-180:39 *)
Definition withConstTyBool32_f
  (i : u64) (a : array u8 32%usize) : result u64 :=
  Ok i
.

(** Trait implementation: [traits::{(traits::WithConstTy<32: usize> for bool)#8}]
    Source: 'src/traits.rs', lines 174:0-174:29 *)
Definition WithConstTyBool32 : WithConstTy_t bool 32%usize := {|
  WithConstTy_tWithConstTy_t_LEN1 := with_const_ty_bool32_len1;
  WithConstTy_tWithConstTy_t_LEN2 := with_const_ty_len2_default bool 32%usize;
  WithConstTy_tWithConstTy_t_V := u8;
  WithConstTy_tWithConstTy_t_W := u64;
  WithConstTy_tWithConstTy_t_W_clause_0 := ToU64U64;
  WithConstTy_t_f := withConstTyBool32_f;
|}.

(** [traits::use_with_const_ty1]:
    Source: 'src/traits.rs', lines 183:0-183:75 *)
Definition use_with_const_ty1
  (H : Type) (LEN : usize) (withConstTyInst : WithConstTy_t H LEN) :
  result usize
  :=
  Ok withConstTyInst.(WithConstTy_tWithConstTy_t_LEN1)
.

(** [traits::use_with_const_ty2]:
    Source: 'src/traits.rs', lines 187:0-187:73 *)
Definition use_with_const_ty2
  (H : Type) (LEN : usize) (withConstTyInst : WithConstTy_t H LEN)
  (w : withConstTyInst.(WithConstTy_tWithConstTy_t_W)) :
  result unit
  :=
  Ok tt
.

(** [traits::use_with_const_ty3]:
    Source: 'src/traits.rs', lines 189:0-189:80 *)
Definition use_with_const_ty3
  (H : Type) (LEN : usize) (withConstTyInst : WithConstTy_t H LEN)
  (x : withConstTyInst.(WithConstTy_tWithConstTy_t_W)) :
  result u64
  :=
  withConstTyInst.(WithConstTy_tWithConstTy_t_W_clause_0).(ToU64_t_to_u64) x
.

(** [traits::test_where1]:
    Source: 'src/traits.rs', lines 193:0-193:40 *)
Definition test_where1 (T : Type) (_x : T) : result unit :=
  Ok tt.

(** [traits::test_where2]:
    Source: 'src/traits.rs', lines 194:0-194:57 *)
Definition test_where2
  (T : Type) (withConstTyT32Inst : WithConstTy_t T 32%usize) (_x : u32) :
  result unit
  :=
  Ok tt
.

(** Trait declaration: [traits::ParentTrait0]
    Source: 'src/traits.rs', lines 200:0-200:22 *)
Record ParentTrait0_t (Self : Type) := mkParentTrait0_t {
  ParentTrait0_tParentTrait0_t_W : Type;
  ParentTrait0_t_get_name : Self -> result string;
  ParentTrait0_t_get_w : Self -> result ParentTrait0_tParentTrait0_t_W;
}.

Arguments mkParentTrait0_t { _ }.
Arguments ParentTrait0_tParentTrait0_t_W { _ }.
Arguments ParentTrait0_t_get_name { _ }.
Arguments ParentTrait0_t_get_w { _ }.

(** Trait declaration: [traits::ParentTrait1]
    Source: 'src/traits.rs', lines 205:0-205:22 *)
Record ParentTrait1_t (Self : Type) := mkParentTrait1_t{}.

Arguments mkParentTrait1_t { _ }.

(** Trait declaration: [traits::ChildTrait]
    Source: 'src/traits.rs', lines 206:0-206:49 *)
Record ChildTrait_t (Self : Type) := mkChildTrait_t {
  ChildTrait_tChildTrait_t_ParentTrait0Inst : ParentTrait0_t Self;
  ChildTrait_tChildTrait_t_ParentTrait1Inst : ParentTrait1_t Self;
}.

Arguments mkChildTrait_t { _ }.
Arguments ChildTrait_tChildTrait_t_ParentTrait0Inst { _ }.
Arguments ChildTrait_tChildTrait_t_ParentTrait1Inst { _ }.

(** [traits::test_child_trait1]:
    Source: 'src/traits.rs', lines 209:0-209:56 *)
Definition test_child_trait1
  (T : Type) (childTraitInst : ChildTrait_t T) (x : T) : result string :=
  childTraitInst.(ChildTrait_tChildTrait_t_ParentTrait0Inst).(ParentTrait0_t_get_name)
    x
.

(** [traits::test_child_trait2]:
    Source: 'src/traits.rs', lines 213:0-213:54 *)
Definition test_child_trait2
  (T : Type) (childTraitInst : ChildTrait_t T) (x : T) :
  result
    childTraitInst.(ChildTrait_tChildTrait_t_ParentTrait0Inst).(ParentTrait0_tParentTrait0_t_W)
  :=
  childTraitInst.(ChildTrait_tChildTrait_t_ParentTrait0Inst).(ParentTrait0_t_get_w)
    x
.

(** [traits::order1]:
    Source: 'src/traits.rs', lines 219:0-219:59 *)
Definition order1
  (T U : Type) (parentTrait0Inst : ParentTrait0_t T) (parentTrait0Inst1 :
  ParentTrait0_t U) :
  result unit
  :=
  Ok tt
.

(** Trait declaration: [traits::ChildTrait1]
    Source: 'src/traits.rs', lines 222:0-222:35 *)
Record ChildTrait1_t (Self : Type) := mkChildTrait1_t {
  ChildTrait1_tChildTrait1_t_ParentTrait1Inst : ParentTrait1_t Self;
}.

Arguments mkChildTrait1_t { _ }.
Arguments ChildTrait1_tChildTrait1_t_ParentTrait1Inst { _ }.

(** Trait implementation: [traits::{(traits::ParentTrait1 for usize)#9}]
    Source: 'src/traits.rs', lines 224:0-224:27 *)
Definition ParentTrait1Usize : ParentTrait1_t usize := mkParentTrait1_t.

(** Trait implementation: [traits::{(traits::ChildTrait1 for usize)#10}]
    Source: 'src/traits.rs', lines 225:0-225:26 *)
Definition ChildTrait1Usize : ChildTrait1_t usize := {|
  ChildTrait1_tChildTrait1_t_ParentTrait1Inst := ParentTrait1Usize;
|}.

(** Trait declaration: [traits::Iterator]
    Source: 'src/traits.rs', lines 229:0-229:18 *)
Record Iterator_t (Self : Type) := mkIterator_t {
  Iterator_tIterator_t_Item : Type;
}.

Arguments mkIterator_t { _ }.
Arguments Iterator_tIterator_t_Item { _ }.

(** Trait declaration: [traits::IntoIterator]
    Source: 'src/traits.rs', lines 233:0-233:22 *)
Record IntoIterator_t (Self : Type) := mkIntoIterator_t {
  IntoIterator_tIntoIterator_t_Item : Type;
  IntoIterator_tIntoIterator_t_IntoIter : Type;
  IntoIterator_tIntoIterator_t_IntoIter_clause_0 : Iterator_t
    IntoIterator_tIntoIterator_t_IntoIter;
  IntoIterator_t_into_iter : Self -> result
    IntoIterator_tIntoIterator_t_IntoIter;
}.

Arguments mkIntoIterator_t { _ }.
Arguments IntoIterator_tIntoIterator_t_Item { _ }.
Arguments IntoIterator_tIntoIterator_t_IntoIter { _ }.
Arguments IntoIterator_tIntoIterator_t_IntoIter_clause_0 { _ }.
Arguments IntoIterator_t_into_iter { _ }.

(** Trait declaration: [traits::FromResidual]
    Source: 'src/traits.rs', lines 250:0-250:21 *)
Record FromResidual_t (Self T : Type) := mkFromResidual_t{}.

Arguments mkFromResidual_t { _ _ }.

(** Trait declaration: [traits::Try]
    Source: 'src/traits.rs', lines 246:0-246:48 *)
Record Try_t (Self : Type) := mkTry_t {
  Try_tTry_t_Residual : Type;
  Try_tTry_t_FromResidualSelftraitsTryResidualInst : FromResidual_t Self
    Try_tTry_t_Residual;
}.

Arguments mkTry_t { _ }.
Arguments Try_tTry_t_Residual { _ }.
Arguments Try_tTry_t_FromResidualSelftraitsTryResidualInst { _ }.

(** Trait declaration: [traits::WithTarget]
    Source: 'src/traits.rs', lines 252:0-252:20 *)
Record WithTarget_t (Self : Type) := mkWithTarget_t {
  WithTarget_tWithTarget_t_Target : Type;
}.

Arguments mkWithTarget_t { _ }.
Arguments WithTarget_tWithTarget_t_Target { _ }.

(** Trait declaration: [traits::ParentTrait2]
    Source: 'src/traits.rs', lines 256:0-256:22 *)
Record ParentTrait2_t (Self : Type) := mkParentTrait2_t {
  ParentTrait2_tParentTrait2_t_U : Type;
  ParentTrait2_tParentTrait2_t_U_clause_0 : WithTarget_t
    ParentTrait2_tParentTrait2_t_U;
}.

Arguments mkParentTrait2_t { _ }.
Arguments ParentTrait2_tParentTrait2_t_U { _ }.
Arguments ParentTrait2_tParentTrait2_t_U_clause_0 { _ }.

(** Trait declaration: [traits::ChildTrait2]
    Source: 'src/traits.rs', lines 260:0-260:35 *)
Record ChildTrait2_t (Self : Type) := mkChildTrait2_t {
  ChildTrait2_tChildTrait2_t_ParentTrait2Inst : ParentTrait2_t Self;
  ChildTrait2_t_convert :
    (ChildTrait2_tChildTrait2_t_ParentTrait2Inst).(ParentTrait2_tParentTrait2_t_U)
    -> result
    (ChildTrait2_tChildTrait2_t_ParentTrait2Inst).(ParentTrait2_tParentTrait2_t_U_clause_0).(WithTarget_tWithTarget_t_Target);
}.

Arguments mkChildTrait2_t { _ }.
Arguments ChildTrait2_tChildTrait2_t_ParentTrait2Inst { _ }.
Arguments ChildTrait2_t_convert { _ }.

(** Trait implementation: [traits::{(traits::WithTarget for u32)#11}]
    Source: 'src/traits.rs', lines 264:0-264:23 *)
Definition WithTargetU32 : WithTarget_t u32 := {|
  WithTarget_tWithTarget_t_Target := u32;
|}.

(** Trait implementation: [traits::{(traits::ParentTrait2 for u32)#12}]
    Source: 'src/traits.rs', lines 268:0-268:25 *)
Definition ParentTrait2U32 : ParentTrait2_t u32 := {|
  ParentTrait2_tParentTrait2_t_U := u32;
  ParentTrait2_tParentTrait2_t_U_clause_0 := WithTargetU32;
|}.

(** [traits::{(traits::ChildTrait2 for u32)#13}::convert]:
    Source: 'src/traits.rs', lines 273:4-273:29 *)
Definition childTrait2U32_convert (x : u32) : result u32 :=
  Ok x.

(** Trait implementation: [traits::{(traits::ChildTrait2 for u32)#13}]
    Source: 'src/traits.rs', lines 272:0-272:24 *)
Definition ChildTrait2U32 : ChildTrait2_t u32 := {|
  ChildTrait2_tChildTrait2_t_ParentTrait2Inst := ParentTrait2U32;
  ChildTrait2_t_convert := childTrait2U32_convert;
|}.

(** Trait declaration: [traits::CFnOnce]
    Source: 'src/traits.rs', lines 286:0-286:23 *)
Record CFnOnce_t (Self Args : Type) := mkCFnOnce_t {
  CFnOnce_tCFnOnce_t_Output : Type;
  CFnOnce_t_call_once : Self -> Args -> result CFnOnce_tCFnOnce_t_Output;
}.

Arguments mkCFnOnce_t { _ _ }.
Arguments CFnOnce_tCFnOnce_t_Output { _ _ }.
Arguments CFnOnce_t_call_once { _ _ }.

(** Trait declaration: [traits::CFnMut]
    Source: 'src/traits.rs', lines 292:0-292:37 *)
Record CFnMut_t (Self Args : Type) := mkCFnMut_t {
  CFnMut_tCFnMut_t_CFnOnceInst : CFnOnce_t Self Args;
  CFnMut_t_call_mut : Self -> Args -> result
    ((CFnMut_tCFnMut_t_CFnOnceInst).(CFnOnce_tCFnOnce_t_Output) * Self);
}.

Arguments mkCFnMut_t { _ _ }.
Arguments CFnMut_tCFnMut_t_CFnOnceInst { _ _ }.
Arguments CFnMut_t_call_mut { _ _ }.

(** Trait declaration: [traits::CFn]
    Source: 'src/traits.rs', lines 296:0-296:33 *)
Record CFn_t (Self Args : Type) := mkCFn_t {
  CFn_tCFn_t_CFnMutInst : CFnMut_t Self Args;
  CFn_t_call : Self -> Args -> result
    (CFn_tCFn_t_CFnMutInst).(CFnMut_tCFnMut_t_CFnOnceInst).(CFnOnce_tCFnOnce_t_Output);
}.

Arguments mkCFn_t { _ _ }.
Arguments CFn_tCFn_t_CFnMutInst { _ _ }.
Arguments CFn_t_call { _ _ }.

(** Trait declaration: [traits::GetTrait]
    Source: 'src/traits.rs', lines 300:0-300:18 *)
Record GetTrait_t (Self : Type) := mkGetTrait_t {
  GetTrait_tGetTrait_t_W : Type;
  GetTrait_t_get_w : Self -> result GetTrait_tGetTrait_t_W;
}.

Arguments mkGetTrait_t { _ }.
Arguments GetTrait_tGetTrait_t_W { _ }.
Arguments GetTrait_t_get_w { _ }.

(** [traits::test_get_trait]:
    Source: 'src/traits.rs', lines 305:0-305:49 *)
Definition test_get_trait
  (T : Type) (getTraitInst : GetTrait_t T) (x : T) :
  result getTraitInst.(GetTrait_tGetTrait_t_W)
  :=
  getTraitInst.(GetTrait_t_get_w) x
.

(** Trait declaration: [traits::Trait]
    Source: 'src/traits.rs', lines 310:0-310:15 *)
Record Trait_t (Self : Type) := mkTrait_t { Trait_tTrait_t_LEN : usize; }.

Arguments mkTrait_t { _ }.
Arguments Trait_tTrait_t_LEN { _ }.

(** [traits::{(traits::Trait for @Array<T, N>)#14}::LEN]
    Source: 'src/traits.rs', lines 315:4-315:20 *)
Definition trait_array_len_body (T : Type) (N : usize) : result usize := Ok N.
Definition trait_array_len (T : Type) (N : usize) : usize :=
  (trait_array_len_body T N)%global
.

(** Trait implementation: [traits::{(traits::Trait for @Array<T, N>)#14}]
    Source: 'src/traits.rs', lines 314:0-314:40 *)
Definition TraitArray (T : Type) (N : usize) : Trait_t (array T N) := {|
  Trait_tTrait_t_LEN := trait_array_len T N;
|}.

(** [traits::{(traits::Trait for traits::Wrapper<T>)#15}::LEN]
    Source: 'src/traits.rs', lines 319:4-319:20 *)
Definition traittraits_wrapper_len_body (T : Type) (traitInst : Trait_t T)
  : result usize :=
  Ok 0%usize
.
Definition traittraits_wrapper_len (T : Type) (traitInst : Trait_t T)
  : usize :=
  (traittraits_wrapper_len_body T traitInst)%global
.

(** Trait implementation: [traits::{(traits::Trait for traits::Wrapper<T>)#15}]
    Source: 'src/traits.rs', lines 318:0-318:35 *)
Definition TraittraitsWrapper (T : Type) (traitInst : Trait_t T) : Trait_t
  (Wrapper_t T) := {|
  Trait_tTrait_t_LEN := traittraits_wrapper_len T traitInst;
|}.

(** [traits::use_wrapper_len]:
    Source: 'src/traits.rs', lines 322:0-322:43 *)
Definition use_wrapper_len (T : Type) (traitInst : Trait_t T) : result usize :=
  Ok (TraittraitsWrapper T traitInst).(Trait_tTrait_t_LEN)
.

(** [traits::Foo]
    Source: 'src/traits.rs', lines 326:0-326:20 *)
Record Foo_t (T U : Type) := mkFoo_t { foo_x : T; foo_y : U; }.

Arguments mkFoo_t { _ _ }.
Arguments foo_x { _ _ }.
Arguments foo_y { _ _ }.

(** [core::result::Result]
    Source: '/rustc/d59363ad0b6391b7fc5bbb02c9ccf9300eef3753/library/core/src/result.rs', lines 502:0-502:21
    Name pattern: core::result::Result *)
Inductive core_result_Result_t (T E : Type) :=
| Core_result_Result_Ok : T -> core_result_Result_t T E
| Core_result_Result_Err : E -> core_result_Result_t T E
.

Arguments Core_result_Result_Ok { _ _ }.
Arguments Core_result_Result_Err { _ _ }.

(** [traits::{traits::Foo<T, U>#16}::FOO]
    Source: 'src/traits.rs', lines 332:4-332:33 *)
Definition foo_foo_body (T U : Type) (traitInst : Trait_t T)
  : result (core_result_Result_t T i32) :=
  Ok (Core_result_Result_Err 0%i32)
.
Definition foo_foo (T U : Type) (traitInst : Trait_t T)
  : core_result_Result_t T i32 :=
  (foo_foo_body T U traitInst)%global
.

(** [traits::use_foo1]:
    Source: 'src/traits.rs', lines 335:0-335:48 *)
Definition use_foo1
  (T U : Type) (traitInst : Trait_t T) : result (core_result_Result_t T i32) :=
  Ok (foo_foo T U traitInst)
.

(** [traits::use_foo2]:
    Source: 'src/traits.rs', lines 339:0-339:48 *)
Definition use_foo2
  (T U : Type) (traitInst : Trait_t U) : result (core_result_Result_t U i32) :=
  Ok (foo_foo U T traitInst)
.

End Traits.