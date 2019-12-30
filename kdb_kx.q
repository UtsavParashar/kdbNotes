

Notes from Chapter 14: Introduction to kdb+
Foreign key doubts:
-------------------
Base table should be keyed.
type of keyed column in the base table should be same as the type of column in client table.
Base table cannot have more than one column as keyed.
Eg: bkt:([sym:`GOOG`AMZN`FB];px:100 200 300); /- base keyed table
    tf:([] sym:`bkt$`AMZN`FB`GOOG; vol:1000 2000 3000); /- table foreign
    select sym, sym.px, vol from tl

Link Column/Enumerate Column:
-----------------------------
Link columns are similar to foreign keys as the columns are linked here between table based on enumeration.
Base/Target table column is used to enumerate the column in client table.
Eg: bt:([] sym:`GOOG`AMZN`FB;px:100 200 300); /- base table
    tl:([] sym:`bt!(exec sym from bt)?`AMZN`FB`GOOG; vol:1000 2000 3000); /- table linked
    select sym, sym.px, vol from tl
Linked column is benificial over foreign key as:
1. The target can be a table or a keyed table.
2. The target can be the table containing the linked column.
3. Linked columns can be splayed or partitioned, whereas foreign keys cannot.

Link column can be used to implement a hierarchical structure in a table itself.The column pid is a link column that relates a row to its parent row.
q)tree:([] id:0 1 2 3 4; pid:`tree!0N 0 0 1 1; v:100 200 300 400 500)
q)select from tree where pid=0 / find children of root

Serializing and Deserializing:set and get -- whole table is loaded in memory
Storing and retrieving
