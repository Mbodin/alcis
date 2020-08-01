
Alcis is a programming language whose main feature is to enable the creation of arbitrary notations at will.
The language is typed and functional.

# File Types

There are two kinds of source files:
- header files, usually with the extension `.ah`.
  They define a module signature, with its types and function types.
- code files, usually with the extension `.ac`.
  They contain the declaration of functions and local types.

# Examples

The following snippet shows how to define a basic function.
See [examples](../examples/) for more details.

```alcis
(* Definition of an identity function. *)
(f ?x) := x.

(* Openning modules. *)
numeric.$

(* Declaration of a constant. *)
c := i42.

(* Declaration of an inductive type: a list. *)
(list ?a) ::=
  | []
  | a :: (list a)
  .

(* Definition of a recursive function over a list. *)
(length ?l) :=
  l?(
	| [] -> i0
	| _ :: ?l' -> i1 + length l'
	).

(* Definition of an inline operator over lists. *)
(?la ++ ?lb) :=
  la?(
  | [] -> lb
  | ?a :: ?la' -> a :: (la' ++ lb)
  ).

(* Declaring a fancy function taking its argument to the left. *)
(?x fancy) := x :: [].

(* Note that in a conflict of notation in an expression like [length l fancy]:
  it could either mean [length (l fancy)] or [(length l) fancy].
  If there is any ambiguity, the compiler will refuse the compilation: parentheses are then mandatory.
  Alternatively, one can declare that (for instance) [fancy] has a higher priority than [length]:
  all [length l fancy] expressions will then be understood as [length (l fancy)]. *)
(_ fancy) ::> (length _).

(* A less fancy usage of the priority can be defined between [::] and [++]. *)
(_ :: _) ::> (_ ++ _).

(* One can define operations with more than one symbols. *)
(?x # ??y # ?z) := x + y + z.

(* Note the use of the double [?] for the [??y] argument.
  If it were just [?y], then there would be an ambiguity in [a # b # c # d # e].
  However, as the conflict is between [(_ # _ # _)] and…itself, we can’t use the [::>] operator.
  The double [?] serves for this purpose: it means that in case of an ambiguity, then it is the
  argument [?y] that has priority over the others: [a # b # c # d # e] thus means
  [a # (b # c # d) # e]. *)

(* Of course, the example [(_ # _ # _)] is just silly.
  There are cases where this is wanted, though, like in the [++] example above. *)
```

