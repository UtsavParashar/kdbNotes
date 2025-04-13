data: ("DSFFFFFFFFFF"; enlist csv)0: `:C:/Users/Utsav/Downloads/500180.csv;
data,: ("DSFFFFFFFFFF"; enlist csv)0: `:C:/Users/Utsav/Downloads/500247.csv;
update month, vwap, vwapPct: 100*((vwap - prev[vwap])%prev[vwap]) by tick from (`month xcol 0!select vwap: deliQuantity wavg closePrice by date.mm, tick from data)

select closePricePct: avg 100*((closePrice - prev[closePrice])%prev[closePrice])  by date.mm, tick from data