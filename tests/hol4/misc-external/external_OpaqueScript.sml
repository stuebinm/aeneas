(** [external]: external function declarations *)
open primitivesLib divDefLib
open external_TypesTheory

val _ = new_theory "external_Opaque"


(** [core::mem::swap]: forward function *)val _ = new_constant ("core_mem_swap_fwd",
  “:'t -> 't -> state -> (state # unit) result”)

(** [core::mem::swap]: backward function 0 *)val _ = new_constant ("core_mem_swap_back0",
  “:'t -> 't -> state -> state -> (state # 't) result”)

(** [core::mem::swap]: backward function 1 *)val _ = new_constant ("core_mem_swap_back1",
  “:'t -> 't -> state -> state -> (state # 't) result”)

(** [core::num::nonzero::NonZeroU32::{14}::new]: forward function *)val _ = new_constant ("core_num_nonzero_non_zero_u32_new_fwd",
  “:u32 -> state -> (state # core_num_nonzero_non_zero_u32_t option)
  result”)

(** [core::option::Option::{0}::unwrap]: forward function *)val _ = new_constant ("core_option_option_unwrap_fwd",
  “:'t option -> state -> (state # 't) result”)

val _ = export_theory ()
