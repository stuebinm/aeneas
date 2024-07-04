theory Primitives imports
 Main
 "HOL-Library.Monad_Syntax"
begin

typedef u32 = "{n. (n :: nat) \<le> 4294967295}"
  morphisms Rep_u32 Abs_u32
proof
  show "0 \<in> {n. (n :: nat) \<le> 4294967295}" by simp
qed

definition u32_lt :: "u32 \<Rightarrow> u32 \<Rightarrow> bool" where
 "u32_lt a b \<equiv> Rep_u32 a < Rep_u32 b"


datatype 'a result = Ok 'a | Err

definition bind :: "'a result \<Rightarrow> ('a \<Rightarrow> 'b result) \<Rightarrow> 'b result" where
 "bind m f \<equiv> (case m of Err \<Rightarrow> Err | Ok a \<Rightarrow> f a)"

adhoc_overloading Monad_Syntax.bind bind

declare bind_def[simp]

(* TODO: instantiation to make u32 usable with literal numbers etc. *)

end