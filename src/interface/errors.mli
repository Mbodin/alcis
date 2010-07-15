(* errors.mli *)
(* Functions to handle errors and a list of booleans that describe what to do if there is one. *)

val error : string -> 'a
val warn : string -> unit


val warning_comments : unit -> bool

