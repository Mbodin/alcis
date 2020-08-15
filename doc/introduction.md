
Alcis is a programming language whose main feature is to enable the creation of arbitrary notations at will.
The language is typed and functional.

# File Types

There are two kinds of source files:
- header files, usually with the extension `.ah`.
  They define a module signature, with its types and function types.
- code files, usually with the extension `.ac`.
  They contain the declaration of functions and local types.

To these two kinds of files, we add two compiled kinds of files:
- object header files, with the extension `.aho`.
- object files, with the extension `.aco`.
These files contain compilation information.

# Example

The following snippet shows how to define a basic function.
See [examples](../examples/) for more details.

```alcis
(* Definition of an identity function. *)
f ?x := x.

(* Opening modules. *)
integer.|>

(* Declaration of a constant. *)
c := decimal.(42).

(* Declaration of an inductive type: a list. *)
list ?a ::=
  | []
  | a :: (list a)
  .

(* Definition of a recursive function over a list. *)
length ?l :=
  l?(
	| [] -> 0
	| _ :: ?l' -> i1 + length l'
	).

(* Definition of an inline operator over lists. *)
(?la ++ ?lb) :=
  la?(
  | [] -> lb
  | ?a :: ?la' -> a :: (la' ++ lb)
  ).

(* Declaring a fancy function taking its argument to the left. *)
?x fancy := x :: [].

(* Note that in a conflict of notation in an expression like [length l fancy]:
  it could either mean [length (l fancy)] or [(length l) fancy].
  If there is any ambiguity, the compiler will refuse the compilation: parentheses are then mandatory.
  Alternatively, one can declare that (for instance) [fancy] has a higher priority than [length]:
  all [length l fancy] expressions will then be understood as [length (l fancy)]. *)
(_ fancy) ::> (length _).

(* A less fancy usage of the priority can be defined between [::] and [++]. *)
_ :: _ ::> _ ++ _.

(* One can define operations with more than one symbols. *)
?x # ??y # ?z := x - y + z.

(* Note the use of the double [?] for the [??y] argument.
  If it were just [?y], then there would be an ambiguity in [a # b # c # d # e].
  However, as the conflict is between [(_ # _ # _)] and…itself, we can’t use the [::>] operator.
  The double [?] serves for this purpose: it means that in case of an ambiguity, then it is the
  argument [?y] that has priority over the others: [a # b # c # d # e] thus means
  [a # (b # c # d) # e]. *)

(* Of course, the example [(_ # _ # _)] is just silly.
  There are cases where this is wanted, though, like in the [++] example above, or the factorial. *)
?n ! := if n = 0 then 1 else ((n - 1)! * n).

(* In fact, lists themselves are not noted [list a] in Alcis: they are noted [[ a ]].
  This is possible thanks to the notation mechanism: *)
[ ?a ] ::=
	| []
	| a :: ([ a ])
	.
```

# Documentation

This documentation is organised as follows.

## References
- [basics](reference/basics.md): reserved identifiers, tokenisation, etc.
- [types](reference/types.md): syntax for type declarations.
- [definitions](reference/definitions.md): syntax for terms.
- [priorities](reference/priorities.md): describe how terms are parsed, and how to tune it.
- [modules](reference/modules.md): syntax to define priority between operators.
- [evaluation](reference/evaluation.md): evaluation model.
- [command-line](reference/command_line.md): command-line usage of the compiler.
- [stdlib](reference/stdlib.md): description of the standard library.

## Tutorials
None for now.

## Explanations
None for now.

## How-to
- [long-notations](howto/long_notations.md): how to define long notations like the `[a1; .. ; an]` list-notation,
- [records](howto/records.md): how to define records.


