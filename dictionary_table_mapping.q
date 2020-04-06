1. A table is transposed version of a dictionary, where while flipping only addresses are transposed but values remain same.

d: `a`c!((10 20 30);(40 50 60)) /- Dictionary
t:flip d /- Table
Equivalent table syntax:
t:([] a:10 20 30; c:40 50 60);

2. A keyed table is a dictionary of two tables.
kt:([] id:10 20 30)!([] px:100 200 300;vol:1000 2000 3000);
Equivalent keyed table syntax:
kt:([id:10 20 30]px:100 200 300;vol:1000 2000 3000);

