Foreign Key:
    A foreign key is one or more columns of a table whose values are defined as enumeration over the keyed column in keyed table.

    1. Foreign key in q enforces referential integrity(atleast in one direction) i.e the values in the foreign key columns must be present in primary key columns.
    Eg: kt:([id:`GOOG`AMZN`FB]; px:100 200 300);
        t:([] ids:`kt$10?`GOOG`AMZN`FB`AAPL; vol:10?1000);
    Above example will throw cast error since `AAPL id of foreign key is not present in primary key of kt.

    2. Primary key must be keyed. In above example id column of kt table is keyed. If it's not keyed, then it will throw type error.

    3. When q sees the name of the keyed table in an enumeration domain it knows to use the list of key records.

    4. As in case of symbol enumeration,q looks up for index of each foreign value in the list of key records and, under the covers, replaces the field value with the index.Also as with symbols, the enumeration is displayed in reconstituted form instead of as the underlying indices. To see the underlying indices, cast to an integer.
    Eg: `long$t[`ids] /- 0 2 2 0 2 0 2 0 1 2

    5. As always, the enumeration can be substituted for the original in normal operations.
    eg: kt:([id:`GOOG`AMZN`AAPL]; px:100 200 300); /- replaced `FB by `AAPL in the keyed table and hence it is updated in foreign table
    eg: `GOOG=t`ids /1001010100b

    6. Built in function fkeys can be used to get the column and corresponding primary table for it.
    q)fkeys t / id| kt
    fkeys internally uses .Q.fk and .Q.V.
    fkeys /-   k){(&~^x)#x:.Q.fk'.Q.V x}
    .Q.V - Convert from table to dict.
    .Q.fk - Checks if input parameter has foreign key
    fkeys in q /- {(where not null x)#x:.Q.fk each .Q.V x}

    7. Resolving a Foreign key - When we want to get the actual value instead of enumerated values - apply value function to the enumerated column.
     q)meta update value id from t

    8. In order to get the data from primary keyed table in the foreign key table, dot notation can be used.
        Eg: q)select id, id.px, vol from t
      i.e there is implicit left join between t and kt.
        q) t lj kt
        q)(t lj kt)~(select ids, vol, ids.px from t) /- 1b
        Foreign relation is performant and consumes less memory.
        q)\t:1000000 t lj kt
        4262
        q)\t:1000000 select id, vol, id.px from t
        1391

    9. The implicit join with the dot notation is powerful and convenient when your tables are in normal form and there are multiple foreign key relations.
        Eg:
        q)exch:([ex:`NSE`BSE] bid:100 200; ask:101 201)
        q)quote:([sym:`ITC`SBI] px:101 202; exc:`exch$`BSE`NSE)
        q)t:([] tick:`quote$`ITC`SBI`ITC; vol:1000 2000 3000)
        q)select tick, vol, tick.px, tick.exc, tick.exc.bid, tick.exc.ask from t


    10. How can we splayed a table with foreign key?
    Since the table is dependent on keyed table and since keyed table cannot be splayed hence the foreign key table cannot be splayed with its linkage to keyed table but by breaking the link from the keyed table, the foreign key table can be splayed.
    q)update value ids from `t
    q).Q.dpft[`:/Users/utsav/db;.z.d;`ids;`t]

    11. If a column of the table in not linked with foreign key during the initialization, then foreign key relation can be setup using update statement.
    q)kt:([sym:`GOOG`AMZN] px:100 200)
    q)t:([] sym:`$(); vol:`long$());
    q)update sym:`kt$sym from `t

    12. In effect, max 57 of the enumerated columns/foreign keys can exist in a database, else the session with throw elim error.
        Why 57? - Because columns with enum are provided type starting from 20h ranging till 76.
        q)`t insert (`AMZN;2000)
        q)type exec sym from t /- 20h

    13. Linking a foreign key column can be with one primary key at a time, trying to reference the foreign key with another column will dereference it from previous columns i.e it will delete the link from the first column with which foreign column was linked.
    q)trade:([sym:`GOOG`AMZN]; px:100 200)
    q)t:([] sym:`trade$`GOOG`AMZN`AMZN; vol:3?1000)
    q)select sym, sym.px, vol from t
    q)update sym:`quote$sym from `t
    q)select sym, sym.px, vol from t

Compound Foreign Key:
    1. Compound foreign key is a foreign key where the primary keys conists of more than one column and they are linked to one column of the foreign key.
    q)kt:([sym:`GOOG`AMZN; ex:`NSE`BSE] px:100 200)
    q)t:([] tick:`kt$((`GOOG`NSE);(`AMZN`BSE)); vol:1000 2000)
    2. Other way of doing same is:
    q)kt:([sym:`GOOG`AMZN; ex:`NSE`BSE] px:100 200)
    q)t:([] tick:`kt$(); vol:`long$())
    q)`t insert (`kt$(`GOOG`NSE);1000)
    3. Note in above both insertion and in compound foreign key, the foreign key type is of long type and not the symbol type because it stores the index value.

Remove a Foreign key:
    1. Simple foreign key - value can be used to remove a simple foreign key.
    update tick:value tick from `t
    This will replace the reference by the actual value of the tick and the link between the tables will be deleted.
    2. Below function can be used to remove more than one foreign keys from a table:
        removeKeys:{[x]
          v[i]:value each (v:value flip x)i:where not null(0!meta x)`f;
          flip (cols x)!v };
    
    3. Calling the value function on a complex foreign key column will remove the table mapping but will leave the previously enumerated column intact as a list of longs.

Linked Columns:
    Links can be applied to two or more tables whether the tables are in memory, splayed on disk or even in different kdb+ databases.

Simple Linked Columns:(NOT COMPLETE YET - https://code.kx.com/q/wp/foreign-keys/#simple-linked-columns)
    Using integers index with the Enumeration operator(!) we can establish the connection once we have mapped each row in referencing table(eq) to the corresponding row number in the referenced table(f)
    q)eq:([]sym:5#`A`B`C`D`E;size:5?10000;mtm:5?2.)
    q)f:([sym:`A`B`C]earningsPerShare:1.2 2.3 1.5;bookValPerShare:2.1 2.5 3.2 )
