package com.felixseifert.graalvm.benchmarks;

import org.openjdk.jmh.annotations.*;

import java.util.List;
import java.util.concurrent.TimeUnit;

public class ListProcessingBenchmarkStreams {

  @Benchmark
  @BenchmarkMode(Mode.AverageTime)
  @OutputTimeUnit(TimeUnit.NANOSECONDS)
  public long processList(final StateList stateList) {
    return stateList.list.stream().filter(i -> i % 2 == 0).mapToLong(i -> (long) i * i).sum();
  }

  @State(Scope.Benchmark)
  public static class StateList {
    public final List<Integer> list = InputList.getList();
  }
}
