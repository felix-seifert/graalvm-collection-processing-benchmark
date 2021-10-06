#! /bin/bash -v

ROUNDS=10
RESULTS_FILE=benchmark.csv

LOOPS_DIR=list-processing-loops/target
LOOPS_NAME=list-processing-benchmark-loops
LOOPS_JAR="$LOOPS_DIR/$LOOPS_NAME.jar"
LOOPS_NATIVE="$LOOPS_DIR/$LOOPS_NAME-native"

STREAMS_DIR=list-processing-streams/target
STREAMS_NAME=list-processing-benchmark-streams
STREAMS_JAR=$STREAMS_DIR/$STREAMS_NAME.jar
STREAMS_NATIVE="$LOOPS_DIR/$STREAMS_NATIVE_NAME-native"

prepare_environment() {
  # Todo: Add check for compiled files
  if test -f $RESULTS_FILE; then
    rm $RESULTS_FILE
  fi
  touch $RESULTS_FILE
}

#
# Executes given jar and puts execution duration into given variable
#
measure_jar_execution() {
  local _JAR=$1
  local _DURATION=$2
  START=$(date +%s%N)
  java -jar "$_JAR"
  END=$(date +%s%N)
  eval "$_DURATION=$((END - START))"
}

#
# Executes given binary and puts execution duration into given variable
#
measure_native_execution() {
  local _NATIVE=$1
  local _DURATION=$2
  START=$(date +%s%N)
  ./$_NATIVE
  END=$(date +%s%N)
  eval "$_DURATION=$((END - START))"
}

run_loops_jar_benchmark() {
  echo 'Start benchmark of list processing through loops in JVM mode'
  declare -a LOOPS_JAR_TIMINGS
  for ((i = 0; i < ROUNDS; i++)); do
    measure_jar_execution $LOOPS_JAR DURATION
    LOOPS_JAR_TIMINGS+=("$DURATION")
  done
  local JOINED_TIMINGS
  JOINED_TIMINGS=$(echo "${LOOPS_JAR_TIMINGS[@]}" | tr ' ' ',')
  echo "Durations of list processing in JVM mode through loops in nanoseconds,$JOINED_TIMINGS" >> $RESULTS_FILE
  echo "Results added to $RESULTS_FILE"
}

run_loops_native_benchmark() {
  echo 'Start benchmark of list processing through loops in native mode'
  declare -a LOOPS_NATIVE_TIMINGS
  for ((i = 0; i < ROUNDS; i++)); do
    measure_native_execution $LOOPS_NATIVE DURATION
    LOOPS_NATIVE_TIMINGS+=("$DURATION")
  done
  local JOINED_TIMINGS
  JOINED_TIMINGS=$(echo "${LOOPS_NATIVE_TIMINGS[@]}" | tr ' ' ',')
  echo "Durations of list processing in native mode through loops in nanoseconds,$JOINED_TIMINGS" >> $RESULTS_FILE
  echo "Results added to $RESULTS_FILE"
}

prepare_environment
run_loops_jar_benchmark
run_loops_native_benchmark
