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
    q)kt:([sym:`GOOG`AMZN`FB]; px:20 30 40);
    q)`:/Users/utsav/db/kt set kt
    q)t:([] sym:`kt$5?`GOOG`AMZN`FB; vol:5?10000)
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
