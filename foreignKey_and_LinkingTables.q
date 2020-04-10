Foreign Key:
    A foreign key is one or more columns of a table whose values are defined as enumeration over the keyed column in keyed table.

    1. Foreign key in q enforces referential integrity(atleast in one direction) i.e the values in the foreign key columns must be present in primary key columns.
    Eg: kt:([id:`GOOG`AMZN`FB]; px:100 200 300);
        t:([] id:`kt$10?`GOOG`AMZN`FB`AAPL; vol:10?1000);
    Above example will throw cast error since `AAPL id of foreign key is not present in primary key of kt.

    2. Primary key must be keyed. In above example id column of kt table is keyed. If it's not keyed, then it will throw type error.

    3. When q sees the name of the keyed table in an enumeration domain it knows to use the list of key records.

    4. As in case of symbol enumeration,q looks up for index of each foreign value in the list of key records and, under the covers, replaces the field value with the index.Also as with symbols, the enumeration is displayed in reconstituted form instead of as the underlying indices. To see the underlying indices, cast to an integer.
    Eg: `long$t[`id] /- 0 2 2 0 2 0 2 0 1 2

    5. As always, the enumeration can be substituted for the original in normal operations.
    eg: kt:([id:`GOOG`AMZN`AAPL]; px:100 200 300); /- replaced `FB by `AAPL in the keyed table and hence it is updated in foreign table
    eg: `GOOG=t`id /1001010100b

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
        q)(t lj kt)~(select id, vol, id.px from t) /- 1b

    9. The implicit join with the dot notation is powerful and convenient when your tables are in normal form and there are multiple foreign key relations.
        Eg: select name.street.city.zip from residents.

