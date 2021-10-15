#! /bin/bash

if [ $# -lt 1 ]; then
  ROUNDS=10
elif ! [ "$1" -eq "$1" ] 2>/dev/null; then
  echo "Please specify the number of execution rounds in the first argument."
  exit
else
  ROUNDS=$1
fi

RESULTS_FILE=benchmark.csv

BUILD_SCRIPT='build.sh'

LOOPS_DIR='list-processing-loops'
LOOPS_TARGET_DIR="$LOOPS_DIR/target"
LOOPS_NAME='list-processing-benchmark-loops'
LOOPS_JAR="$LOOPS_TARGET_DIR/$LOOPS_NAME.jar"
LOOPS_NATIVE="$LOOPS_TARGET_DIR/$LOOPS_NAME-native"

STREAMS_DIR='list-processing-streams'
STREAMS_TARGET_DIR="$STREAMS_DIR/target"
STREAMS_NAME='list-processing-benchmark-streams'
STREAMS_JAR="$STREAMS_TARGET_DIR/$STREAMS_NAME.jar"
STREAMS_NATIVE="$STREAMS_TARGET_DIR/$STREAMS_NAME-native"

NO_PROCESSING_DIR='no-processing'
NO_PROCESSING_TARGET_DIR="$NO_PROCESSING_DIR/target"
NO_PROCESSING_NAME='no-processing'
NO_PROCESSING_JAR="$NO_PROCESSING_TARGET_DIR/$NO_PROCESSING_NAME.jar"
NO_PROCESSING_NATIVE="$NO_PROCESSING_TARGET_DIR/$NO_PROCESSING_NAME-native"

#
# Returns 0 if provided file is present and 1 if not
#
is_file_present() {
  test -f "$1"
}

ensure_presence_of_loops() {
  if ! is_file_present $LOOPS_JAR || ! is_file_present $LOOPS_NATIVE; then
    (cd $LOOPS_DIR || exit; ./$BUILD_SCRIPT)
  fi
}

ensure_presence_of_streams() {
  if ! is_file_present $STREAMS_JAR || ! is_file_present $STREAMS_NATIVE; then
    (cd $STREAMS_DIR || exit; ./$BUILD_SCRIPT)
  fi
}

ensure_presence_of_no_processing() {
  if ! is_file_present $NO_PROCESSING_JAR || ! is_file_present $NO_PROCESSING_NATIVE; then
    (cd $NO_PROCESSING_DIR || exit; ./$BUILD_SCRIPT)
  fi
}

get_col_headings() {
  local _T_HEADINGS
  for ((i = 1; i <= ROUNDS; i++)); do
    _T_HEADINGS+=",T$i"
  done
  local _OTHER_HEADINGS='Processing,Mode,Description'
  echo $_OTHER_HEADINGS$_T_HEADINGS
}

ensure_presence_of_empty_results_file() {
  if is_file_present $RESULTS_FILE; then
    rm $RESULTS_FILE
  fi
  touch $RESULTS_FILE
  get_col_headings >>$RESULTS_FILE
}

prepare_environment() {
  ensure_presence_of_loops
  ensure_presence_of_streams
  ensure_presence_of_no_processing
  ensure_presence_of_empty_results_file
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
  "./$_NATIVE"
  END=$(date +%s%N)
  eval "$_DURATION=$((END - START))"
}

run_loops_jar_benchmark() {
  echo "Start benchmark of $ROUNDS executions of list processing through loops in JVM mode"
  declare -a LOOPS_JAR_TIMINGS
  for ((i = 0; i < ROUNDS; i++)); do
    measure_jar_execution $LOOPS_JAR DURATION
    LOOPS_JAR_TIMINGS+=("$DURATION")
  done
  local JOINED_TIMINGS
  JOINED_TIMINGS=$(echo "${LOOPS_JAR_TIMINGS[@]}" | tr ' ' ',')
  echo "Loops,JVM,Durations of list processing in JVM mode through loops in nanoseconds,$JOINED_TIMINGS" >>$RESULTS_FILE
  echo "Results added to $RESULTS_FILE"
}

run_loops_native_benchmark() {
  echo "Start benchmark of $ROUNDS executions of list processing through loops in native mode"
  declare -a LOOPS_NATIVE_TIMINGS
  for ((i = 0; i < ROUNDS; i++)); do
    measure_native_execution $LOOPS_NATIVE DURATION
    LOOPS_NATIVE_TIMINGS+=("$DURATION")
  done
  local JOINED_TIMINGS
  JOINED_TIMINGS=$(echo "${LOOPS_NATIVE_TIMINGS[@]}" | tr ' ' ',')
  echo "Loops,Native,Durations of list processing in native mode through loops in nanoseconds,$JOINED_TIMINGS" >>$RESULTS_FILE
  echo "Results added to $RESULTS_FILE"
}

run_stream_jar_benchmark() {
  echo "Start benchmark of $ROUNDS executions of list processing through streams in JVM mode"
  declare -a STREAMS_JAR_TIMINGS
  for ((i = 0; i < ROUNDS; i++)); do
    measure_jar_execution $STREAMS_JAR DURATION
    STREAMS_JAR_TIMINGS+=("$DURATION")
  done
  local JOINED_TIMINGS
  JOINED_TIMINGS=$(echo "${STREAMS_JAR_TIMINGS[@]}" | tr ' ' ',')
  echo "Streams,JVM,Durations of list processing in JVM mode through streams in nanoseconds,$JOINED_TIMINGS" >>$RESULTS_FILE
  echo "Results added to $RESULTS_FILE"
}

run_streams_native_benchmark() {
  echo "Start benchmark of $ROUNDS executions of list processing through streams in native mode"
  declare -a STREAMS_NATIVE_TIMINGS
  for ((i = 0; i < ROUNDS; i++)); do
    measure_native_execution $STREAMS_NATIVE DURATION
    STREAMS_NATIVE_TIMINGS+=("$DURATION")
  done
  local JOINED_TIMINGS
  JOINED_TIMINGS=$(echo "${STREAMS_NATIVE_TIMINGS[@]}" | tr ' ' ',')
  echo "Streams,Native,Durations of list processing in native mode through streams in nanoseconds,$JOINED_TIMINGS" >>$RESULTS_FILE
  echo "Results added to $RESULTS_FILE"
}

run_no_processing_jar_benchmark() {
  echo "Start benchmark of $ROUNDS executions without processing in JVM mode"
  declare -a NO_PROCESSING_JAR_TIMINGS
  for ((i = 0; i < ROUNDS; i++)); do
    measure_jar_execution $NO_PROCESSING_JAR DURATION
    NO_PROCESSING_JAR_TIMINGS+=("$DURATION")
  done
  local JOINED_TIMINGS
  JOINED_TIMINGS=$(echo "${NO_PROCESSING_JAR_TIMINGS[@]}" | tr ' ' ',')
  echo "No processing,JVM,Durations without processing in JVM mode in nanoseconds,$JOINED_TIMINGS" >>$RESULTS_FILE
  echo "Results added to $RESULTS_FILE"
}

run_no_processing_native_benchmark() {
  echo "Start benchmark of $ROUNDS executions without processing in native mode"
  declare -a NO_PROCESSING_NATIVE_TIMINGS
  for ((i = 0; i < ROUNDS; i++)); do
    measure_native_execution $NO_PROCESSING_NATIVE DURATION
    NO_PROCESSING_NATIVE_TIMINGS+=("$DURATION")
  done
  local JOINED_TIMINGS
  JOINED_TIMINGS=$(echo "${NO_PROCESSING_NATIVE_TIMINGS[@]}" | tr ' ' ',')
  echo "No processing,Native,Durations without processing in native mode in nanoseconds,$JOINED_TIMINGS" >>$RESULTS_FILE
  echo "Results added to $RESULTS_FILE"
}

prepare_environment
run_loops_jar_benchmark
run_loops_native_benchmark
run_stream_jar_benchmark
run_streams_native_benchmark
run_no_processing_jar_benchmark
run_no_processing_native_benchmark
