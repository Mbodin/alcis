(* errors.mli *)
(* Functions to handle errors and a list of booleans that describe what to do if there is one. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

val error : string list -> 'a
val warn : string list -> unit
val internal_error : string list -> 'a


val define_warning : string -> bool -> string -> unit
val get_warning : string -> bool

