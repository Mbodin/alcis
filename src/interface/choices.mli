(* choices.mli *)
(* Handle all the options of the program. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)

type arg =
    | Bool of bool


val add_boolean_option : string -> bool -> string -> unit
val get_value : string -> arg

val list_options : unit -> unit

