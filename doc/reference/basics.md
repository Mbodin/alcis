
# Tokenisation

## Comments
Comments are enclosed between `(*` and `*)`.
Comments can be nested.

## Identifiers
There are three kinds of identifiers:
- letter-based identifier, with only letters (a-z, A-Z) or the `'` and `_` characters.
- symbol-based identifier, with only symbols: `` ` ``, `~`, `!`, `"`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `-`, `+`, `=`, `[`, `]`, `{`, `}`, `\`, `/`, `|`, `;`, `:`, `<`, `>`, `?`, `,`, `.`, `¬`, `¦`, `×`, `÷`, `¿`, `¡`, `€`, `₤`, `¤`, `‘`, `’`, `“`, `”`, and `°`. (The exact list might expand in the future.) Note that parentheses `(` and `)` are not part of this list.
- numbers (0-9) with exactly one symbol.

For instance, the chain `a'b&*x41` contains 4 identifiers: `a'b`, `&*`, `x`, and `41`.

## The case of the dot
The dot `.` is used for various purposes:
- as an identifier,
- ending a definition or statement,
- opening a module,
- separating an universal type quantification from a declaration.

To differentiate between the three usages, the following algorithm is used:
- if a letter-based identifier immediately (that is, with no space in between, including tabulation and line breaks) precedes the dot, and that this letter-based identifier is itself preceded by a question-mark `?`, and that we can expect a type declaration at the current place, then the dot is a separator of a universal quantification from its associated declaration.
- if a letter-based identifier immediately precedes the dot, and that the dot is immediately followed by an opening parenthesis `(`, a `|>` identifier, or a letter-based identifier, then the dot is seen as a module opening.
- otherwise, if the dot is part of a symbol-based identifier with more than one character, then it is an identifier.
- otherwise, the dot indicate the end of a declaration.

In particular, this means that the identifier `.` is forbidden, and `.|>` is to be avoided in most cases.

## Reserved identifiers
The list follows:
- `:=` (used in definitions),
- `::=` (used in type definitions),
- `:` (used in type declarations),
- `::>` (used in definition priorities),
- `|` (used in pattern-matching and type definitions),
- `?` (used in pattern-matching, argument declarations, and universally quantified types),
- `??`, `?!`, `??!`, and `?&` (used in argument declaration),
- `_` (wildcard),
- `|>` and `<|` (used for function application),
- `\` (nameless function),
- `->` (used in pattern-matching and nameless functions).

The following identifiers are also reserved for future use:
- `?:` (type argument),
- `?:&` (type-name argument).

