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

"8=FIX.4.4|9=178|35=8|49=A|56=B|1=accountA|6=229.6295|11=00000001|12=|13=|14=10000|15=GBp|17=100000005|19=|21=1|29=1|30=XLON|31=229.1|32=1850|37=|38=10000|39=2|41=|44=|48=VOD.L|50=AB|52=20131218-09:01:46|54=1|55=VOD|58=|59=1|60=20131218-09:01:46|10=197"

fixTbl:(uj/){flip fixTagToName[key d]!value enlist each d:getAllTags x} each fixMsgs