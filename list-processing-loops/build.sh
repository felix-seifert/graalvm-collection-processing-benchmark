#! /bin/bash

ROOT_DIR=$(pwd)

JAVA_SRC_DIR=src/java
ROOT_PACKAGE=com/felixseifert/graalvm/benchmarks/loops

TARGET_DIR=target
COMPILED_CLASSES_DIR=$TARGET_DIR/classes

JAR_NAME=list-processing-benchmark-loops
NATIVE_NAME="$JAR_NAME-native"

check_if_correct_directory() {
  CURRENT_DIR=$(echo "$ROOT_DIR" | awk -F"/" '{print $NF}')
  if [[ $CURRENT_DIR != *"loop"* ]]; then
    echo 'Script is executed in wrong directory.'
    exit
  fi
}

compile() {
  "$GRAALVM_HOME/bin/javac" -d $COMPILED_CLASSES_DIR $JAVA_SRC_DIR/$ROOT_PACKAGE/*.java
}

package_in_jar() {
  cp src/resources/META-INF/MANIFEST.MF $COMPILED_CLASSES_DIR
  cd $COMPILED_CLASSES_DIR || exit
  "$GRAALVM_HOME/bin/jar" cfm "$ROOT_DIR/$TARGET_DIR/$JAR_NAME.jar" MANIFEST.MF $ROOT_PACKAGE/*.class
  cd "$ROOT_DIR" || exit
}

compile_native_image() {
  "$GRAALVM_HOME/bin/native-image" -jar "$ROOT_DIR/$TARGET_DIR/$JAR_NAME.jar" "$ROOT_DIR/$TARGET_DIR/$NATIVE_NAME" | cat
}

check_if_correct_directory
compile && echo ".java files from $ROOT_PACKAGE compiled in $COMPILED_CLASSES_DIR"
package_in_jar && echo "$TARGET_DIR/$JAR_NAME.jar created"
compile_native_image && echo "Native image $TARGET_DIR/$JAR_NAME-native compiled"
