Binary Data:
============

`: --> file handle

hsym -1! --> hsym `$"/file/path" /- sometimes we have a file with space or a file path having a variable in between, in that case we can go for hsym
hsym `$"/directory",(string variable),"/filepath" /- always enclose variable in parenthesis else it will break.

hcount -7! --> hcount `:/file/path /- to get the path of the file from the os

hdel (~) --> hdel `:/file/path /- to delete a file

hopen (<) --> hopen `:/file/path /- open an handle to a file

hopen (>) --> hclose `:/file/path /- close an handle to a file

Q supports two kinds of file formats
0 -> can be used to play around with text file
1 -> can be used to play around with binary file

text read/write a file
read0 --> read a text file
0: --> write a text file

binary read/write a file:
read1 --> read a binary file
1: --> write a binary file

read1 `:/Users/utsav/L set 10 20 30
q)`:/data/answer.bin 1: 0x06072a
q)read1 `:/data/answer.bin

Using Apply Amend:
==================
.[`:/data/raw; (); :; 1001 1002 1003] /- alternate of set
get `:/data/raw

q).[`:/data/raw; (); ,; 42] /- append to an existing file
get `:/data/raw

Save and Load:
Save is a better version of set which is used to save the list/table in a file where file name is to be same as list/table/dictionary are same.
say, we have a table t:
t:([] a:`a`b; b:til 2)
In order to save it using set, we will have to use
`:/file/path/t set t /- else we can use
save `:/file/path/t
Save serializes the table in a global variable to a binary file, having the same name as the variable.
Eg: with list
a:10 20 30
save `:/file/path/a

all versions of save can be performed using more general 0:
If we save the table with .txt extension then the table will be stored in a file as tab delimited.
save can be used to store

Quirks:
If a file is not created using set then it cannot be read using get. File could have been creted using handle.
q)get `:/Users/utsav/nl
'/Users/utsav/nl
  [0]  get `:/Users/utsav/nl


Write a file:
1. set
2. using handle --> eg. h: hopen `:/Users/utsav; h[10 20 30]; 6i[10 20 30];
3. save
4. neg[h] negative handle --> neg[h] [10 20 30] - to write a text file.
5.
