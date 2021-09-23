package com.felixseifert.graalvm.benchmarks.loops;

import java.util.List;

public class ListProcessingBenchmarkLoops {

  public static long processList(final List<Integer> list) {
    long sum = 0;
    for (int i : list) {
      if (i % 2 == 0) {
        sum += (long) i * i;
      }
    }
    return sum;
  }

  public static void main(String[] args) {
    final long result = processList(InputList.getList());
    System.out.println("Result through loops is " + result);
  }
}
