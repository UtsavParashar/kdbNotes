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

