package com.felixseifert.graalvm.benchmarks;

import org.openjdk.jmh.annotations.*;

import java.util.List;
import java.util.concurrent.TimeUnit;

public class ListProcessingBenchmarkLoops {

  @Benchmark
  @BenchmarkMode(Mode.AverageTime)
  @OutputTimeUnit(TimeUnit.NANOSECONDS)
  public long processList(final StateList stateList) {
    long sum = 0;
    for (int i : stateList.list) {
      if (i % 2 == 0) {
        sum += (long) i * i;
      }
    }
    return sum;
  }

  @State(Scope.Benchmark)
  public static class StateList {
    public final List<Integer> list = InputList.getList();
  }
}
