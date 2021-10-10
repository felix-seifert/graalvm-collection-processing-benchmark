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

The execution timings will be stored in a `.csv` file. A row comprises the used for of processing, the execution mode, a
description of the execution and is followed by several execution timings of the described mode.

```
Processing,Mode,Description,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10
loops,jvm,Durations of list processing in JVM mode through loops in nanoseconds,456640855,480563969,466274310,457555452,473514995,451377833,465314880,470706899,470199321,476601833
loops,native,Durations of list processing in native mode through loops in nanoseconds,7979673,7672593,9879840,5475428,5415416,3764797,3834782,5024665,4398057,4784259
streams,jvm,Durations of list processing in JVM mode through streams in nanoseconds,442252917,486446579,474882802,469567358,486140159,464532595,494910979,490998692,492638200,466492981
streams,native,Durations of list processing in native mode through streams in nanoseconds,8750754,7709488,8186808,5780086,5315444,4769203,3847299,3968024,4391808,4771771
no-processing,jvm,Durations without processing in JVM mode in nanoseconds,443549496,473485721,468311970,451413823,479392505,461802326,460117760,471456463,458598231,471726635
no-processing,native,Durations without processing in native mode in nanoseconds,4145229,5330653,4577214,4098532,3506842,4721917,4417340,3747131,3686842,4774681
```

## Generate Graphs

After running the benchmark, you might want to aggregate the benchmarking results and display them in a graph. The graph
generation can be automated with the Python script in the folder [process-benchmarks](process-benchmarks). The script
generates two different graphs: One graph show the measured absolute execution duration for the different processing
forms in different execution modes. The second graph shows how the different execution forms differ from a nearly empty
application as described in the section [Idea of Benchmark](#idea-of-benchmark).

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
