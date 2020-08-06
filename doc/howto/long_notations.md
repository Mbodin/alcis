Most notations take a constant number of argument.
Some, like the `[a1; .. ; an]` notation for lists take an arbitrary number of argument.
This how aims to explain how to design such notations, by looking at how lists do the trick.

We assume that the notation has a starting character (`[` for lists) and an ending character (`]` for lists).
We also assume that the considered type is a list-like type: it has an empty element, and a way to add one.

First, define an intermediary type that will be solely use for parsing the notation.
This notation is usually prefixed by `//`: `//string` for `string`, `//[ a ]` for `[ a ]`.
In some ways, the trick consists in building an automaton whose state is this parsing `//` type and result will be our target type (e.g., `[ a ]`).

This intermediary type will be left abstract in the module signature:
```alcis
?a. _ : //[ a ].
```
And will be defined as a synonym for the base type in the module implementation:
```alcis
//[ ?a ] ::= [ a ].
```
This guarantees that despite `//[ a ]` is the same than `[ a ]`, this fact won’t be known outside the module, thus forcing users to close the notation to produce a `[ a ]`.

There are two ways to then parse the inner type: left to right or right to left.
In the case of lists, it is right to left.

The first symbol according to this reading should produce an empty intermediary type.
In the case of lists, the first symbol is `]` as lists are parsed right to left.
We thus define:
```alcis
?a. ] : //[ a ].
] := [].
```

We then need a way to deal with the middle part of the notation: a sequence of values separated by `;`.
This symbol will serve as the list constructor.
As we parse the list right to left, we assume an already-parsed `//[ a ]` at the right and a new element of type `a` at the left:
```alcis
?a. a ; ??(//[ a ]) : //[ a ].
?v ; ??l := v :: l.
```

Finally, we need a way to convert the constructed `//[ a ]` into a `[ a ]`, using the last read symbol, in this case, `[`.
The implementation is always an identity function as `//[ a ]` is by definition equal to `[ a ]`:
```alcis
?a. [ (//[ a ]) : [ a ].
[ ?l := l.
```

As-is, we defined the notation `[a1; .. ; an;]`.
To enable not having to deal with the last semicolon, one can define a variant for the `]` symbol that takes a left argument:
```alcis
?a ] : //[ a ].
```

