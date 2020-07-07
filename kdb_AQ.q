Lists:
Simple List - Homogeneous List - Known as vectors in Mathematics, Contiguous Memory locations. Eg:(1;2;3;4)
General List - Heterogeneous List - Eg - (`a;1;3f)
Singleton list - List which consists of only atom is known as Singleton list Eg: enlist`
Empty List - List which does not contain any element is known as empty list Eg: ()

Dictionary:
A dictionary is a mapping between a domain list(key) and a range list(value) -- All x axis values are list and all y axis values are range.
It is a foundation of tables(table is a list of dictionaries)
Dictionaries are type safe.
d:`a`b`c!(1 2 3;4 5 6;7 8 9);
d[`a;0]:3f /- 'type errpr since d[`a] is of long type hence assigning float value will throw type error.
Arithmatic operators act on range list(values) and not on domain list(keys).
d*2 /- It will double all the elements in range list(value) but not affect domin list(key) - `a`b`c!(2 4 6j;8 10 12j;14 16 18j)

Tables:
A collection of named columns or a list of dictionaries is called table.
Types of tables - Simple table, keyed table and empty table.
meta table returns c,t,f,a -> column, type, foreign keys, attributes
meta([] a:`s#1 2 3; b:`g#`a`b`c; c:`u#"abc")
    There are 4 possible attributes in a table: Sorted, Unique, grouped, parted
    * Sorted(`s#) -> The items in the list are in sorted order.
    * Unique(`u#) -> The items in the list are unique.
    * Grouped(`g#) -> Create a dictionary which maps each occurence of an element with their position.
    * Parted(`p#) -> Creates a dictionary which maps each occurence of an element to its first occurent on disk. parted in a list of grouped elements.
Tables with nested list shows types in capital i.e columns with String type has type C and column with char type has type c.
meta ([] a:((1 2);(3 4);(5 6);(7 8)))
c| t f a
-| -----
a| J

Virtual column i within a table represents the index of a row(in this case i has its own operation, it should not be assigned as column)
    select i from table

Foreign key is a field in one table, that uniquely identifies row in another table.
ti:([id:1 2 3 4]; sym:`a`b`c`d);
t:([] id:`ti$id; px:100 200 300 400)
meta t
select id, id.sym, px from t

Foreign key provides refrential integrity meaning that values in foreign key columns must present in primary key columns meaning before inserting a value in foreign key column first check that the value is present in primary key column.
Primary key of foreign key must be keyed.
Keyed table: is a dictionary mapping of a table of key records and a table of column records. It can be considered that keyed columns are a key of records and rest of the columns are corresponding values.
Like dictionaries arithmetic operations can be performed on keyed tables.
t:([a:`a`b`c`b`e] b:1 2 3 4 5; c:3 4 5 6 70);
t1:([a:`a`b`c`b] b:10 20 30 40; c:30 40 50 60);
t+t1

With unkeyed tables we can perform arithmetic operation if the table consists of numeric fields and row counts match else it throws length error.
t1:([] a:1 2 3 4; b:10 20 30 40);
t2:([] a:10 20 30; b:100 200 300);
t1+t2

Extract rows and columns from tables
t1[2] /- fetch 2nd row for each column
t1[`a] /- fetch column a from the table t1


