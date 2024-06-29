theory Primitives imports
 Main
 "HOL-Library.Monad_Syntax"
begin


datatype u32 = u32 nat
datatype 'a result = Ok 'a | Err
fun u32_lt :: "u32 \<Rightarrow> u32 \<Rightarrow> bool" where
  "u32_lt (u32 a) (u32 b) = (a < b)"

definition bind :: "'a result \<Rightarrow> ('a \<Rightarrow> 'b result) \<Rightarrow> 'b result" where
 "bind m f \<equiv> (case m of Err \<Rightarrow> Err | Ok a \<Rightarrow> f a)"

adhoc_overloading Monad_Syntax.bind bind

declare bind_def[simp]

end