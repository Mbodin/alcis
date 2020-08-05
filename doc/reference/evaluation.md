
The evaluation in Alcis is in call-by-need by default.

A function to enforce the evaluation of its argument beforehand marks it with `?!`.
The order of evaluation is then:
- evaluation of the function,
- evaluation of all the strict arguments of the function, from left to right.
- calling the function, all the other arguments being call by need.

