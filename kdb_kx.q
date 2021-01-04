ENUMERATIONS:
==============
Enumeration is a method of associating a data set with a set of distict values, commonly referred to as an enumeration domain. It is a method of data normalization and a technique to improve performance.
names:`Ramesh`Suresh`Chandu`Suresh`Ramesh`Maghu`Chandu;
name:distinct names;
enumName:`name$names;
In the above example we have a list of names with repeating values.If we were to save this list to disk, it would require us to save each symbol several times.Instead, if we create a list of distinct values contained in the long repetitive list - an enumeration domain - we can create an index association with it by using cast syntax.
We can see in the following code that the enumeration and the original list have the same values.
q)names=enumName /- 1111111b
However, they do not match since enumerations have their own types, ranging from 20-76. Since version 3.0, type 20 is reserved for enumerations against a domain named sym, so the first enumeration declared against any other name is type 21 and they increment from there.
q)names~enumName /- 0b
q)type names /- 11h
q)type enumName /- 20h
Since enumerations are directly linked to their domain, if we change a value in domain, it changes all corresponding values in the enumeration.
name[0]=`Ram




Foreign Keys:
-------------
A foreign key defines a mapping from the rows of the table in which it is defined to the rows of the table with corresponding primary key. Foreign keys provide refrential integrity. In other words, an attempt to insert a foreign key value that is not in primary key will fail.
We will consider two examples. In the first example we will define a foreign key explicitly on initialization.
sector:([sym:`IBM`MSFT`FDP]; ex:`N`CME`N; MC:1000 250 5000);
t:([] sym:`sector$`IBM`FDP`IBM`FDP`FDP`IBM; px:6?1f);
q)show meta t
It is imp to note that the sym column is now an enumeration over they keyed table domain of sector.
The general notion for a predefined foreign key is:
select a.b from c
where a is the foreign key
b is the field in the primary key table(sector)
c is the foreign key table(t)



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

t:([] sym:`GOOG`AMZN`GOOG`FB; px:10 20 11 30)
select from t where px=(max;px) fby sym
select by sym from t where px=max select max px by sym from t

Lists:
A list is an ordered collection of atoms or other types including lists. A list is known as an array in other languages. Given that kdb+ is a column oriented db and that a column is a list, the list is of great importance in this technology.
A one dimentional list is a collection of atom. Lists can be homogeneous or heterogeneous.
Passing a list to the monadic 'type' function will reveal the data type of that list.
Heterogeneous lists and multidimentional lists are always of type 0h.
Lists of lists can be created as can lists of lists of lists etc.
General syntax:
The general syntax of defining a list is
