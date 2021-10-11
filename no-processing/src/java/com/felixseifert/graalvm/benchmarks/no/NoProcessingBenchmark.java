package com.felixseifert.graalvm.benchmarks.no;

import java.util.List;

public class NoProcessingBenchmark {

    private static long processList(final Integer list) {
        return list;
    }

    public static void main(String[] args) {
        final long result = processList(InputList.getList());
        System.out.println("Boring result is " + result);
    }
}
