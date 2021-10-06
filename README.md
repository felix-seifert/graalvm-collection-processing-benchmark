# graalvm-collection-processing-benchmark

This project serves to benchmark list processing with streams and loops in GraalVM's JVM mode and native mode.

## Prerequisites

As this project benchmarks the performance of Java code compiled by GraalVM, it is needed to have **GraalVM** and
GraalVM's **`native-image` functionality**.

1. [Download GraalVM](https://www.graalvm.org/downloads/), unzip the archive to a desired location, export the GraalVM
   home directory as `$GRAALVM_HOME`, and add `$GRAALVM_HOME/bin` to the `PATH` environment variable.
    * On Linux
      ```shell
      export GRAALVM_HOME=/path/to/graalvm
      export PATH=$GRAALVM_HOME/bin:$PATH
      ```
    * On macOS
      ```shell
      export GRAALVM_HOME=/path/to/graalvm/Contents/Home
      export PATH=$GRAALVM_HOME/bin:$PATH
      ```
    * For more information, have a look
      at [https://www.graalvm.org/guides/#run-java-applications-on-graalvm-from-the-cli](https://www.graalvm.org/guides/#run-java-applications-on-graalvm-from-the-cli)
      .
2. Install the [`native-image` functionality](https://www.graalvm.org/reference-manual/native-image/)
   ```shell
   gu install native-image
   ```

In the build script, GraalVM's `javac` is used to simplify the prerequisites and not depend on having another JDK
installed. Nevertheless, note that the aforementioned environment variable `$GRAALVM_HOME` is of utmost importance.

## Build Code and Run Benchmark

If the environment variable is set, just run the script `benchmark.sh`. It compiles the different modules if it did not
already happen and executes them as JARs and native binaries. The execution is repeated and each execution gets timed.

```shell
./benchmark.sh
```

The execution timings will be stored in a `.csv` file. A row comprises a cell with a description of the execution mode
and is followed by several cells which each include an execution timing of the described mode.

```
Durations of list processing in JVM mode through loops in nanoseconds,448489212,450392198,451370661,445946157,471229684,451721586,440719189,473921751,468296118,457031957
Durations of list processing in native mode through loops in nanoseconds,7481069,7089192,5532764,4501771,3886928,3509831,3544814,3509943,3469809,4069187
Durations of list processing in JVM mode through streams in nanoseconds,420181708,480143271,461680516,464056132,465772250,468489195,480839552,463729502,477066599,456528607
Durations of list processing in native mode through streams in nanoseconds,6614009,6320993,6387160,6430733,6976682,6356072,6309118,6178219,5133343,4012548
Durations without processing in JVM mode in nanoseconds,442104481,465377112,446387596,466247921,439630449,452008831,453139540,493972999,452112940,453896817
Durations without processing in native mode in nanoseconds,7311050,5222034,4633433,5435407,6936241,6446732,5486576,5538380,5413637,5685813
```

## Idea of Benchmark

The two folder [list-processing-loops](list-processing-loops) and [list-processing-streams](list-processing-streams)
each contain an application which processes a list respectively with loops or streams. The third
folder [no-processing](no-processing) contains an application which prints out the single value of a list. The idea is
to benchmark these applications in different GraalVM modes and compare their performance.

To reduce the different list processing as much as possible to their differences, the execution duration of the
application which does not perform any list processing can be subtracted from the execution duration of the list
processing with loops or streams. To reduce the variance between different executions, the executions are repeated and
their averages should be taken for the benchmark.

The following schematic calculation tries to explain the approach of the different timings. `d(x)` should be the
execution duration of `x`.

```
d(app_loop) = (d(app_loop_1) + .. + d(app_loop_n)) / n
d(app_stream) = (d(app_stream_1) + .. + d(app_stream_n)) / n
d(app_no_proc) = (d(app_no_proc_1) + .. + d(app_no_proc_n)) / n

d(loop) = d(app_loop) - d(app_no_proc)
d(stream) = d(app_stream) - d(app_no_proc)
```

As the different timings should be compared between JVM mode and native mode, the depicted benchmarking steps would have
to be repeated for the `.jar` files and the native binaries. Executing the script `benchmark.sh` measures all the needed
timings and stores them for further processing in a `.csv`.
