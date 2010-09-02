(* errors.mli *)
(* Functions to handle errors and a list of booleans that describe what to do if there is one. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

val error : Position.t -> string list -> 'a
val warn : Position.t -> string list -> unit
val internal_error : string list -> 'a
val internal_warning : string list -> unit
val not_implemented : string -> 'a
val misstyped : string -> string -> 'a

val define_warning : string -> bool -> string -> unit
val get_warning : string -> bool

