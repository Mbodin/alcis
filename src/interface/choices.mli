(* choices.mli *)
(* Handle all the options of the program. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)

type file_type =
    | Alcis_header
    | Alcis_source_code
    | Alcis_C_interface
    | C_header
    | C_source_code

type arg =
    | Bool of bool
    | String of string
    | Input_list of (in_channel * file_type) list


val add_boolean_option : string -> bool -> string -> unit
val add_option : string -> arg -> unit
val add_action : string -> int -> (string list) -> string -> (string list -> unit) -> unit

val get_value : string -> arg
val set_value : string -> arg -> unit

val get_boolean : string -> bool
val set_boolean : string -> bool -> unit

val get_nb_arg : string -> int option
val do_action : string -> string list -> unit

val list_options : unit -> unit

val set_internal_error_function : (string list -> unit) -> (string list -> unit) -> unit

