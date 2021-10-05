package com.felixseifert.graalvm.benchmark.no;

import java.util.List;

public class NoProcessingBenchmark {

    private static long processList(final List<Integer> list) {
        return list.get(0);
    }

    public static void main(String[] args) {
        final long result = processList(InputList.getList());
        System.out.println("Boring result is " + result);
    }
}
