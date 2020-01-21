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

Quirks:
If a file is not created using set then it cannot be read using get. File could have been creted using handle.
q)get `:/Users/utsav/nl
'/Users/utsav/nl
  [0]  get `:/Users/utsav/nl


Write a file:
1. set
2. using handle --> eg. h: hopen `:/Users/utsav; h[10 20 30]; 6i[10 20 30];
