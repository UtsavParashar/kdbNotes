aj - as of join

What is asof join? Why do we need it?
-------------------------------------
When we want to join two tables based on asof condition like bid/ask asof tradeprice in that case we go for aj.

syntax:
    aj[c1...cn;t1;t2]
        where c1..cn-1 is a symbol list of columns which are common to both tables.
        cn is a sortable column most time
        t1 is a table
        t2 is a simple table
    aj[`sym`time;trade;quote]

It returns:
    * a table with a result of left join from t1 and t2.
    * if column c1..cn-1 in t1 matches exactly along with column cn then the output is similar to lj(making t2 as keyed)
        q)t1:([] sym:`GOOG`AMZN;date:(.z.d-1;.z.d);px:100 200)
        q)t2:([] sym:`GOOG`AMZN;date:(.z.d-1;.z.d);vol:1000 2000)
        q)aj[`sym`date;t1;t2]~lj[t1;2!t2] /- 1b

    * if column c1..cn-1 in t1 matches exactly but column cn does not match exactly then the previous value and its corresponding values are considered.
        q)t1:([] sym:`GOOG`AMZN;date:(.z.d-1;.z.d);px:100 200)
        q)t2:([] sym:`GOOG`AMZN;date:(.z.d-1;.z.d-1);vol:1000 2000)
        q)aj[`sym`date;t1;t2]

    * if record of c1..cn-1 does not match between tables then the result has values of t1 and null value for t2.
        q)t1:([] sym:`GOOG`AMZN`IBM;date:(.z.d-1;.z.d;.z.d);px:100 200 300)
        q)t2:([] sym:`GOOG`AMZN;date:(.z.d-1;.z.d-1);vol:1000 2000)
        q)aj[`sym`date;t1;t2]


What is the difference between aj and aj0?
------------------------------------------
When we use aj then the sortable column cn, let's consider time column in the output is extracted from table t1 whereas in aj0 the time column will be the matched time from t2.
    q)t:([]time:10:01:01 10:01:03 10:01:04;sym:`msft`ibm`ge;qty:100 200 150)
    q)q:([]time:10:01:00 10:01:00 10:01:00 10:01:02;sym:`ibm`msft`msft`ibm;px:100 99 101 98)
    q)aj[`sym`time;t;q]
    q)aj0[`sym`time;t;q]

Performance of aj:
------------------
Order of search columns - Ensure that the first argument to aj, the column to search on are in correct order i.e `sym`time. Otherwise we will suffer a severe performance hit.
DONOT use - q)aj[`time`sym;t;q]

FOR SPEED, below attributes can be used:
IN MEMORY/DISK -
    t2[`sym] - grouped/parted
    t2[`time] - sorted based on sym
    i.e quote has `g#sym and time sorted within sym

Departure from this incurs a severe performance penalty.
Note that, on disk, the g# attribute does not help.
    t:([] sym:100?`GOOG`AMZN`FB; time:asc 100?(10:01:00 10:01:10 10:02:00 10:02:20 10:03:00 10:30:22); px:100?100.)
    q:([] sym:1000?`GOOG`AMZN`FB; time:asc 1000?(10:01:00 10:01:10 10:02:00 10:02:20 10:03:00 10:30:22); vol:1000?10000)
    q1:update `g#sym from q
    q1:update asc time by sym from q1

    q)\t:10000 aj[`sym`time;t;q]
    6166
    q)\t:10000 aj[`sym`time;t;q1]
    297
    q)\t:100000 aj[`sym`time;t;q]
    61288
    q)\t:100000 aj[`sym`time;t;q1]
    2855

Why applying grouped/parted attribute on sym and time sorted by sym on quotes table provides so much performance benifits in aj?
Since sym is grouped hence an internal hashtable is created for each symbol and as time is sorted within sym hence the pointer can directly go to the required last record which is mapped.
https://stackoverflow.com/questions/61856842/attributes-internal-working-in-aj-for-performance-benefits-in-kdb

Select from T2:
----------------
In memory, there is no need to select from t2. Irrespective of the number of records, use, e.g.:
aj[`sym`time;select … from trade where …;quote]
instead of
aj[`sym`time;select … from trade where …;
             select … from quote where …]

In contrast, on disk you must map in your splay or day-at-a-time partitioned database:
Splay:
aj[`sym`time;select … from trade where …;select … from quote]

Partitioned:
aj[`sym`time;select … from trade where …;
             select … from quote where date = …]

NOTE - Further where constraints
If further where constraints are used, the columns will be copied instead of mapped into memory, slowing down the join.

If you are using a database where an individual day’s data is spread over multiple partitions the on-disk p# will be lost when retrieving data with a constraint such as …date=2011.08.05. In this case you will have to reduce the number of quotes retrieved by applying further constraints – or by re-applying the attribute.










