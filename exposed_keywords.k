/- k - references
+ - flip --> (+)(sym:`A`B`C; px:3?100)
# - count --> (#)20 30 40
& - where --> l(&)l in m
| - reverse --> (|)"string"
* - first --> (*)20 30
= - group --> (=)"missisippi"
_ - floor --> (_)15%4
? - distinct/unique --> (?)40 20 30
@ - type --> (@)10 20 30
~ - not --> (~)0b~1b
~ - hdel --> (~)`:./sym1
$ - string --> ($)0b~1b
^ - null --> (^)0n
- - neg --> (-)10
! - til --> (!)5
! - key --> (!)`A`B`C!10 20 30
. - value --> (.)`A`B`C!10 20 30
. - get --> (.)`:./sym2
< - up(iasc) --> /index value from lowest to highest (complete function is written down from asc)
> - down(idesc) --> /complete function is written down
< - hopen --> h:(<)`::5001
> - hclose --> (>)h
% - inv --> (%)10
, - enlist --> (,)5


/- functions definitions
{(*)1?x} - rand --> {*1?x}100
{`s#x@(<)x} - asc --> {`s#x@(<)x}10 8 6 29
{x@(>)x} - desc --> {x@(>)x}10 8 6 29
(-)(_)(-) - ceiling --> (-)(_)(-)3.14
(<)(<) - rank --> (<)(<)2 3 1 2 4