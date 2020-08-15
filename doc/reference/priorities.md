
This document describes how the parser works, and in particular, how it parses terms and types.

# Declaring priorities

The parser is parameterised by priority orders.
Let us consider them first.

## Priorities between different operators

Two operators, for instance `+` and `*`, are by default non-comparable: no one is prioritary relative to the other.
In case of ambiguity, and error will be reported, which forces programmers to either add parentheses, or declare a priority.

Declaring priority is done through `::>`:
```alcis
_ * _ ::> _ + _.
```
This declaration means that every further occurrences of, e.g., `1 + 2 * 3` will be interpreted as `(1 + 2) * 3`, and not as `1 + (2 * 3)`.
Note that any such declaration means that more programs will be accepted, and thus that less checks will be performed by the compiler: always consider whether the declared order of operation is natural and well-known by programmers.

This declaration can be done either in the module signature or in the module implementation.
However, only the priority defined in the signature will be considered in other modules.
Furthermore, if a priority is declared in an implementation and not in a signature, only declarations placed after the priority command will consider them.

It is also possible to declare priorities between operators with the same notation, but from a different module, as in:
```alcis
_ + _ ::> other_module.(_ + _).
```
Similarly, it is possible to define priorities between two operators with different arity:
```alcis
- _ ::> _ - _.
```

FIXME: Double-check.
In the case where `_ + _` is ambiguous, it is also possible to add types in a priority declaration:
```alcis
integer * integer ::> integer + integer.
```
Note that if you need to precise the types, this means that the way some symbol work will depend on the types that they are refering to: this can be very confusing for programmers.

Priorities are transitive: if `_ * _ ::> _ + _` and `_ + _ ::> _ = _`, then there is no need to 

## Priorities between instances of the same operator

TODO

# The parsing algorithm

TODO: Rephrase.

1. Declaration breaks with `.`, as well as the various declaration keywords: `:`, `:=`, `::=`, and `::>`.
2. Parentheses `(`, `)`, `|>`, and `<|`.
3. Repeat until reaching an expression or until no progress happens:
	1. Determining what each symbol can mean in the context. In particular, notations with more than one symbol will check if the other symbols are present.
	2. All symbols whose only meaning is not a function.
	3. Determine the domain of each symbol left-over, that is the places that might be one of its argument.
	4. For all non-expression symbols:
		- Consider all functions that may take it as argument. If some are subsumed by a priority operator by all the others, remove it from the possibilities.
			Consider all left-over possibilities, checking if they might type-check.
		- If the symbol itself can be a function, consider this possibility.
This algorithm considers a lot of possibilities.
A term is only accepted if there is only one way to interpret the expression.

Note that this algorithm won’t change its conclusion depending on the symbol chosen in step 4.

As an example, consider the following program:
```alcis
basic.|>
integer.|>
decimal.|>
v := -18.
```
The expression `-42` might not seem like a complex expression, but as explained in [basics](basics.md), it actually features three identifiers: it is equivalent to `- 1 8`.
The symbol `-` can mean:
- The unit value `- : 1`,
- The unary operator `- integer : integer`,
- The binary operator `integer - integer : integer`. This one is immediately rejected as there are no left argument.
Similarly, `1` can mean:
- The value `1 : integer` defined in `integer`,
- The function `integer 1 : integer` defined in `decimal`.

This means that we can have the following interpretations for `-18`:
- `(- (1)) 8`, which type-checks and produces a value equivalent to `7`,
- `- ((1) 8)`, which is the one clearly intended by the programmer here,
- `((-) 1) 8`, which doesn’t type-check: `-` is part of the unit type, and the function `1` expects an integer.

No symbol is thus associated with a single value.
We consider the domains: the domain of `8` includes `1` because of the function `integer 8 : integer`, the domain of `1` includes `-` because of the function `integer 1 : integer`, and the domain of `-` includes `1` because of the function `- integer : integer`.
We consider `-`: it stands in `1`’s domain, we thus have a conflict between `- _` and `_ 1`.

There is a declaration stating that `_ 1 ::> - _`.
We thus consider first the case where `-` is an argument of `_ 1`.
As seen above, this doesn’t type-check.
This means that `-` is not ready for reduction.

We consider `1`.
We have seen that `1` can’t be a function in this position, and it can reduce to an integer.
It is in both the domain of `- _` and `_ 8`.
However, there is a declaration `_ 8 ::> - _`: `8` comes first.
It type-checks: `1 8` is reduced into an expression.

The domains are recomputed, and `1 8` is now in the domain of `- _`.
There is no other domains, but we still consider the case where `-` means the base unit value.
In this case, however, we don’t get a single expression at the end of the parsing: it is invalid.
The other possibility is that `-` represents the `- _` function, and it type-checks.
We thus return `- (1 8)`.

If there were to be any ambiguity, compilation would have stopped.
As you can notice, the algorithm may take some time on large expressions with complex relations. We hope that this case won’t happen in practice, but if you find parsing slow, consider adding parentheses.

