/- https://code.kx.com/q/wp/columnar-database/
/- Columnar database and query optimization

/trade table creation
trade:([] date:asc 1000000?{x(&)1<x mod 7}2019.12.01+(!)31;time:asc 1000000?09:30:00.000 + til 21600000; sym:1000000?`GOOG`AMZN`FB; price:1000000?10.; size:1000000?1000000);
update price:?[`GOOG=sym;100.+price;?[`AMZN=sym;200.+price;price]]from `trade;
`date xasc `trade;

/- Create Partition for trade table
{{(.Q.dd[hsym `$"/Users/utsav/db"]x,y,"/") set .Q.en[`:/Users/utsav/db;](delete date from select from y where date=x)}[x;]@'`trade`quote}@'distinct trade`date;

/- Quotes table creation
quote:([] date:asc 1000000?{x(&)1<x mod 7}2019.12.01+(!)31; time:asc 1000000?09:30:00.000 + til 21600000; sym:1000000?`GOOG`AMZN`FB; bid:1000000?10.; ask:1000000?10.; bsize:1000000?1000000; asize:1000000?10000000);

update bid:?[`GOOG=sym;100.+bid;?[`AMZN=sym;200.+bid;bid]]from `quote;
update ask:bid-(rand 0.01*(!)20) from `quote;



