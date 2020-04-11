Enumeration is basically divided into three forms:

1. ? -> Enum Extend -> best of all.
2. $ -> Enumerate ---> has certain limitations.
3. ! -> Enumeration -> Used for an edge case.(Case 4,5)

Case 1: Best Case - Work for both ? and $
    x:10?`GOOG`AMZN`FB;
    y:(?)x;
    en:(`y?x)=`y$x

Case 2: If all distinct values of x are not present in y then $ fails with cast error but enum extend with work as usual.
    x:10?`GOOG`AMZN`FB;
    y:`GOOG`AMZN; /- `FB is missing from x
    en:`y?x; /- Works perfectly and adds `FB to y
    y;
    en:`y$x; /- throws cast error

Case 3: Attributes are lost in $ but maintained in ?.
    x:`g#5?`GOOG`AMZN`FB; /- `g#`AMZN`GOOG`FB`GOOG`FB
    y:(?)x; /- `AMZN`FB`GOOG
    en:`y?x; /- `g#`AMZN`FB`AMZN`GOOG`FB
    en:`y$x; /- `AMZN`FB`AMZN`GOOG`FB /- Attribute is lost

Case 4: If y(domain) is not passed as symbol then enumerating it returns the index of the values of x in that case !(enumeration) can be used.
    x:`g#8?`GOOG`AMZN`FB;
    y:(?)x;
    en:y?x; /- 0 1 0 0 2 0 2 2j
    `y!en; /- `FB`GOOG`FB`FB`AMZN`FB`AMZN`AMZN

Case 5: When you want to enumerate the values of range(x) with its index then we can go for !.
    q)x:5?`GOOG`AMZN`FB
    q)y:(?)x
    q)z:`y$x
    q)z /- `y$`FB`GOOG`AMZN`AMZN`FB
    q)`int$`y$x /- 0 1 2 2 0i
    q)a:`y!0 1 2 2 0
    q)a /- `y$`FB`GOOG`AMZN`AMZN`FB
    q)z~a /- 1b

Case 6: Store distinct values in a file.
    x:`g#8?`GOOG`AMZN`FB;
    y:(?)x;
    `:en:`y?x /- a file named y is created in CWD with values `FB`GOOG`AMZN

Points To Remeber:
1. From an enumerated variable domain and values can be extracted using key and values function.
    key en; /- `y
    value en; /- `FB`GOOG`FB`FB`AMZN`FB`AMZN`AMZN

2. If all distinct values range are not present in domain then $ will fail with cast error but ? will work.

3. Attributes are lost in enumerate($) but preserved in (?) enum-extend.


