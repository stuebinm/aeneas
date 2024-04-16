(** [hashmap_main]: external function declarations *)
open primitivesLib divDefLib
open hashmapMain_TypesTheory

val _ = new_theory "hashmapMain_Opaque"


(** [hashmap_main::hashmap_utils::deserialize]: forward function *)val _ = new_constant ("hashmap_utils_deserialize_fwd",
  “:state -> (state # u64 hashmap_hash_map_t) result”)

(** [hashmap_main::hashmap_utils::serialize]: forward function *)val _ = new_constant ("hashmap_utils_serialize_fwd",
  “:u64 hashmap_hash_map_t -> state -> (state # unit) result”)

val _ = export_theory ()
