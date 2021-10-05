package com.felixseifert.graalvm.benchmarks.streams;

import java.util.List;

public class ListProcessingBenchmarkStreams {

  public static long processList(final List<Integer> list) {
    return list.stream().filter(i -> i % 2 == 0).mapToLong(i -> (long) i * i).sum();
  }

  public static void main(String[] args) {
    final long result = processList(InputList.getList());
    System.out.println("Result through streams is " + result);
  }
}
