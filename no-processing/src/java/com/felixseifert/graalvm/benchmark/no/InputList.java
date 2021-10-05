package com.felixseifert.graalvm.benchmark.no;

import java.util.List;

public class InputList {

    private static final List<Integer> list = List.of(0);

    public static List<Integer> getList() {
        return list;
    }
}
