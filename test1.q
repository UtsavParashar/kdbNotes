stock:([sym:`s#`AAPL`C`FB`MS] sector:`Tech`Financial`Tech`Financial; employees:72800 262000 4331 57726);
trade:([] dt:`s#2015.01.01+0 1 2 3 3 4 5 6 6; sym:`C`C`MS`C`DBK`AAPL`AAPL`MS`MS; price:10 10.5 260 11 35.6 1010 1020 255 254; size:10 100 15 200 55 20 300 200 400);
fbTrades:([] dt:`s#2015.01.01+1 2 4; sym:`FB; size:1000; book:`A`B`A);

/ Generate 5 random numbers between 90 and 100
randomNumbers: 90 + 10?11

/ Print the random numbers
randomNumbers

/ Update the `price` column in the `trade` table based on the `sym` column
/ Example: Increase price by 10% for `sym`=`AAPL`
trade:update price:price*1.1 from trade where sym=`AAPL

/ Print the updated table
trade


f: {x: asc x where x>0;  1+x?x}

f: {if[all x<1;:1]; x: asc x where x>0;  b:1+first where not x=1+til count x; $[0N=b;1+last x;b]}
fn: {b: where not x=1+til count x; $[count b; 1+first b; 1+count x]}


f:{(1+til count x) = asc x where x > 0}

fn:{min(1+0|1 + til count x)except x}


exdata:(syms;count[syms]#101 102 103 104;count[syms]#`LSE`NDQ`HKSE`TSE;count[syms]#`GB`US`HK`JP )