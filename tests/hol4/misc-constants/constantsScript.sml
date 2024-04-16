(** [constants] *)
open primitivesLib divDefLib

val _ = new_theory "constants"


(** [constants::X0] *)
Definition x0_body_def:
  x0_body : u32 result = Return (int_to_u32 0)
End
Definition x0_c_def:
  x0_c : u32 = get_return_value x0_body
End

(** [constants::X1] *)
Definition x1_body_def:
  x1_body : u32 result = Return core_u32_max
End
Definition x1_c_def:
  x1_c : u32 = get_return_value x1_body
End

(** [constants::X2] *)
Definition x2_body_def:
  x2_body : u32 result = Return (int_to_u32 3)
End
Definition x2_c_def:
  x2_c : u32 = get_return_value x2_body
End

val incr_fwd_def = Define ‘
  (** [constants::incr]: forward function *)
  incr_fwd (n : u32) : u32 result =
    u32_add n (int_to_u32 1)
’

(** [constants::X3] *)
Definition x3_body_def:
  x3_body : u32 result = incr_fwd (int_to_u32 32)
End
Definition x3_c_def:
  x3_c : u32 = get_return_value x3_body
End

val mk_pair0_fwd_def = Define ‘
  (** [constants::mk_pair0]: forward function *)
  mk_pair0_fwd (x : u32) (y : u32) : (u32 # u32) result =
    Return (x, y)
’

Datatype:
  (** [constants::Pair] *)
  pair_t = <| pair_x : 't1; pair_y : 't2; |>
End

val mk_pair1_fwd_def = Define ‘
  (** [constants::mk_pair1]: forward function *)
  mk_pair1_fwd (x : u32) (y : u32) : (u32, u32) pair_t result =
    Return (<| pair_x := x; pair_y := y |>)
’

(** [constants::P0] *)
Definition p0_body_def:
  p0_body : (u32 # u32) result = mk_pair0_fwd (int_to_u32 0) (int_to_u32 1)
End
Definition p0_c_def:
  p0_c : (u32 # u32) = get_return_value p0_body
End

(** [constants::P1] *)
Definition p1_body_def:
  p1_body : (u32, u32) pair_t result =
    mk_pair1_fwd (int_to_u32 0) (int_to_u32 1)
End
Definition p1_c_def:
  p1_c : (u32, u32) pair_t = get_return_value p1_body
End

(** [constants::P2] *)
Definition p2_body_def:
  p2_body : (u32 # u32) result = Return (int_to_u32 0, int_to_u32 1)
End
Definition p2_c_def:
  p2_c : (u32 # u32) = get_return_value p2_body
End

(** [constants::P3] *)
Definition p3_body_def:
  p3_body : (u32, u32) pair_t result =
    Return (<| pair_x := (int_to_u32 0); pair_y := (int_to_u32 1) |>)
End
Definition p3_c_def:
  p3_c : (u32, u32) pair_t = get_return_value p3_body
End

Datatype:
  (** [constants::Wrap] *)
  wrap_t = <| wrap_val : 't; |>
End

val wrap_new_fwd_def = Define ‘
  (** [constants::Wrap::{0}::new]: forward function *)
  wrap_new_fwd (val : 't) : 't wrap_t result =
    Return (<| wrap_val := val |>)
’

(** [constants::Y] *)
Definition y_body_def:
  y_body : i32 wrap_t result = wrap_new_fwd (int_to_i32 2)
End
Definition y_c_def:
  y_c : i32 wrap_t = get_return_value y_body
End

val unwrap_y_fwd_def = Define ‘
  (** [constants::unwrap_y]: forward function *)
  unwrap_y_fwd : i32 result =
    Return y_c.wrap_val
’

(** [constants::YVAL] *)
Definition yval_body_def:
  yval_body : i32 result = unwrap_y_fwd
End
Definition yval_c_def:
  yval_c : i32 = get_return_value yval_body
End

(** [constants::get_z1::Z1] *)
Definition get_z1_z1_body_def:
  get_z1_z1_body : i32 result = Return (int_to_i32 3)
End
Definition get_z1_z1_c_def:
  get_z1_z1_c : i32 = get_return_value get_z1_z1_body
End

val get_z1_fwd_def = Define ‘
  (** [constants::get_z1]: forward function *)
  get_z1_fwd : i32 result =
    Return get_z1_z1_c
’

val add_fwd_def = Define ‘
  (** [constants::add]: forward function *)
  add_fwd (a : i32) (b : i32) : i32 result =
    i32_add a b
’

(** [constants::Q1] *)
Definition q1_body_def:
  q1_body : i32 result = Return (int_to_i32 5)
End
Definition q1_c_def:
  q1_c : i32 = get_return_value q1_body
End

(** [constants::Q2] *)
Definition q2_body_def:
  q2_body : i32 result = Return q1_c
End
Definition q2_c_def:
  q2_c : i32 = get_return_value q2_body
End

(** [constants::Q3] *)
Definition q3_body_def:
  q3_body : i32 result = add_fwd q2_c (int_to_i32 3)
End
Definition q3_c_def:
  q3_c : i32 = get_return_value q3_body
End

val get_z2_fwd_def = Define ‘
  (** [constants::get_z2]: forward function *)
  get_z2_fwd : i32 result =
    do
    i <- get_z1_fwd;
    i0 <- add_fwd i q3_c;
    add_fwd q1_c i0
    od
’

(** [constants::S1] *)
Definition s1_body_def:
  s1_body : u32 result = Return (int_to_u32 6)
End
Definition s1_c_def:
  s1_c : u32 = get_return_value s1_body
End

(** [constants::S2] *)
Definition s2_body_def:
  s2_body : u32 result = incr_fwd s1_c
End
Definition s2_c_def:
  s2_c : u32 = get_return_value s2_body
End

(** [constants::S3] *)
Definition s3_body_def:
  s3_body : (u32, u32) pair_t result = Return p3_c
End
Definition s3_c_def:
  s3_c : (u32, u32) pair_t = get_return_value s3_body
End

(** [constants::S4] *)
Definition s4_body_def:
  s4_body : (u32, u32) pair_t result =
    mk_pair1_fwd (int_to_u32 7) (int_to_u32 8)
End
Definition s4_c_def:
  s4_c : (u32, u32) pair_t = get_return_value s4_body
End

val _ = export_theory ()
