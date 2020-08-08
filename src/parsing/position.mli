(** Function to deal with positions. *)
(* author: Martin Constantino–Bodin <martin.bodin@ens-lyon.org> *)

(* TODO: Documentation *)

(** A type to represent file position. *)
type t

(** A smart constructor for [t], specifying the filename, line, and colon of a position. *)
val make : string -> ?line:int -> ?colon:int -> t

(** The different kind of files that this program can manipulate. *)
type file_type =
    | Alcis_header
    | Alcis_source_code
    | Alcis_compiled_header
    | Alcis_compiled_code

(** Getting the respective filename, line, and colon from a position. *)
val get_filename : t -> string
val get_line : t -> int option
val get_colon : t -> int option

(** Pretty-print the position (with or without displaying the filename). *)
val to_string : t -> string
val infile_to_string : t -> string

(** A position for internal errors. *)
val global : t

(** A monad to track the current position.
  FIXME: It is based on some side-effects, though: I need to look at that. *)
type 'a e

val get_pos : 'a e -> t
val get_val : 'a e -> 'a

val etiq : 'a -> t -> 'a e
val cetiq : 'a -> 'a e

val apply : ('a -> 'b) -> 'a e -> 'b e

val set_filename : string -> unit
val new_line : unit -> unit
val characters_read : int -> unit

val get_position : unit -> t

