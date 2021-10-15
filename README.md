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
You can specify the number of executions as the first argument. If you do not specify this, the benchmark executes each
mode and processing form 10 times.

```shell
./benchmark.sh 100
```

The execution timings will be stored in a `.csv` file. A row comprises the used form of processing, the execution mode,
a description of the execution and is followed by several execution timings of the described mode.

```
Processing,Mode,Description,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10
Loops,JVM,Durations of list processing in JVM mode through loops in nanoseconds,548346161,488445354,467328913,452216192,457825879,485607947,460001081,469433120,453007915,476017979
Loops,Native,Durations of list processing in native mode through loops in nanoseconds,21883384,7221723,7488429,7132373,7693068,5407403,4696986,5388801,4863087,5750389
Streams,JVM,Durations of list processing in JVM mode through streams in nanoseconds,465749634,496172396,494853601,469920572,513513433,503009541,512070066,502442097,503881682,511083303
Streams,Native,Durations of list processing in native mode through streams in nanoseconds,22004712,7668186,5148112,10127384,7185451,7941998,5890849,6090887,6436806,6026572
No processing,JVM,Durations without processing in JVM mode in nanoseconds,503537348,555238835,539205346,480851815,496739958,544496174,481078617,478547335,472112515,474704626
No processing,Native,Durations without processing in native mode in nanoseconds,21762677,7448068,8295145,7261507,8784889,6754219,5853263,4090931,4015362,3708235
```

## Generate Graphs

After running the benchmark, you might want to aggregate the benchmarking results and display them in a graph. The graph
generation can be automated with the Python script in the folder [process-benchmarks](process-benchmarks). The script
generates two different graphs: One graph shows the measured absolute execution duration for the different processing
forms in different execution modes. The second graph shows how the different execution forms differ from a nearly empty
application as described in the section [Idea of Benchmark](#idea-of-benchmark).

## Idea of Benchmark

The two folders [list-processing-loops](list-processing-loops) and [list-processing-streams](list-processing-streams)
each contain an application which processes a list with loops or streams respectively. The third folder
[no-processing](no-processing) contains an application which prints out the single value of a list. The idea is to
benchmark these applications in different GraalVM modes and compare their performance.

To reduce the different list processing forms as much as possible to their differences, the execution duration of the
application which does not perform any list processing can be subtracted from the execution duration of the list
processing with loops or streams. To reduce the variance between different executions, the executions are repeated and
their median values should be taken for the benchmark.

The following schematic calculation tries to explain the approach of the different timings. `d(x)` should be the
execution duration of `x`.

```
d(app_loop) = median([app_loop_1 .. app_loop_n])
d(app_stream) = median([app_stream_1 .. app_stream_n])
d(app_no_proc) = median([app_no_proc_1 .. app_no_proc_n])

d(loop) = d(app_loop) - d(app_no_proc)
d(stream) = d(app_stream) - d(app_no_proc)
```

As the different timings should be compared between JVM mode and native mode, the depicted benchmarking steps would have
to be repeated for the `.jar` files and the native binaries. Executing the script `benchmark.sh` measures all the needed
timings and stores them for further processing in a `.csv` file.
