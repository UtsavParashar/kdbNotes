Iterators - Scan and Each are the cores of the accumulator and map iterators. The other iterators are variants of them.
Three kinds of iterations
1. Atomic iteration
--------------------
2+2 / atom + atom
2+ 1 2 3 / atom + list
1 2 3 + 1 2 3 / list + list

2. Mapping
-----------------
2.1 each
q)count each ("the";"quick";"brown";"fox")

2.2 peach - each parallel
q)count peach ("the";"quick";"brown";"fox")
3 5 5 3

2.3 Each Right - 
"abc",/:"xyz" 

2.4 Each Left
"abc",\:"xyz"

2.5 Each Prior - Transforms the output i.e output length == input length
/ Such functions whose input arg length == output length are called uniform function in kdb
q)-':[1 200 300] 
1 199 100

prior keyword could also be used
q)prior[-; 1 200 300]
1 199 100
q)(-) prior 1 200 300
1 199 100

2.6 case - ' or join each --> same as zip in python
q)(1 2 3),' 4 5 6
1 4
2 5
3 6

3. Accumulation - https://code.kx.com/q/wp/iterators/#accumulation
===============
In accumulator iterations the value is applied repeatedly, first to the entire (first) argument of the derived function, next to the result of that evaluation, and so on.
The number of evaluations is determined according to the value’s rank.

For a unary value, there are three forms:
Converge: iterate until a result matches either the previous result or the original argument
Do: iterate a specified number of times
While: iterate until the result fails a test

Converge - 
q){x*x}\[0.1]
0.1 0.01 0.0001 1e-008 1e-016 1e-032 1e-064 1e-128 1e-256 0
q)({x*x}\)0.1
0.1 0.01 0.0001 1e-008 1e-016 1e-032 1e-064 1e-128 1e-256 0

Do
q)5{x*x}\0.1 
0.1 0.01 0.0001 1e-008 1e-016 1e-032
q){x*x}\[5;0.1]  
0.1 0.01 0.0001 1e-008 1e-016 1e-032

While
q)(.001<){x*x}\0.1
0.1 0.01 0.0001
q){x*x}\[.0001<;0.1] 
0.1 0.01 0.0001

Syntax - function accumulator vaule(unary, list)
Eg 1: {x*x}\[0.1]
Eg 2: +\[2;3;4] or (+/)2 3 4
Eg 3: (+) scan 2 3 4 or (+) over 2 3 4

Brackets and Parentheses -
q)+\[3 4 5]
3 7 12
q)+\[100;3 4 5]
103 107 112

Notice that the derived function here is variadic: it can be applied as a unary or as a binary.

An iterator applied postfix derives a function with infix syntax.
This is true regardless of the derived function’s rank. For example, count' is a unary function but has infix syntax.
q)100+\3 4 5
103 107 112

*** So prefix application is usually better.
*** An infix function can be applied prefix as a unary by parenthesizing it.

q)(+\)3 4 5 6 7
3 7 12 18 25
q)sums 3 4 5 6 7 // preferred
3 7 12 18 25

q)(count')  ("the";"quick";"brown";"fox")
3 5 5 3
q)count each("the";"quick";"brown";"fox")  / better q style
3 5 5 3

Each, Each Parallel
====================
q)x:("the";"quick";"brown";"fox")
q)reverse x
q)reverse each x

each both - With a binary value, the iterator is sometimes known as each both.
You can think of it as a zip fastener, applying the value between pairs of items from its arguments.
q)2 1 2 1 rotate' x
"eth"
"uickq"
"ownbr"
"oxf"

q)sum peach 3?'5#10
15 13 18 9 7

each and peach works with monotonic funtions
q)count each ("the";"quick";"brown";"fox")     
3 5 5 3
q)each[count; ("the";"quick";"brown";"fox")]
3 5 5 3

each both can work with diadic, variadic functions
q)"o" in' ("the";"quick";"brown";"fox")
0011b

Each prior
q)(-':)100 101 105
100 1 4
q)(-) prior 100 101 105 / good q style
100 1 4
q)(+':)100 101 105
100 201 206

q)deltas 100 101 105
100 1 4
q)1+deltas 100 101 105
101 2 5
q)1_deltas 100 101 105
1 4
q){x,y}prior til 5
0  
1 0
2 1
3 2
4 3
Here we see that the first item, 0, is paired with 0N. The Join operator has no identity element, so it uses the argument til 5 as a prototype.
The zero left argument is the ‘seed’ – the  subtracted from the first item, 4. We can use another ‘seed’ value.
q)1 -': 4 8 3 2 2
3 4 -5 -1 0

Watch out Using a float as the seed shifts the type of the first item of the result. But only the first item: the result is no longer a vector, but a mixed list.


q)0.5 -': 4 8 3 2 2
3.5
4
-5
-1
0
q)type each 0.5 -': 4 8 3 2 2
-9 -7 -7 -7 -7h
q)differ 1 2 1 1 
1110b
q)differ
$["b"]~~':

Higher ranks
Each Parallel, peach, and each apply unary values. Each Left, Each Right, Each Prior, and prior apply binary values.
The Each iterator applies values of any rank.

The Each iterator applies values of any rank.


q)1 2 3 in' (1 2 3;3 4 5;5 6 7)
100b
q)ssr'[("mad";"bud";"muy");"aby";"umd"]
"mud"
"mud"
"mud"

Accumulating iterators
------------------------
There are two accumulating iterators (or accumulators) and they are really the same. The Scan iterator is the core; the
Over iterator is a slight variation of it.
Here is Scan at work with ssr.
q)ssr\["hello word."; ("h";".";"rd"); ("H";"!";"rld")]
"Hello word."
"Hello word!"
"Hello world!"
q)ssr/["hello word.";("h";".";"rd");("H";"!";"rld")]
"Hello world!"
q)ssr["abcd";"ab";"AB"]
"ABcd"

parscalsTriangle:{{(+)prior x,0}/[x;1]}