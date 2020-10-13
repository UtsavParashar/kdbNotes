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
