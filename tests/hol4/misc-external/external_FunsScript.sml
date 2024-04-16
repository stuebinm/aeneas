(** [external]: function definitions *)
open primitivesLib divDefLib
open external_TypesTheory external_OpaqueTheory

val _ = new_theory "external_Funs"


val swap_fwd_def = Define ‘
  (** [external::swap]: forward function *)
  swap_fwd (x : 't) (y : 't) (st : state) : (state # unit) result =
    do
    (st0, _) <- core_mem_swap_fwd x y st;
    (st1, _) <- core_mem_swap_back0 x y st st0;
    (st2, _) <- core_mem_swap_back1 x y st st1;
    Return (st2, ())
    od
’

val swap_back_def = Define ‘
  (** [external::swap]: backward function 0 *)
  swap_back
    (x : 't) (y : 't) (st : state) (st0 : state) : (state # ('t # 't)) result =
    do
    (st1, _) <- core_mem_swap_fwd x y st;
    (st2, x0) <- core_mem_swap_back0 x y st st1;
    (_, y0) <- core_mem_swap_back1 x y st st2;
    Return (st0, (x0, y0))
    od
’

val test_new_non_zero_u32_fwd_def = Define ‘
  (** [external::test_new_non_zero_u32]: forward function *)
  test_new_non_zero_u32_fwd
    (x : u32) (st : state) : (state # core_num_nonzero_non_zero_u32_t) result =
    do
    (st0, opt) <- core_num_nonzero_non_zero_u32_new_fwd x st;
    core_option_option_unwrap_fwd opt st0
    od
’

val test_vec_fwd_def = Define ‘
  (** [external::test_vec]: forward function *)
  test_vec_fwd : unit result =
    let v = vec_new in do
                       _ <- vec_push_back v (int_to_u32 0);
                       Return ()
                       od
’

(** Unit test for [external::test_vec] *)
val _ = assert_return (“test_vec_fwd”)

val custom_swap_fwd_def = Define ‘
  (** [external::custom_swap]: forward function *)
  custom_swap_fwd (x : 't) (y : 't) (st : state) : (state # 't) result =
    do
    (st0, _) <- core_mem_swap_fwd x y st;
    (st1, x0) <- core_mem_swap_back0 x y st st0;
    (st2, _) <- core_mem_swap_back1 x y st st1;
    Return (st2, x0)
    od
’

val custom_swap_back_def = Define ‘
  (** [external::custom_swap]: backward function 0 *)
  custom_swap_back
    (x : 't) (y : 't) (st : state) (ret : 't) (st0 : state) :
    (state # ('t # 't)) result
    =
    do
    (st1, _) <- core_mem_swap_fwd x y st;
    (st2, _) <- core_mem_swap_back0 x y st st1;
    (_, y0) <- core_mem_swap_back1 x y st st2;
    Return (st0, (ret, y0))
    od
’

val test_custom_swap_fwd_def = Define ‘
  (** [external::test_custom_swap]: forward function *)
  test_custom_swap_fwd
    (x : u32) (y : u32) (st : state) : (state # unit) result =
    do
    (st0, _) <- custom_swap_fwd x y st;
    Return (st0, ())
    od
’

val test_custom_swap_back_def = Define ‘
  (** [external::test_custom_swap]: backward function 0 *)
  test_custom_swap_back
    (x : u32) (y : u32) (st : state) (st0 : state) :
    (state # (u32 # u32)) result
    =
    custom_swap_back x y st (int_to_u32 1) st0
’

val test_swap_non_zero_fwd_def = Define ‘
  (** [external::test_swap_non_zero]: forward function *)
  test_swap_non_zero_fwd (x : u32) (st : state) : (state # u32) result =
    do
    (st0, _) <- swap_fwd x (int_to_u32 0) st;
    (st1, (x0, _)) <- swap_back x (int_to_u32 0) st st0;
    if x0 = int_to_u32 0 then Fail Failure else Return (st1, x0)
    od
’

val _ = export_theory ()
