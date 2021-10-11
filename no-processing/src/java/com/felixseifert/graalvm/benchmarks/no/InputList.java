package com.felixseifert.graalvm.benchmarks.no;

import java.util.List;

public class InputList {

    private static final List<Integer> list = List.of(0);

    public static Integer getList() {
        // Do not use real list because retrieving only single entry of list can already be as list processing.
        return 0;
    }
}
