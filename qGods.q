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
This function is used when we have an expensive monadic function, which we have to operate on a vector with repeating values. .Q.fu will perform the function on each unique, then recreate the result. Often the time saving can be significant





