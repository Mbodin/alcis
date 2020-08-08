(** Functions to handle errors. *)
(* author: Martin Constantino–Bodin <martin.bodin@ens-lyon.org> *)

(** We define two levels of errors: errors and warning.
   Errors indicate a non-recoverable mistake in the source file,
   whilst warning can be recovered. *)

(** Report a error in a source file. *)
val error : Position.t -> string list -> 'a

(** Report a warning in a source file. *)
val warn : Position.t -> string list -> unit

(** Report an internal error. *)
val internal_error : string list -> 'a

(** Report an internal warning. *)
val internal_warning : string list -> unit

(** Report an internal warning. *)
val not_implemented : string -> 'a

(** FIXME: When this function should be used? *)
val misstyped : string -> string -> 'a

(** Define a warning that can be parameterised by the user.
   The first string is the name of the warning (which is also used in the program options),
   the boolean is the default value, and the third is a description. *)
val define_warning : string -> bool -> string -> unit

(** Get whether a given warning is enabled. *)
val get_warning : string -> bool

