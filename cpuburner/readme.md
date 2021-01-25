## CPU burner

Make sure you have JDK properly installed, then simply

```
make run
```

then you should be able see the results similar as follows:

```
Starting 2 threads
[0] Calculations per second: 12508198 (6254721.50 per thread)
[1] Calculations per second: 13182346 (6591212.00 per thread)
[2] Calculations per second: 13523979 (6762034.00 per thread)
[3] Calculations per second: 13142227 (6571148.50 per thread)
[4] Calculations per second: 13605674 (6802877.00 per thread)
[5] Calculations per second: 13525095 (6762583.00 per thread)
[6] Calculations per second: 13466362 (6733225.50 per thread)
[7] Calculations per second: 13531765 (6765925.00 per thread)
[8] Calculations per second: 13473358 (6736720.00 per thread)
[9] Calculations per second: 13307777 (6653944.00 per thread)
[10] Calculations per second: 13397817 (6698959.50 per thread)
[11] Calculations per second: 13536385 (6768248.00 per thread)
[12] Calculations per second: 13418748 (6709426.00 per thread)
[13] Calculations per second: 13098367 (6549221.00 per thread)
[14] Calculations per second: 13605714 (6802895.00 per thread)
```

You may want to change number of threads in `makefile` according to your testing scenario

```
threads = 2
```

### Clean the table

```
make clean
```

### Run with GCP Profiler

```
make profile
```
