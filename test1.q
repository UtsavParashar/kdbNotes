data: ("DSFFFFFFFFFF"; enlist csv)0: `:C:/Users/Utsav/Downloads/500180.csv;
data,: ("DSFFFFFFFFFF"; enlist csv)0: `:C:/Users/Utsav/Downloads/500247.csv;
update month, vwap, vwapPct: 100*((vwap - prev[vwap])%prev[vwap]) by tick from (`month xcol 0!select vwap: deliQuantity wavg closePrice by date.mm, tick from data)

select closePricePct: avg 100*((closePrice - prev[closePrice])%prev[closePrice])  by date.mm, tick from data;

til 10
(+) prior 0 1 2 3 4 5 6
(-) prior 0 1 2 3 4
(+':)1 1 2 3 5 8 13

{{(+)prior x,0}/[x;1]}[3]

iasc 1 3 2

t:([] sym:5#`goog; px:1 2 3 3 2)
update ret:ratios px by sym from t

select log ratios px from t
update diff: ((deltaspx)%prev px) by sym from t

select signum deltas px from t

3 sublist flip `a`b`c!(1 2 3;"xyz";2 3 5)

60 60 sv 1 1
