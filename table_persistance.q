A table can be persisted in 4 ways:

1. Serializing Tables
2. Splaying Tables
3. Partitioning Tables
4. Segmenting Tables

======================
1. Serializing Tables:
======================
    NOTE: THE LIMITATION TO USING A SERIALIZED TABLE OR KEYED TABLE IS THAT, BEHIND THE SCENES, THE OPERATIONS LOAD IT INTO MEMORY AND WRITE IT BACK OUT. AMONGST OTHER THINGS, THIS MEANS THAT ANYONE WANTING TO WORK WITH IT MUST BE ABLE TO FIT IT INTO MEMORY IN ITS ENTIRETY.

    1. It is possible to persist any table(or keyed table) using the general q serialization/deserialization capability using set and get.
    `:/Users/utsav/db/t set ([] a:10 20 30; b:20 30 40);
    `:/Users/utsav/db/t set ([] a:`abc`def`ghi; b:20 30 40)

    2. We can serialize the referencing foreign column table and the referenced keyed table and bring them back into memory.
    q)kt:([sym:`GOOG`AMZN`FB]; px:20 30 40); /- referenced keyed table
    q)`:/Users/utsav/db/kt set kt
    q)t:([] sym:`kt$5?`GOOG`AMZN`FB; vol:5?10000) /- referencing foreign column table
    q)`:/Users/utsav/db/t set t

    3. We can operate on serialized table by loading them into memory using get or \l.
    q)t:get `:/Users/utsav/db/t
    q)\l /Users/utsav/db/t

    4. We can perform a query on a serialized table using by specifying the file handle as the table name.
    q)select from `:/Users/utsav/db/t where sym=`GOOG


    5. Similar operations can be done on keyed tables.
    q)`:/Users/utsav/db/kt set ([sym:`GOOG`AMZN`FB] px:10 20 30)
    `:/Users/utsav/db/kt
    q)`:/Users/utsav/db/kt upsert (`GOOG;11)

  ISSUES WITH SERIALIZING TABLES:
    1. The entire table must fit into the memory on each user's machine.
    2. Operations against persisted table will be slow due to reloading the entire table each time.

==================
2. SPLAYING TABLES:
==================
    When a table is too large to fit into the memory as a single entity,we can persist its components into a directory. This is called splaying of tables because the table is pulled apart into its constituent columns.
    Splaying solves the memory/reload problem because a splayed table is mapped into memory, columns are loaded on demand then memory is released when no longer needed. Tables with many columns benifit from splaying since most queries refer to a handful of columns and only those columns will be loaded.
    A splayed table is persisted as a directory with table's name and the serialized files in that directory are columns.
    The directory consists of a .d file which maintains the sequence of the columns in the table. This is the only metadata stored in kdb+; all other metadata is read from directory and file names.

    1. Creating splayed tables is same as serializing tables with a difference that in splayed table the file handle must have an additional front slash.
    q)`:/Users/utsav/db/t/ set ([] v1:10 20 30; v2:1.1 2.2 3.3)
        NOTE that we cannot set symbol columns directly else we will get 'type error.

    2. We can also create splayed tables using upsert or amend at.
    q)`:/Users/utsav/db/t/ upsert ([] v1:10 20 30; v2:1.1 2.2 3.3)
    q).[`:/Users/utsav/db/t/;();,;([] v1:20 30; v2:1.1 2.2)]

    3. Reading the constituents of the file in splayed directory using get demonstrates that they are simply q entities.
    q)get `:/Users/utsav/db/t/.d
    q)get `:/Users/utsav/db/t/v1

    4. Manually we can splay the table as:
        q){(hsym `$"/Users/utsav/db/t/", string x) set t x}each cols t
        q)`:/Users/utsav/db/t/.d set cols t
        Using this we can even splay the symbol columns without enumerating them
        Above can be checked using
        q)meta get `:/Users/utsav/db/t

    RESTRICTIONS FOR SPLAYED Tables:
    1. Tables can be splayed, keyed tables cannot. The day is saved using linked columns which can be persisted. - https://stackoverflow.com/questions/61157522/why-cant-keyed-table-be-splayed-in-kdb
    2. Only columns of type simple lists or compound lists can be splayed. By compound list we mean a list of simple list of uniform types eg. String.
    3. All symbol columns must be enumerated.

    SPLAYED Tables with symbol columns:
    The convention for symbol columns in splayed (and partitioned) tables is that all symbol columns in all tables are enumerated over the list sym, which is serialized into the root directory.

    1. There are many utilities to splay a table with symbol columns, .Q.en is one of them.
    .Q.en has two parameters, first being file handle to the root directory where the sym file is to be placed and the second parameter is a table with symbol columns which needs to be enumerated.
    We can use .Q.en even if there is not symbol column in kdb.
    `:/Users/utsav/db/t/ set .Q.en[`:/Users/utsav/db;t]
    `:/Users/utsav/db/t/ set .Q.en[`:/Users/utsav/db;]t /- Projected form

    NOTES:
    1. If there is a sym list in memory it is overwritten.
    2. If there is a sym list on disk, it is then locked and loaded in memory.
    3. If no sym list exists in memory or on disk an empty one is created.
    4. All symbols in all symbol columns of the table are conditionally enumerated over the sym list in memory.
    5. Once the enumeration is complete the sym list in memory is serialized to the root and the file is unlocked.

    Manually do the enumeration: https://stackoverflow.com/questions/61295947/usage-of-amend-to-create-sym-vector-manually-in-kdb
    q)t:([] s1:`a`b`c; v:10 20 30; s2:`x`y`z)
    q)`:/Users/utsav/db/t/ set @[t;exec c from meta t where "s"=t;`sym?]

    2. We can splay a compound column like string or any other column with more than one type.
    q)`:/Users/utsav/db/t/ set ([] c:(1;1,1;`1))
    q)`:/Users/utsav/db/t/ set ([] ci:(1 2 3; enlist 4; 5 6); cstr:("abc";enlist"d";"ef"))

    3. We can observe that two or more files created in case of compound columns. Where the #(sharp) file contains the binary data of the original list in flattened form and non sharp file is a serialized q list of integers representing the length of each sublist in the original list.
        The purpose of writing compound columns as two files is to speed up operations against them when the splayed table is mapped into memory. Of course, the processing won’t be as fast as for a simple column, but it is still plenty fast for most purposes.
        One question that always arises when designing a kdb+ database is whether to store text data as symbols or strings. The advantage of symbols is that they have atomic semantics and, since they are integers under the covers once they are enumerated, processing is quite fast. The main issue with symbols is that if you make all text into symbols, your sym list gets enormous and the advantages of enumeration disappear.
        In contrast, strings do not pollute the sym list with one-off instances and are reasonably fast. The disadvantage is that they are not first class and you must revert to teenage years by using like to match them.

    RECOMMENDATION:
    Only make text columns into symbols when the fields will be drawn from a small, reasonably stable domain and there is significant repetition in their use. When in doubt, start with a string column. It is much easier to convert a string column to symbols that it is to remove symbols from the sym list.

    4. meta is described based on first row of the table.
    q)meta ([] c:(1 2 3 ;1,1;`1))
    c| t f a
    -| -----
    c| J

 Basic Operations on Splayed Tables:
 -----------------------------------
 q)t:([] sym:10?`GOOG`AMZN`FB; px:10?100.; size:10?10000)
 q)`:/Users/utsav/db/t/ set .Q.en[`:/Users/utsav/db;]t

    delete t from `. /- so that it can be loaded and worked upon

1. Table can be loaded in two ways:
    q /Users/utsav/db/t
    \l /Users/utsav/db/t
    Interestingly, it is called loading the table but actually none of the table are brought into the memory in this step.

2. The illusion that the table is actually in memory is convincing, many fundamental table operations work on on splayed tables like:
    \a
    tables[]
    meta t
    cols t
    type t
    count t

3. We can extract columns using dot(.) notations from a splayed table along with symbol indexing.
    t.sym /- dot notation - `GOOG`AMZN`FB`AMZN`FB`GOOG`GOOG`FB`GOOG`AMZN
    t`sym /- symbol indexing - `GOOG`AMZN`FB`AMZN`FB`GOOG`GOOG`FB`GOOG`AMZN

4. We can index records from splayed tables.
    t[0]
    t 0
    t@0

5. We can run both select and exec on splayed tables.(This is in constrast with partitioned tables where we can use only select).
    select first px from t
    exec from t
    exec first px from t
    first exec px from t

Operations on a splayed directory:
----------------------------------
1. The table operations against the file handle of a splayed table are:
    select, exec, xasc, `attr#,

    select from `:/Users/utsav/db/t
    exec from `:/Users/utsav/db/t
    `sym xasc `:/Users/utsav/db/t
    @[`:/Users/utsav/db/t;`sym;`p#]
    \l /Users/utsav/db/t
    meta t

2. If we update a table then it's affect is visible only in the workspace and not on the disk.
    t:([] sym:10?`GOOG`AMZN`FB; px:10?10.; vol:10?1000);
    `:/Users/utsav/db/t/ set .Q.en[`:Users/utsav/db;t]
    delete t from `.
    \l /Users/utsav/db/t
    update vol:100000 from `t where px<2
    \l /Users/utsav/db/t
    t

    Hence an imp poing about KDB, IT IS NOT POSSIBLE TO USE BUILD IN OPERATIONS TO UPDATE DATA PERSISTED IN SPLAYED TABLES.
    You read that correctly. Kdb+ is intended to store data that is not updated or deleted once it has been written. We shall see in the next section how to append to a splayed table, which makes it possible to process updates and deletes in a bitemporal fashion, but this capability is not available out of the box.

Appending to a splayed tables:
------------------------------
1. Insert does not work with splayed tables, but in order to append rows to a splayed table on disk, we can use upsert this is because upsert behaves as insert in case of non-keyed tables and keyed tables cannot be splayed.
    `:/Users/utsav/db/t/ set .Q.en[`:/Users/utsav/db;]([] s1:`a`b`c;v:10 20 30; s2:`x`y`z);
    `:/Users/utsav/db/t/  upsert .Q.en[`:/Users/utsav/db;] ([] s1:`d`e; v:40 50; s2:`u`v);
    `:/Users/utsav/db/t/  upsert .Q.en[`:/Users/utsav/db;] enlist `s1`v`s2!(`f;60;`t);
    `:/Users/utsav/db/t/  upsert .Q.en[`:/Users/utsav/db;] flip `s1`v`s2!flip ((`g;70;`r);(`h;80;`s));
    \l /Users/utsav/db
    select from t

2. Hence, upsert can be used to build large splayed tables incrementally. Below example can be used to splayed table step by step as batches of new records arrive.
    fbatch:{[rt;tn;recs] hsym[`$rt,"/",tn,"/"] upsert .Q.en[hsym `$rt;]recs};
    fdayrecs:{([] dt:x; ti:asc 100?24:00:00; sym:100?`ibm`aapl; qty:100*1+100?1000)};
    pappday:fbatch["/Users/utsav/db";"t";];
    pappday fdayrecs 2020.05.01;
    pappday fdayrecs 2020.05.02;
    pappday fdayrecs 2020.05.03;
    \l /Users/utsav/db
    select from t

Manual operations on a splayed directory:
-----------------------------------------
1. Though there are no built in operations to update splayed tables on disk, we can perform such operations by manipulating the serialized files.

`:/Users/utsav/db/t/ set ([] ti:09:30:00 09:31:00; p:101.5 33.5)
`:/Users/utsav/db/t/p set .[get `:/Users/utsav/db/t/p; where 09:31:00=get `:/Users/utsav/db/t/ti; :;42.0]
\l /Users/utsav/db
select from t




