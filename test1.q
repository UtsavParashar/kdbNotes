stock:([sym:`s#`AAPL`C`FB`MS] sector:`Tech`Financial`Tech`Financial; employees:72800 262000 4331 57726);
trade:([] dt:`s#2015.01.01+0 1 2 3 3 4 5 6 6; sym:`C`C`MS`C`DBK`AAPL`AAPL`MS`MS; price:10 10.5 260 11 35.6 1010 1020 255 254; size:10 100 15 200 55 20 300 200 400);
fbTrades:([] dt:`s#2015.01.01+1 2 4; sym:`FB; size:1000; book:`A`B`A);

/ Generate 5 random numbers between 90 and 100
randomNumbers: 90 + 10?11

/ Print the random numbers
randomNumbers

/ Update the `price` column in the `trade` table based on the `sym` column
/ Example: Increase price by 10% for `sym`=`AAPL`
trade:update price:price*1.1 from trade where sym=`AAPL

/ Print the updated table
trade

/ Difference between `peach` and `.Q.fc` in kdb:
/ `peach`: Parallel each. It applies a function to each element of a list in parallel using multiple threads.
/ `.Q.fc`: Concurrent function execution. It applies a function concurrently to a list of arguments, useful for batch processing.

/ Example using `peach`
resultPeach:{x*x} peach til 5  / Squares each number in parallel

/ Example using `.Q.fc`
resultFc:.Q.fc[{x*x}; til 5]  / Squares each number concurrently

/ Print results
resultPeach
resultFc

