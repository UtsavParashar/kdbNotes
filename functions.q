/Bhagwan ka Q
There are many types of functions.

Atomic - These apply to atomic arguments and produce atomic results.
Eg: 0>type {[n] n xexp 2}[10] /1b

Aggregate - Results atom from argument list
Eg: 0>type{[n;m] n xexp m}[10;2] /1b

Uniform - list from list
These extends the concept of atom functions in that they apply to the lists. The count of the argument list is same as count of result list. Unlike at atom function, an item of a uniform function result is not solely dependent on the  correspnding item of the argument. The relationship between the argument and the result is more general.
Eg: 0>type {[n]n xexp 0^next n}(5;2)

Dyadic Funtion - Binary operation in mathematics are called dyadic function in q. Eg: + /+[2;3]


Monadic Function - Unary operation are called Monadic funtion. Eg:
type /- type 10

Functions available in kdb:
1. Absolute Value - abs x

