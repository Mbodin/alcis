(* position.ml *)
(* Contains definition to know where something happens. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

type file_type =
    | Alcis_header
    | Alcis_source_code
    | Alcis_C_interface
    | C_header
    | C_source_code

type t = string * ((int * int) option)

