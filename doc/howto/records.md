Records are a usual construct in programming languages to denote an object with fields (sometimes called attributes or methods).
In Alcis, one simply use [modules](../reference/modules.md).
Indeed, Alcis modules are first-class (that is, they are usual values) and can be use for all the common record operations.

Let us consider an example: some kind of bank account storing a name and an amount.
```alcis
string.|>
integer.|>

bank_account ::= (|
		name : string.
		amount : integer.
	|).

(* We can then define accounts with this type. *)
account_a : bank_account.
account_a := (|
		name := " a ".
		amount := decimal.(42).
	|).

account_b : bank_account.
account_b := (|
		name := " b ".
		amount := decimal.(100).
	|).
```

Accessing an account field is done as any other module: `account_a.name` and `account_a.amount`.
Let us define a function to transfer money from one account to the other.
We would like not having to repeat the previously defined fields.
To this end, we use the module inclusion `.<|`:
```alcis
pair.|>

bank_account - integer --> bank_account : bank_account * bank_account.
?from - ?m --> ?to := (
		from' := (| from.<| amount := from.amount - m. |).
		to' := (| to.<| amount := to.amount + m. |).
		(from', to')
	).
```

A module can also be used in a pattern-matching:
```alcis
bool.|>

bank_account = bank_account : bool.
?ba = ?bb :=
	(ba, bb)?(
	| (| name := ?na. amount := ?aa. |), (| name := ?nb. amount := ?ab. |) ->
		na = nb /\ aa = ab
	).
```

Finally, modules can also be parameterised by a type:
```alcis
tree ?a ::= (|
		name : string.
		children : [ tree a ].
	|).
```

