# graalvm-collection-processing-benchmark

The two folders [list-processing-streams](list-processing-loops) and [list-processing-streams](list-processing-streams)
provide JMH benchmarks for comparing collection processing (especially list processing) in Java. The collections are
either processes with loops or streams. The idea is to run these benchmarks in different GraalVM modes and compare the
performance in between loops and streams and the different GraalVM modes.

For now, the results are not satisfying as the compilation with GraalVM's `native-image` mode does not result in a clear
performance benefit. The reason might be that JVM uses reflection which does not result in a standalone executable which
still require a JVM.