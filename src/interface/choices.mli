(* choices.mli *)
(* Handle all the options of the program. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)

type arg =
    | Bool of bool


val add_boolean_option : string -> bool -> string -> unit
val add_action : string -> int -> (string list) -> string -> (string list -> unit) -> unit

val get_value : string -> arg
val get_boolean : string -> bool

val get_nb_arg : string -> int option
val do_action : string -> string list -> unit

val list_options : unit -> unit

val set_internal_error_function : (string list -> unit) -> unit

