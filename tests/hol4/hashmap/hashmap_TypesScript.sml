(** [hashmap]: type definitions *)
open primitivesLib divDefLib

val _ = new_theory "hashmap_Types"


Datatype:
  (** [hashmap::List] *)
  list_t = | ListCons usize 't list_t | ListNil
End

Datatype:
  (** [hashmap::HashMap] *)
  hash_map_t =
  <|
    hash_map_num_entries : usize;
    hash_map_max_load_factor : (usize # usize);
    hash_map_max_load : usize;
    hash_map_slots : 't list_t vec;
  |>
End

val _ = export_theory ()
