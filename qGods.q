Functions:
There are various ways of manipulating atoms lists and dictionaries. Some of these are funtions.

Functions are of different types:
1. Atomic -
    These apply to atomic arguments and produce atomic results.
    Eg: 0>type{[ip] ip xexp 2}10

2. Aggregate (atom from list)
    0>type{[ip1; ip2] ip1 xexp ip2}[10;2]

3. Uniform (List from List)
    These extend the concept of the atomic function in that they apply to the lists. The count of the argument list equals to the count of corresponding result list.
    Unlike the atom function, an item of a uniform function result is not solely dependent on the corresponsing item of the argument. The relationship between the argument and result is more general.
    0>type{[ip] ip xexp 0^next ip}[(5;2)]

4. Other -
    Binary operations in mathematics are called dyadic function in q, and unary operations are called monadic functions.Eg '+' --> Dyadic and floor is monadic function.


IPC:
    Handles - Kdb+ processes can connect to any other kdb+ process on the same computer, network or even remotely.
    Firstly, the server must be setup on a port using \p or -p option(startup)
    Then the client uses the hopen function to connect.
    Eg: if one kdb+ instance was setup on port 5001 on a machine called hostname, then to connect to it from any other kdb+ process then following command is used.
        h:hopen `:hostname:5001

     The symbol `:hostname:5001 is called the communication handle. The integer (int) h is called the connection handle.
     THere is no need to identify the server is the client is running on the same machine. The communication handle in that case is simply
     h: hopen `::5001
     h: hopen 5001

     A remote server can be connected by its domain name or by its IPaddress say 127.0.0.1
     `:127.0.0.1:5001

     An open connection is closed with the hclose function.
     hclose h

Message Type:
    We can send messages to servers either synchronously or asynchronously.

Asynchronous Message -
    An asynchronous msg does not return a result. The expression of the async message completes as soon as the expression is executed. The message sent is then executed on the server side and no result is returned to the client.
    Async messages are also called set msgs because typically they cause changes in the state of the server, or set the value of the variable. For Eg - A delete or insert statement would often be sent asynchronously.

    Sending an async msg (neg h)x put x on the msg queue and (almost) never fails; the messages are then pushed out when the handle is ready to write. This ensures that there is not blocking and that the async messages don't get out until the sending process is idle.

    A way to gurantee a flush of the message queue is to follow the async msg with a sync msg eg h"".
    neg[h](::) known as blocking write will flush all async msgs as far as tcp; to gurantee all the way to the client would require a sync call. It should be noted that hclose does not flush by default which also avoids any blocking of the handle.

Synchronous Message -
    A sync message expects a response from the server.
    The expression that sends a sync msg waits for a response and returns it as its result. For eg - A select statement must be sent as a sync msg.
    Sync msgs are also called 'get' msgs because they expect a response.
    If u want to get a msg from a server, use a sync msg.

There are two forms of msgs which can be sent:
    String Form -
        A character string holding an executable expression.
        h"select avg px by time.u from trade"
        h"insert[`trade;(10:30:01;`dd;88.5;1625)]"

    Functional Form -
        We can also send list of a form
            h(function; param1; param2)
        The first item of the list is a char, string or sym atom holding the name of the function to be executed on the server. The other items are the arguments of the function call, in order. Eg. The above insert msg can also be phrased as a remote procedure call.
        h(`insert;`trade;(10:30:01;`dd;88.5;1625))

    A sync message is sent by executing the expession
        processhandle message
    And an async msg is sent by
        (neg processhandle) message
        neg[processhandle] message

    The following example sends sync character string message to the communication partner.
        h"select avg px by time.u from trade"
        h"insert[`trade;(10:30:01;`dd;88.5;1625)]"
        Since the insert msg was sent synchronously the result(the name of the modified table) is returned. This confirms that the insert was successful.
        However, if the client doesn't require a response, the insert msg can be sent async.
        (neg h)"insert[`tbl;(`s1;`p1;400)]"
        Execution of this msg returns immediately with no result.
        The function argument list form of the insert msg is
        (neg h)("insert";`tbl;(`s1;`p1;400))
        In most realistic situations the data to be inserted is not constant, but is either generated algorithmically or received from an external source.
        Consequently, the function-arguments message format is generally the more useful one because it does not require formatting the data into char strings.


Message Handlers -
    q has some built in message handlers; that is internal functions which are specifically called where the different type of ipc are performed. They all live in .z namespace and can be modified for specific uses.
    Generally, it can be quite useful to save the original function before overriding e.g something like
    orig_zpc:.z.pc
    new_zpc:{[] new functionality}
    .z.pc: {orig_zpc[]; new_zpc[]}

    IPC Functions:
        .z.pg: process get - of the message handler for sync msgs. The function gets called automatically whenever a sync msgs is received on a kdb instance. The parameter to the function is the message passed. By default, it is defined as {value x}, as in just execute the message received, though you can overwrite this to give it any customed action.

        .z.ps: process set - is equivalent to the message handler for async message.

        .z.ph: process http - if the message handler for http msgs.

        .z.po: process/port open - is the function called when the tcp connection is opened on a server.
            To see the handle when the connection to my process is opened define .z.po as:
                .z.po:{show "Connection opened by ", string h:.z.h}
            This functionality would obviously be useful for logging purposes; see who called what from where at what time etc

        .z.pc: process/port close - is called when the connection is closed.

        .z.pi: process/input - is called for any sort of input. Can be used for logging purposes.

        .z.pp: post-port - is called with a http post request.

        .z.pw: User authentication - is called after -u/-U checks but before .z.po when opening a new connection and lends itself to security. i.e who is accessing this q process. Default definition is always set to 1b(true), if it returns 0b then an `access error is returned.

        Within these message handlers, there are a number of variables you can make use of. Use .z.w to view the handle of a remote process that is connecting to the q process. This way IPC becomes a two-way process and knowledge of the remote process handle will enable the server q process tp send message too.
        Eg:
        .z.pg:{handle::.z.w; value x} // this will store the remote handle
        .z.pg:{show .z.w; value x}    // this will show the remote handle

        Others include .z.h - hostname of the connecting process
        .z.u - / username of the connecting process
        .z.a - / IP address of the connecting process

        Example - allow users to access only specific function on the server
        .z.pg:{if[not any `func1`func2 in `$string x; '`$"Restricted Access"]; value x};
        (Similarly for .z.ps)

        The above will allow only calls to functions func1 and func2
        h"update price:0f from `trade"
        'Restricted Access

    Another typical way to overwrite .z.pg is in a gateway process, one which takes results from different processes and aggregate them; for example one result from a HDB and another from an RTD:
    .z.pg:{res1: h_rtd"select from trade where sym=`FRST.L";                /- RTD Data
        res2: h_hdb"select from trade where date=2020.06.18, sym=`FRST.L"   /- HDB Data
        $[(98h=type res1) & 98h=type res2; res1 uj res2; ()]
    } /- error check result
    NB - The definition above is of limited use as the input x isn't used, but it illustrates the fact that it can be used to join together results from different processes and output them.

Close Handler -
    Either the server or client can close a connection. A message indicating the close is printed in the console of the other instance.
    .z.pc: is automatically called with the connection handle to the partner that closed the connection.
    If a client closes a connection then the server's .z.pc removes that client from its client list.

    If a server unexpectedly closes a connection i.e the server crashes; then you may want the client to reconnect. Typically this is done with a timer so that reconnection is attempted repeatedly until successful, or perhaps up to some max number of attempts.

    In the following example .z.pc resets the connection handle to 0 and sets the timer to 1second.

    The following function is defined in the client:
        .z.pc::{h::0; value"\\t 1000"; show "Connection Closed"}
    By setting \t to 1000, the timer is set hence the .z.ts function will be called automatically every second.
    We define .z.ts function as:
    .z.ts:{5001; show "Attempting to reconnect"; h::hopen `:if[h>0; value "\\t 0"; show "Reconnected"]}
    on each call the client attempts to reconnect. If successful, the connection handle will be assigned a positive integer(int) value. Additionally, the "If statement" in .z.ts resets the timer to 0 (as in turns it off) if the reconnection attempt is successful.

Attributes:
===========
Lists(and by extension, dictionaries and columns of tables) can have attributes applied to them. Attributes imply or enforce certain properties on the list which will aid searching in different situations.
A list can only have one attribute set - the last attribute applied will be the one which remains. Some attributes will also be lost upon modification.

Sorted - `s#
`s# mean the list is sorted ascending. If the list is explicitly sorted by asc(or xasc) then the list will automatically have the sorted attribute set.
a:asc 3 2 1 /- `s#1 2 3j
A list which is known to be sorted can also have the attributes explicitly set. q will check if the list is sorted, if it is not then the s-fail error will be thrown.
a: reverse b:3 2 1
`s#a /- `s#1 2 3j
`s#b /- 's-fail

The sorted attribute will be lost on an unsorted append. Otherwise, it will be maintained.
a:`s#1 2 3
a,:3 4
a /- `s#1 2 3 3 4j
a,:2 2
a /- 1 2 3 3 4 2 2j

It will also be lost on most deletes.
a:`s#1 2 3 4
a _: 1
a /- lost attribute - 1 3 4j

Searching in q on binary list is done by binary search, which is much faster than the usual linear search. The increases the speed on in, within, find etc and also min, max and med(which simply becames first, last and middle index respectively).

Parted - `p#
`p# means the list is parted - identical items are sorted contiguously.
The attribute can only be set by explicitly applying it. The will internally generate a dictionary mapping each element in the list to its first occurence. This will require some extra storage space, which will be worst case (all items unique) be n+ l*4 bytes, where n is the size of the list and l is the length. However, the worst case for storage overhead is when all items in the list are unique, and there will be no benifit to applying `p# to the list.
Applying `p to a list which is not contiguous will invoke a u-fail error.

a:1 4 4 2 2
`p#a /- `p#1 4 4 2 2j
b:1 4 4 2 2 1
`p#b /- u-fail

It will always be lost on modification, even if the modification preserves the parting.
a:`p#a /- `p#1 4 4 2 2j
a,2 /- 1 4 4 2 2 2j
a:`p#a /- `p#1 4 4 2 2j
a _: 1 /- 1 4 2 2j

When a parted list is searched, starting index of the element(s)to be found is looked up in the internal mapping. All occurences of the elements can then be retrived by one contiguous read. In memory, this gives little or no improvement over the other attributes. However, when the data is stored on disk this gives a massive performace improvement as disk head skipping is minimised. In kdb+ splayed databases it is usually to apply the parted attribute to the column which is searched most frequently.

Grouped: `g#
Applying `g# attribute mean that the list is grouped. An internal dictionary is built and maintained which maps each unique item to each of its indices, requiring considerable storage space. For a list of length l containing u unique items of size s, this will be l*4 + u*s bytes.
The attribute can be applied to any typed lists. It is maintained on appends, but lost on deletes.

a:`g#1 2 5 6 5 2 1 /- `g#1 2 5 6 5 2 1j
a,:5 /- `g#1 2 5 6 5 2 1 5j
a _: 0
a /- 2 5 6 5 2 1 5j

When a grouped list is searched, the indices of the elements to be found are retrieved from the internal mappings. All occurences of the elements can be retrieved. This greatly decreases retrieval time when data is stored in-memory. For on disk data the improvement is hard to quantify as the disk head will still skip.

Unique: `u#
`u# can be applied to a list of unique elements. If the list in not unique, a u-fail error will occur.
When a list is flagged as unique, an internal hashmap is created to each item in the list.
`u# is preserved on concatenations which preserve the uniqueness. It is lost on deletions and non unique concatinations.
a:`u#1 2 3 4
a,:5 6 7 /- `u#1 2 3 4 5 6 7j
a,:2 /- 1 2 3 4 5 6 7 2j
a:`u#1 2 3 4
a _: 0
a /- 2 3 4
Searches on `u# lists are done via a hash function, so become constant time.

Removing attributes: Attributes can be removed on applying `#.

Appropriate Use of Attributes:
The following are intended as general guidelines only. Points 1-3 are intended for in-memory applications. Fox maximum benifits, apply attributes to list which requires frequent searching.
1. If the elements of the list are unique, use `u#. This will produce fast, constant retrieval time. `u# should be applied to the key of a dictionary, or the key of a single key table which has length greater than 100. At approximately this point, has function becomes faster than searching a list of 100. Concatinations on dictionaries and single keyed tables will automatically preserve the uniqueness of the key.

2. If there are multiple occurences of each element and ample memory is available, apply `g#. Retrieval time will then be more dependent on the number of unique elements and the number of instances of the elements being looked up rather than the length of the list itself. A good example of using `g# is on the sym column (generally the instrument/element name) of kdb+.

3. If items are generally distinct and the data is static, the list could be sorted to have `s# applied. Also, if concatenations always preserve sort, `s# could be applied. Sorting will improve search time, although search time will still be dependent on the lenght of the list. This could be done in kdb+ tick to the time column provided the data received comes from one ticker plant only, and the ticker plant appends the time column to all sources of data.

4. `p# is used for on-disk data. Data can then be retreived for a whole set of data using contiguous reads, minimising disk head skipping.

Examples:
Applying sort decreases search time.
s: update `s#time from t:([] time:`#asc 09:00:00+1000000?(60*60*8))
\t do[10000;select from t where time within 10:00 12:00]
\t do[10000;select from s where time within 10:00 12:00]
\t do[100000; select from t where time=11:00:00]
\t do[100000; select from s where time=11:00:00]

Grouping decreases search time
g:update `g#sym from t:([] sym:1000000?100?`4)
\t:1000 select from t where sym=`icmf /- 1229j
\t:1000 select from g where sym=`icmf /- 2j
Retreival time with grouping in dependent on number of items returned rather than size of the table.
g:update `g#sym from ([]sym:1000000?100?`4),([] sym:2#`testsym)
\t:1000 select from g where sym=`testsym /- 1j
/- 100 times bigger table
g1:update `g#sym from ([]sym:10000000?100?`4),([] sym:2#`testsym)
\t:1000 select from g1 where sym=`testsym /- 1j
/- Same size as g1 but 200000 elements to retrieve
g2:update `g#sym from ([] sym:800000?100?`4),([]sym:2000000#`testsym)
\t:1000 select from g1 where sym=`testsym /- 1j

Constant time lookups with unique flag
n:1000000
d:((neg n)?`6)!n?1000
du:(`u#key d)!value d
(key d)[0 50000 99999] /- `bhkmib`chnaeh`cljfdj
/- in d, lookup time depends on location of element.
\t:10000 d`bhkmib /- 7
\t:10000 d`chnaeh /- 263j
\t:10000 d`cljfdj /- 514j
/- with unique flag, lookups are faster and constant time
\t:10000 du`bhkmib /- 8j
\t:10000 du`chnaeh /- 6j
\t:10000 du`cljfdj /- 9j

Importing Data:
Microsoft access files:
On windows it is possible to import from Microsoft Access(.mdb) file directly into a kdb+ session.
First two helper files are needed and both of them are available from www.kx.com. DOwnload www.kx.com/q/w32/odbc.dll and http://kx.com/q/c/odbc.k to you local q directory. Put the "odbc.dll" file into your q\w32 directory.
\l odbc.k
To load all tables from a single file, test.mdb:
.odbc.load `test.mdb
All the tables in the file will now be present in the top-level namespace of the q session. You can also open a handle to the file in-place.
db:.odbc.open `test.mdb
To get a list of avaiable tables
.odbc.tables db
To execute a sql statement against the file:
.odbc.eval[db; "Select * from table_name"]
And then, finally close the handle
.odbc.close db

Character-delimited text files:
Text files with field delimited by a particular character(for example - .csv file) can be imported using 0: function. This function takes two parameters - the file to be imported, and a description of how to read the fields within.
For example - a given file trade.csv with the following headers
Date, Time, sym, ex, price, size

Where the fields are separated by commas, the file can be imported with:
("DTSSFI";enlist ",")0:`:trade.csv

The first argument is a format desription, consisting of a list with 2 items - the first describes the number and type of fields to be read from the file. The capital letter type representation is used to specify the type of each field to be read from the file, and in this example is from left to right date, time, symbol, symbol, float, integer. A blank space in this list indicates a column should be skipped and not read, while an astrisk will read the literal characters as a string.
The second argument specifies the character that separtes fields in the file. In this example, we are reading from a comma delimited file, so we use "," as the delimiter. We have also used an enlist function to convert "," into a list. This specifies that the first line of the file contains the name of the columns, rather than actual date fields. These will be used as column names in the q table this function returns after reading the file. If we don't use enlist, every line on the file will be read as data.

Nested Lists from Test Files:
Text files containing nested lists can also be read using funtion 0:  Suppose we have a comma separated file with data such as:
    sym,time,depth
    IBM,10:10:21,23.2 23.1 22.1
    GOOG,11:10:21,123.2 123.1 122.1
    AMZN,09:10:21,223.2 223.1 222.1
The third column in this file should be read as a list of floats. Start by reading these fields as literal characters by using an asterisk as the format specifier.
Data: ("ST*";enlist",")0:file.csv
This will load the first two columns correctly, but the depth column is just a list of strings, rather than actual float values. We can extract the values with:
    Data[`depth]:"F"$vs[" "] each Data[`depth]
First we use the vs (vector from scalar) function on each item on the depth column of the data table to split the string of spaces, leaving us with an individual string for each float value.
The $ function is then called with the "F" parameter, which extracts float values from string arguments. This results in the correct list of lists of floats, which is then assigned back to the depth column of the Data table.

Fixed witdh Text Files:
The 0: function can also be used to read the file that use constant-width values to delimit fields instead of specific characters. The general format of the function is similar e.g ("ISF"4 10 4)0:`:file.txt
Again the first argument specifies the data format, and the second is a file handle.
The first half of the format argument is identical to the character-delimited usage seen above, giving a list of the types of each field in sequence. The second part gives the length in bytes of each of those fields in their respective orders.
The above example would mean to read a 4byte integer, a 10 byte symbol and a 4 byte float from the file.
It is also possible to read only a section of a file, The second argument to 0: can be extended from just the file handle to the list, giving the file handle plus offset and range parameters.
("ISF"4 10 4)0:(`:file.txt;19;72)
This will begin reading at byte 19 and continue to read 72 more bytes.
The read must start and end on a record boundary - here the offset of 19 indicates that we will skip a single 18 byte record(the 4byte integer, a 10 byte symbol and a 4 byte float identified in the first argument as comprising a single record adds up to 18bytes), and we will read 72 more bytes, or 4 whole records.

Binary Files:
The 1: function is used to read from binary files. Its usage is similar to fixed width of 0:
("ich";4 1 2)1:0x0041200FF00
will read the data on the right a 4-byte integer, a 1-byte character and a 2 byte short.

Very Large Files:
Sometimes you may need to read from a file that cannot fit in available memory. The .Q.fs will fetch chunks of a text file and apply a function you specify to them.
For example, to read in a very large csv file, and write the contents directly to a splayed table on a disk without ever holdind the entire file in memory:
.Q.fs[{`:data/t/ set .Q.en[`:data]("ISF";enlist",")0:x}]`:file.csv
Here the function
{`:data/t/ set .Q.en[`:data]("ISF";enlist",")0:x}
is applied to file.csv in sections, reading from each and saving them to disk.

Advanced Web Interface:
It is possible to customize your web interface for use with kdb+ sessions. Custom Java script can be stored and loaded to create bespoke functionality and look and feel to webserver displays.
Before coming to examples it is imp to mention that every http request which comes into a kdb+ session is handled by a function .z.ph from the .z namespace(c.f. IPC section). This function essentially allows a kdb+ process to be accessed over the web.

.z.ph: Also known as http get, this function handles synchronous http requests. There is no async version. The function takes(or is passed) two parameters:
    1. The request text eg. "select from trade where sym=`GOOG"
    2. Information on the web interface.
        For eg: the select in the browser will look like
        http://localhost:7001/?select%20from%20trade%20where%20sym=`GOOG
    This will be passed to .z.ph with the default settings
    x 0
    "?select%20from%20trade%20where%20sym=`GOOG"
    x 1
    `Host`Connection`Cache-Control`Upgrade-Insecure-Requests`User-Agent`Accept`Sec-Fetch-Site`Sec-Fetch-Mode`Sec-Fetch-User`Sec-Fetch-Dest`Accept-Encoding`Accept-Language`Cookie!("localhost:7001";"keep-alive";"max-age=0";,"1";"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.80 Safari/537.36";"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9";"none";"navigate";"?1";"document";"gzip, deflate, br";"en-GB,en-US;q=0.9,en;q=0.8";"_xsrf=2|292cf471|878a9a0caafcb9b5dfca54ec218a7a80|1602139570; username-localhost-8888=\"2|1:0|10:1603292930|23:username-localhost-8888|44:NjFmMWE3ZmQ5ODI4NDI4ZTkwZjIwMzBiNWExMWM4MTI=|e0f840fc7ef23b09adbc294dd7a8a606e0e9d272453f0c4fa5d92850de49ce28\"")
    "favicon.ico"
    `Host`Connection`User-Agent`Accept`Sec-Fetch-Site`Sec-Fetch-Mode`Sec-Fetch-Dest`Referer`Accept-Encoding`Accept-Language`Cookie!("localhost:7001";"keep-alive";"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.80 Safari/537.36";"image/avif,image/webp,image/apng,image/*,*/*;q=0.8";"same-origin";"no-cors";"image";"http://localhost:7001/?select%20from%20trade%20where%20sym=`GOOG";"gzip, deflate, br";"en-GB,en-US;q=0.9,en;q=0.8";"_xsrf=2|292cf471|878a9a0caafcb9b5dfca54ec218a7a80|1602139570; username-localhost-8888=\"2|1:0|10:1603292930|23:username-localhost-8888|44:NjFmMWE3ZmQ5ODI4NDI4ZTkwZjIwMzBiNWExMWM4MTI=|e0f840fc7ef23b09adbc294dd7a8a606e0e9d272453f0c4fa5d92850de49ce28\"")

The user can then use a combination of javascript and CSS to modify the display.
To use these files put them into a directory called html in the QHOME directory.
Besides modifying display custom user authentication can be written into the .z.ph logic thus creating secure web service applications.
Eg:
.z.ph:{.admin.check[`h;.z.u;.z.a;.h.uh x];.h.ph x}
Where .h.ph defines provides entry info to the style files

.q.k/.q.q:
==========
The .q.k file which comes with the kdb+ installation package. It contains the definitions for the keywords and functions which make up the q language, written in the bootstraped language k. There are a few exceptions to this - some functions like 'select', 'update' etc are natively implemented in C for speed.
As well as q keywords, .q.k contains some functions in the .Q namespace which are useful for q developers. Many of these are covered in the appropriate sections (see tables on disk for .Q.en, .Q.dpft, .Q.chk and the section on importing text for .Q.fs) some other miscellaneous functions are described below:

.Q.fu:
This function is used when we have an expensive monadic function, which we have to operate on a vector with repeating values. .Q.fu will perform the function on each unique, then recreate the result. Often the time saving can be significant:
s:10000000?`IBM.N`MSFT.O`AMZN.A
getex:{last ` vs x}
\t getex each s
\t .Q.fu[getex each]s

.Q.x12/.Q.j12
These functions can be used to encode and decode 10 character strings to long integers. Allowable characters are restricted to uppercase chars and numbers. Usage is as follows:
.Q.j12 "ABCDEFG123XYZ" /- -6463345209036409669j
.Q.x12 6463345209036409669 /- "ABCDEFG123XYZ"

.Q.x10/.Q.j10
These functions are similar to the x12 and j12 equivalent, but operate on 10 char lists. Because they hold fewer characters in the string, the availble universe of chars is larger - they can hold lower case characters.
.Q.j10 .Q.a /- -7301545714234745677j
.Q.x10 7301545714234745677j

q.q
The q language allows the user to customise it's behaviour by looking for a script for 'q.q' in the user $QHOME folder. Customization of .q.k is discouraged as it makes upgrading q version difficult. Instead, the users own functions and changes to existing q functions can be placed in q.q, which is loaded from .q.k after all the other q functions have been defined. Any function defined in the .q namespace are availble for use with infix notation. For eg. if q.q looked like:
    \c 20 150  /increase screen buffer
    .q.prepend:{y,x}
    Then from q console, the following would work
    2 3 4 prepend 1 /- 1 2 3 4j

    .q.ramesh:{y,x}
    10 11 12 ramesh 9

 Example of using .q.q to modify the web interface
 This example make use of .q.q to change the default layout of the standard kdb+ web browser session.
 Download the file dotk.k and the folder html from the following URL:
 https://code.kx.com/trac/browser/contrib/simon/doth
 Download doth.k to QHOME
 Add the following 2 lines to q.q
 \l doth.k
 .h.HOME "c:\\html"
 Note: Replace "c:\\html" with the path where you downloaded the html folder.
 Now all new q sessions when viewed through the web browser will make use of doth.k and html folder and will look different to the standard kdb+ web session.

q shortcuts (x!):
----------------
A number of shortcuts and functions exists in q to avoid repetition of common data manipulation. These shortcuts range from applying a quick key to a table (1!) without needing knowledge of column names, to helping produce informative log info(-3). For many, there is an equivalent function name that can be called to achieve the same end result. These shortcuts are provided to keep code as concise and efficient as possible, and are helpful for adhoc data manipulation and verification, when debugging a system.

The full list of shortcuts are detailed below:

0N! The standard output function can be used at any point in a function to print out a variable on the screen. After applying 0N! it returns the item being outputted, so you can continue to apply other functions to this item, unlike using show(see eg for clarification) which will always return null and so can no longer be used in the line of code eg:
    {0N!x+0N!y}[3;5]
 These are merely msgs to the screen. The result of the above function is still just 8, NOT a list 5 8 8.
 Using show within the line fails:
    {0N!x+show y}[3;5] /- 'type
 0N! is very useful when trying to debug code.

n! If n is a positive integer, applying n! to any unkeyed table will key the table with first n columns. Similarly 0! will make any table unkeyed. Note: Applying n! to a table does not enforce or check the key for uniqueness. Eg:
If applying n! to n columned table will throw 'length.

-1! Prepends a colon to the start of a symbol if it is not there already. This resulting symbol can be used to create a file handle eg
a:`$"/apps/kdb"
-1!a
-1!`:/apps/kdb
This is the same as the function hsym or {$[":"=first string x;x;`$":",string x]}

-2! Will return any attribute associated to the argument. Consider the example below:
list1 has no attribute
list1:1 2 3
-2!list1 /- `
list2 has unique attribute applied
list2:`u#1 2 3
-2!list2 /- `u
attr list2 /- `u
list3 has been sorted
list3:asc list1
-2!list3 /- `s
NB(Not bad) Only one attribute can be assigned to a variable
list4: asc `u#list1
-2!list4 /- `s
This is same as function attr(attr internally used 2! - attr~ ![-2j])

-3! This will return a string representation of the argument.
This function is very useful if you want to write data to a file, such as a log report eg
a:(1;2;`f;3e)
-3!a /- "(1;2;`f;3e)"
A working example:
Create a simple function to sum a list, and return an error string if it fails.
try_2_sum:{[a] @[sum;a;"The function sum has failed to run at ", (string .z.Z),". The input list was ",-3!a]}
a:(1;2;`f;3e)
try_2_sum[a]
a:1 2 3
try_2_sum[a] /- 6j
An error like this can be captured and subsequently written to a log file.

-5! will represent the functional representation of arguments
-5!"select last time, min qty by sym from trade where time>13:00:00.000" /- (?;`trade;enlist enlist (>;`time;13:00:00.000);enlist `sym!enlist `sym;`time`qty!((last;`time);(min;`qty)))
parse "select last time, min qty by sym from trade where time>13:00:00.000"
This is very useful when trying to build a dynamic query in functional form since it gives you a template to work from.
-5! is similar to function parse with a difference which can be seen in parse function definition
parse /- k){$["\\"=*x;(system;1_x);-5!x]}
parse "\\select last time, min qty by sym from trade where time>13:00:00.000"
-5!"\\select last time, min qty by sym from trade where time>13:00:00.000"

-6! Evaluate the functional form of query. This is same as eval function.
a:([] c1:1 2 3; c2:2 3 1; c3:3 2 3)
b:-5!"select from a where c1=c3"
-6!b

-7! Argument is a file location. This function will return the size of the file in bytes.
-7!`$":abc.q"
-7!-1!`$"abc.q"

-8! Returns the byte representation of a string.
-8!"select from trade" /- 0x010000001f0000000a001100000073656c6563742066726f6d207472616465

-9! Return the string representation from a byte sequence.
-9!0x010000001f0000000a001100000073656c6563742066726f6d207472616465 /- "select from trade"

-11! Used for streaming execution of a file. This function can be used in three ways:
-11!`:logfile /- will replay the entire file ~ equivalent to -11!(-1;`:logfile)
-11!(-2;`:logfile) /- will not replay the logfile, but rather return the number of valid lines in logfile.
-11!(n;`:logfile) /- will replay n line from a log file.

-12! Returns the hostname for a given ipaddress in integer format.
-12!-13!.z.h

-13! Returns ip address for a given hostname symbol
-13!.z.h

-15! Runs md5 encryption on a string
-15!"password123" /- 0x482c811da5d5b4bc6d497ffa98491e38

-16! Provides the reference count on that object
-16!0 /- 1i
-16!(),() /- 58i

Replaced:
-1! hsym
-2! attr
-3! .Q.s1
-5! parse
-6! eval
-7! hcount
-12! .Q.host
-13! .Q.addr
-15! md5
-20! .Q.gc
-24! reval
-29! .j.k
-31! .j.jd
-32! .Q.btoa
-34! .Q.ts
-35! .Q.gz
-37! .Q.prf0

Iterators:
Each Prior Scan Over
Each Prior "':" modifies a dyadic function but it created a monadic function. This new function applies the underlying function to each adjacent pair of items in a list. The function is uniform on its argument by pre-pending the first element of the input to the output.
+':[1 2 3] /- 1 3 5j
-':[1 2 3] /- 1 1 1j
prior [+;1 2 3] /- 1 3 5j
This is the result of 1(the first element joined with (1+2) and (2+3))
A more common usage is deltas which is defined as "-':"
deltas 100 200 300 500 1000 700 /-100 100 100 200 500 -300j
-':[100 200 300 500 1000 700] /- 100 100 100 200 500 -300j

Scan:
Modifying a Dyadic Function:
As an example take "*"(astrisk - multiplication Operator)
*\[1+til 5]

Modifying a Monadic function:
This produces a list of successive application of "f" to the initial value until it encounters 2 consecutive values the same.
A couple of simple examples
(neg\)1
(rotate[1]\)"abcd"
A more complex example is the Newton Raphson approximation of the square root of a number (obviously use the built in "sqrt" function but this serves as a good example)
/- This will the underlying function
foo:{[C;xn]xn-(1%2*xn)*(xn*xn)-C}
/- This will be the function we call
SQRT: {foo[x]\[x]}
In SQRT we create a PROJECTION foo[x] which creates a monadic function we can use for the scan. Let's look at a specific example with x=5
SQRT 5

You can see it gives us the successive approximations starting with a seed value of 5. The scan terminates here because we hit the limit of precision of floating point number.
We can also call f\ with 2 arguments. In this case the first x argument can be either integer number of iterations or a while condition applied to the result of f.
f: xexp[;2]
(f\)[5;2]
(f\)[1000>;2]
// Note in this case the result 256f still passes the while condition and so 65536f is also returned.

You can also use the q keyword scan.
(+)scan 1 2 3 4 5
scan[+;1+til 5]

Over:
Over(/) and Scan(\) are very closely related. Suppose we have a function f and an argument x then in general:
f/[x] = last f\[x]
(*/[1+til 5]) = last (*\)1+til 5
Or redefining  our SQRT function from above:
SQRT:{foo[x]/[x]}
SQRT 5

When over(/) is following a multivalent function then:
{x-y+z}/[35 40 45; 7 8; 9 11] /- 0 5 10j
Which is just:
({x-y+z}[{x-y+z}[35;7;9];8;11];
{x-y+z}[{x-y+z}[40;7;9];8;11];
{x-y+z}[{x-y+z}[45;7;9];8;11])

You can also use the q keyword "over"
(*) over 1+til 5
over[*;1+til 5]

Joins:
------
In a conventional db joins are primarily associated with tables, in which a join is used to extract data from lookup table based on a common column or key. In kdb+ the join operator can also be used with atoms/lists and dictionaries.
Atoms/Lists
The simplest join that can be considered uses the ',' primitive operator. It can be used to join (concatenate) atoms to create lists.
`a,1
"Hello ","World"
Lists to create generic lists,
`a`b`c,`d`e
(1;2 3;3),`q`w
The join results in a generic list unless all elements are of the same type.
type `a`b`c,1 2 3
type `a`b`c,`d`e
Each both - When combined with the `(each) the lists are joined sideways. In this case the list must have the same number of elements.
`a`b`c,'`d`e`f
`a`b`c,'1 2 /- 'length

Dictionaries:
The usefulness of the join operator on dictionaries is limited and behaves in the same way as an upsert into a keyed table.
The result of join on two dictionaries with unique keys is a simple merge.
(`a`b`c!1 2 3),`d`e!1 2
When the key is common to both dictionaries, the value of the key in right operand prevails.
(`a`b`c!1 2 3),`a`d!4 5 /- `a`b`c`d!4 2 3 5j
The behavior is similar when used with unkeyed and keyed tables.

Tables:
Using , with two unkeyed tables appends/inserts the data into the first table, and can be thought of as a vertical join of columns rather than the traditional lateral join of rows.
([] a:1+til 10; b:10?`GOOG`AMZN),([] a:11+til 10; b:10?`IBM`AMZN)
The column names must match for the join to work.
([] a:1+til 10; b:10?`GOOG`AMZN),([] a:11+til 10; c:10?`IBM`AMZN) /- The server sent the response: mismatch
But the column types do not. Should the types of the individual tables differ the resulting column type will be generic.
meta ([] a:1+til 10; b:10?`GOOG`AMZN),([] a:11+til 10; b:10?1+til 10)

When the tables are keyed the result is an upsert.
t1:([c1:1 2 3]c2:`a`b`c)
t2:([c1:1 4 5]c2:`d`e`f)
t1,t2

In summary, using , with unkeyed tables is the same is similar to an insert, but synonymous with an upsert when the tables are keyed.
Tables can be sideways joined as demonstrated with lists above:
t1:([] c1:1 2 3; c2:`a`b`c)
t2:([] c3:3 5 6; c4:`a`e`f)
t1,'t2

Inner Join(ij):
The simplest type of join which returns all rows in the source table which have an entry in the lookup table i.e the columns which are common in both tables.
Use - ij[unkeyed; keyed]
unkeyed ij keyed
([] a:10 20 30; sym:`GOOG`AMZN`GOOG) ij ([sym:`AMZN`FB] px:100 200)
This type of join is equivalent to a right outer join in standard sql.

Left Join(lj):
The left join is used to perform lookups on a keyed table. The joined columns do not have to have an entry in the lookup table.
Use - lj[unkeyed; keyed]
unkeyed lj keyed
([] a:10 20 30; sym:`GOOG`AMZN`GOOG) lj ([sym:`AMZN`FB] px:100 200)
The lj will return same number of rows as the source table.
In contrast to ij each row from source table in returned even if it does not have keyed entry in lookup table.

The primary key column of kt must be present in t if not a foreign key.
t:([]c2:`b`c`d; c3:`def`ghi`jkl)
kt:([c1:`a`b`c]c2:1 2 3)
t lj kt /- error since c1 is not present in t
This type of join is equivalent to left outer join in standard sql.

Union Join: uj
The union join is a vertical join of columns in contrast to the ij and lj previously mentioned.
Use: - uj[unkeyed; unkeyed]
     unkeyed uj unkeyed

([] s:4?`GOOG`AMZN; px:4?100) uj ([] s:4?`GOOG`AMZN; px:4?1000.; vol:4?10000)

If tables are keyed then uj behaves as upsert.
Use: - uj[keyed; keyed]
     keyed uj keyed
([s:4?`GOOG`AMZN]; px:4?100) uj ([s:4?`GOOG`AMZN`FB]; px:4?1000.; vol:4?10000)

If one of the table is keyed and another one unkeyed then it will throw type error.
([s:4?`GOOG`AMZN]; px:4?100) uj ([]s:4?`GOOG`AMZN; px:4?1000.; vol:4?10000)

Neither of the tables need to be keyed and columns with the same name need not have the same type.
kt:([] c1:`a`b`c; c2:1 2 3)
t:([] c2:`b`c`d; c3:`def`ghi`jkl)
t uj kt

Common cols are joined and values for any missing cols is filled with nulls.

One use of this could be timeorder data from two different tables in order to ascertain the sequence of updates across multiple tables. For example trade and quote tables could be joined as below:
show quote:([] time:09:29 09:29 09:32 09:33; sym:`FD`KX`FD`KX; ask:30.23 40.2 30.35 40.35; bid:30.2 40.19 30.33 40.32)
show trade:([] time:09:30 + til 6; sym:`FD`FD`KX`FD`KX`FD; price:30.43 30.45 40.45 30.55 41.0 31.; size:100 200 200 300 300 600)
It is not easy to see the sequence in which trades and quotes happened.
`time xasc uj[trade; quote]
This type of join does not have an equivalent in standard sql.
As-of join is also very powerful join to match trade and quotes data.
aj[`sym`time;trade;quote]

Asof Join(aj):
As the name may suggest it is mainly used to join columns with reference to time. It will return each row of the source table and any rows in the second table which have an entry before or at the same time based on the "key columns".
Use: aj[<col1..coln>;tab1;tab2]
It is primarily used to find the prevaling quotes at the time of a trade, or it will return each trade along with the quote 'as of' the trade time by symbol.
aj[`sym`time;trade;quote]
This type of join is again peculiar to kdb+.

Plus Join:(pj)
Again an example of a left outer join which will return all rows from the source table, looking up any common columns and summing their values. If the lookup column does not exist in the table for a particular to then the values are zero filled.
([] sym:`GOOG`AMZN`GOOG;a:10 20 30) pj ([sym:`AMZN`FB] a:100 200)

As the name may suggest, the column types in the lookup table must be ints, floats.
t:([] c1:`a`b`c`a`d`c; c2:100 200 10 20 30 600)
kt:([c1:`a`b`c] c2:1 2 3; c3:`alpha`beta`charlie)
t pj kt /- 'type
kt:([c1:`a`b`c] c2:1 2 3)
t pj kt
t:([] c1:`a`b`c`a`d`c; c2:100 200 10 20 30 600;c3:`alpha`beta`charlie`a`b`c)
t pj kt
Again cannot find an equivalent in sql. It can be thought of as an extension of the left outer join.

Foreign Key:
Performance wise the best way to create a join is using foreign key. First a lookup table is created called kt.
show kt:([c1:1 2 3]c3:`alpha`beta`charlie)
A foreign key can then be created by including the referencing the lookup table name in the creation on unkeyed table. A foreign key can be created between common columns c1 in t and kt as below:
t:([] c1:`kt$1 2 3; c2:`a`b`c)
meta t
The foreign key works as an enumeration and means that any value in t.c1 must be contained in the key of kt. An attempt to insert a non-enumerated value will result in cast error.
`t insert (4;`d) /- 'cast error
The columns for the lookup table can be accessed using the dot notation as below:
select c1, c2, c1.c3 from t
The foreign key is an example of an inner join since all values in t must have a lookup row in kt.
Care must be taken when using foreign keys, since a deletion from kt will upset the enumeration and may give unexpected results.
delete from `kt where c1=2
t
select  c1,c2,c1.c3 from t

Table Arithmetic:
A good place to start this section is with dictionaries and we can see how this can be applied to tables.
First of all we have our dictionary defined.
d:`a`b`c`d!10 20 30 40
The key of this dictionary is given by
key d
And the value
value d
A particular value in our dictionary is referred to by using the corresponding key to isolate it.
d`b or d[`b]/- 20
The values can be manipulated by using the arithmetic operator +-*%
d[`c]*2
2+d`b
The above simple manipulations are simply about extracting information from a dictionary. If one needs to amend the dictionary values then the amend formulation can be used:
d`c /- 30
@[`d;`c;-;2]
We get dict returned which indicates that the dictionary has been amended.
d`c /- 28
when experimenting with this type of operation it useful to know that you can omit the ` before the name of the dictionary and it isn't amended, but will display the potential new value
@[d;`c;+;2] /- `a`b`c`d!10 20 32 40j
d`c /- 30
This method can also be used to add items to a dictionary
@[d;`e;:;10] /- `a`b`c`d`e!10 20 30 40 10j

When dealing with tables we can first define our example tables
trade:([] time:0#0nt; sym:`;price:0n; size:0N)
and populate it
n:10
sym:`GOOG`FB`AMZN`MS
insert[`trade;(("t"$.z.Z)+n?1000000;n?sym;n?100.;n?100)]
`time xasc `trade
To get a particular columns from this table it is worth remembering than an unkeyed table is a dictionary of lists.
trade`size /- gets us the size column from the table.

This property makes it very easy for us to perform table arithmetic as we can use the same techniques as we use on dictionaries.
20*trade`size
changing the values of size col in trade table
trade[`size]*:20
trade

We can also use the @(amend) as before
@[trade;`price;-;2]

P.S trade changes will only be persisted using `trade

If the table is keyed
trade2: `sym xkey trade[0 1 2 4]
(getting relevant rows(unique sym) from our example table)

To isolate the relevant columns one can use one of the below techniques(whichever is more appropriate to the situation)
`GOOG`FB`AMZN`MS0
{trade2[x]`size}each sym
(0!trade2)`size
and manipulate the data as for unkeyed tables
20*(0!trade2)`size

Using combination of the above techniques a lot of table manipulation can be achieved.
Eg.: Dictionary Addition
(`a`b`c`d!10 20 30 40)+`a`b`d!10 20 30
similarly table addition
([x:`a`b`c] y:10 20 30)+([x:`a`b`d]y:10 20 30)

Tables must be keyed - and can compare with result of pj.

Slave and Slave Processes:
The kdb+ slave option is of most use when dealing with databases paritioned over multiple drives. (It may also be used to process farm CPU bound operations) Essentially a facility is prvided whereby a slave process may be assigned to a disk controller or suitable device or processing on incoming data can be performed on incoming data streams in tandem. This functionaly requires the setup of an appropriate database and the extra functinality provided by the s option is dependant on the hardware used in the current setup.
The most common use is in large TAQ database where partitions are spread across multiple drives and each drive is assigned a worker slave. Usually linear performance increases can be achieved with this methodology.

Functional/Dynamic Queries:
When q is asked to perform any query which it obtains in string form it first changes the input into its functional form and then executes it. Therefore despite the fact that there isn't any performance gain from using functional queries there are some situations where they are very useful( for example when column names are dynamically produced).
The functional form are:
?[t;c;b;a] /- for select
![t;c;b;a] /- for update
where:
    t is a table
    a is a dictionary of aggregates
    b is a dictionary of group bys
    c is a list of constraints

In all examples below we will use table t defined as below:
t:([] a:1 2 2 3 1; b:`e`f`g`h`i; c:10 20 25 30 15)

Functional Select:
So staring from the easiest case, functional version of "select from t" will look like:
?[t;c;b;a]
where
    c:() /- no constraints
    b:0b /- no group bys
    a:() /- to return all columns of t
or writing it as one expression:
?[t;();0b;()]

A very useful tool in writing more complicated functional queries is a parse function or its equivalent (-5!) which changes the string form of a query into function form.
When parse or (-5!) are executed they return the parse tree in k. The "," symbol is equivalent to enlist in q but is not recognised in q so it has to be converted to q using "enlist" where needed.
parse"select from t where a=2"
?[`t;enlist (=;`a;2j);0b;()]

The return of the parse function is returned as an enlisted list of functions (one element list, where the one element is a list of functions). The two commas in the one where clause case display the double enlisting:
parse"select last b by a from t where c<25"
?[`t; enlist (<;`c;25j);(enlist `a)!enlist `a;(enlist `b)!enlist (last;`b)]

In the multiple where clause case, only one (comma) is displayed as the one element can already be seen to be a list:
parse"select last b by a from t where c<25,c>10"
?[`t;enlist ((<;`c;25j);(>;`c;10j));(enlist `a)!enlist `a;(enlist `b)!enlist (last;`b)]

Functional Exec:
A simplified version of functinal select is functional exec. An example of the easiest case(returning values of one of the columns )is:
parse"exec b from t"
?[`t;();();enlist`b]
In case of querying multiple columns and grouping result by another column the aggregate parameter has to be specified as a dictionary and the group of parameters as symbol atom:
parse "exec b,c by a from t"
?[`t;();`a;`b`c!`b`c]

Functional Update:
Another form of functional query is update which again is analogous to the functional select.
parse "update a+3 from t where c=10*3"
![`t;enlist (=;`c;(*;10j;3j));0b;(enlist `a)!enlist (+;`a;3j)]

Functional Delete:
The last case to consider is functional delete which is a simplified version of update.
Its general form is:
    ![t;c;0b;a]
The aggregates argument(a) is a simple list of symbols with the names of columns to be removed:
parse "delete a from t"
![`t;();0b;enlist `a]

The list of constraints(c), which has the same format as in functional select and update, chooses which rows will be removed.
parse"delete from t where b=`g"
![`t;enlist (=;`c;(*;10j;3j));0b;(enlist `a)!enlist (+;`a;3j)]

ODBC:
Since version 2.3 kdb+ has come with s.k which allows sql queries to be run on a q process. There is also a sample database created using sql statements in file sp.s (both s.k and sp.s should ne in QHOME)

Any file with a .s extension is assumed to contain sql statements and can be loaded into a q session using \l.
The use of sql from a q prompt prefix the line with s), in the same way as k code is run by prefixing the line with k.

The default language from odbc or jbdc queries is sql and to run q directly over these interfaces the query needs to be prefixed with q).
If possible, it is better to use kdbc (c.java, c.cs, c.c) described elsewhere instead of ODBC or JDBC. KDBC is faster and more general.

Excel:
The purpose of this section is to demonstrate how data may be extracted from kdb+ via ODBC into Excel. We outline how to set up a connection to existing q session and execute queries in both the SQL format and q syntax.

Unix ODBC:
It is not possible to connect to a q process using ODBC from unix or linux as the ODBC driver provided from KX is for Windows only.
Importing Data via ODBC:


