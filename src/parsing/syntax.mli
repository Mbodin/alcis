(** The typed syntax of Alcis. *)
(* author: Martin Constantino–Bodin <martin.bodin@ens-lyon.org> *)

(** Atomic identifiers are either a letter-based identifier, a digit,
   or a symbol-based identifier. *)
type atomic_identifier = string

(** A path of modules. *)
type path (* TODO *)

(** An identifier identifies a definition. *)
type identifier = {
    id_path : path
    id_name : atomic_identifier list ;
  }

(** A module signature is a mapping of definitions, each associated to a type.
   This type is paramaterised by the type of free type variable. *)
type 'fv module_type = {
    sig_types : (identifier, 'fv type_declaration option) PMap.t
      (** All declared types.  [None] indicates that the type is left abstract. *) ;
    sig_decl : (identifier, 'fv value_type) PMap.t (** All expected definitions. *)
  }

(** The type of values, paramaterised by its free variables. *)
and 'fv value_type =
  | TVar of 'fv (** Free type variable. *)
  | TForall of 'fv * 'fv value_type (** A universally-quantified variable. *)
  | TFunction of 'fv pattern * 'fv value_type (** A function from this pattern to this type. *)
  | TBase of identifier (** A declared type. *) (* FIXME: Not right. *)
  | TModule of 'fv module_type (** A module signature *)

(** A pattern of types and holes. [None] represent the holes. *)
and 'fv pattern = 'fv value_type option list

(** Type declarations. *)
and 'fv type_declaration =
  | TAlias of 'fv value_type (** A type defined as an alias. *)
  | TDefinition of (identifier * 'fv pattern) list (** A type defined by a list of constructors. *)

(** A module signature is a mapping of definitions. *)
type 'fv module_implementation = {
    struct_types : (identifier, 'fv type_declaration option) PMap.t
      (** All declared types.  [None] indicates that the type is symbolic. *) ;
    struct_decl : (identifier, 'fv value) PMap.t (** All definitions. *)
  }

(** A value, comprising a type and a definition. *)
and 'fv value = {
    v_type : 'fv value_type ;
    v_def : 'fv definition
  }

(** A value definition. *)
and 'fv definition =
  | VAlias of identifier (** The definition is just an alias. *)
  | VApp of 'fv definition * 'fv definition list (** A function application applied to these arguments. *)
  | VLambda of 'fv pattern * 'fv definition (** A lambda-abstraction. *)
  | VModule of 'fv module_implementation (** A module. *)

