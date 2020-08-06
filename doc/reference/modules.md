Each pair of `.ah`/`.ac` Alcis files whose name follows the convention of letter-based identifiers creates a module.
Modules thus contains all type declarations and value definitions.

Values inside modules can be accessed using the `.` operator, for instance `pair.swap`.
This only works for letter-based identifiers, though: for other identifiers, parentheses are mandatory (e.g., `pair.(+)`).
More generally, one can locally open a module with parentheses: `decimal.(42)` means the same than `decimal.(4) decimal.(2)`.

To completely open a module, one can use the `.|>` operator: `string.|>` opens the `string` module from this place to the first end of parenthesis (or until the end of the current module).
Note that this may introduce name conflicts.
In the case of a name conflict between two `.|>`-opened or `.`-opened modules that types can’t differentiate, a compilation error is thrown.
In the case of a name conflict between a `.|>`-opened module and a `.`-opened module, the `.`-opened module has by default precedence.
FIXME: This behaviour can be changed with a compilation option.
There finally might be a collision between a module name and a local identifier (for instance if one defines a local `list` identifier): in such cases, the local identifier always has priority.

The `.<|` operator includes the given module to the current one.
For instance, writing `pair.<|` in a module adds the definition `swap` of the `pair` module, as well as all the other values and type definitions.
This is equivalent than writing a trivial:
```alcis
??a * ?b ::= a pair.(,) b.
??a + ?b ::= a pair.(+) b.
swap := pair.swap.
(* etc. *)
```
This construct is useful to extend an existing module (for instance from the standard library) that can’t easily be changed: one can create a copy of the module with `.<|` and add the wanted function.
For instance:
```alcis
list.<|
is empty ?l := l = [].
```
The `.<|` operator can both be used in a module signature or a module implementation.
Only the definitions included in the module signature of the imported module are imported.

Modules (both module types and implementations) can also be inside a module with the `(|` and `|)` syntax.
An extended example can be found in [records](../howto/records.md).
Here is for instance a local extension for the `list` module:
```alcis
list' : (|
		list.<|
		?a. is empty |> [ a ] : bool.bool
	|).
list' := (|
		list.<|
		is empty ?l := l = [].
	|).
```

The declarations in a module signature are implicitely included in its implementation.
For instance, this module declaration is valid:
```alcis
(|
	tb ::= [ ta ].

	convert tb : ta.
	convert ?l' := l l'.

	f ?a :=
		a?(
			| int _ -> l []
			| l ?l' -> convert l'
		).
|) : (|
		ta ::= int integer.integer | l ([ ta ]).

		f ta : ta.
	|).
```

