(** [external]: external types.
-- This is a template file: rename it to "TypesExternal.lean" and fill the holes. *)
Require Import Primitives.
Import Primitives.
Require Import Coq.ZArith.ZArith.
Require Import List.
Import ListNotations.
Local Open Scope Primitives_scope.
Module External_TypesExternal.

(** [core::cell::Cell] *)
Axiom core_cell_Cell_t : forall (T : Type), Type.

(** The state type used in the state-error monad *)
Axiom state : Type.

End External_TypesExternal.
