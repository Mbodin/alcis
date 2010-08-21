(* position.mli *)
(* Contains definition to know where something happens. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

type file_type =
    | Alcis_header
    | Alcis_source_code
    | Alcis_C_interface
    | C_header
    | C_source_code

type t

val get_filename : t -> string
val get_line : t -> int option
val get_colon : t -> int option

val make : string -> int option -> int option -> t

val global : t

