#!/usr/bin/env bash

if [ -n "${DEBUG:-}" ]; then
  set -x
fi

# source: https://github.com/Tieske/test.sh

if [[ "$T_INIT_COUNT" == "" ]]; then
  # first time, initialize global variables
  T_PROJECT_NAME=""
  T_FILE_NAME=""
  T_COUNT_FAILURE=0
  T_COUNT_SUCCESS=0
  T_CURRENT_CHAPTER=""
  T_CHAPTER_START_FAILURES=0
  T_CHAPTER_START_SUCCESSES=0
  T_CURRENT_TEST=""
  T_COLOR_YELLOW="\033[1;33m"
  T_COLOR_RED="\033[0;31m"
  T_COLOR_GREEN="\033[1;32m"
  T_COLOR_CLEAR="\033[0m"
  T_INIT_COUNT=0
  T_FAILURE_ARRAY=()
  T_DEBUGGING=""

  figlet -v > /dev/null 2>&1
  T_FIGLET_AVAILABLE=$?
else
  # assuming we're being sourced again, just exit
  return 0
fi


function texit {
  # internal function only
  unset T_PROJECT_NAME
  unset T_FILE_NAME
  unset T_COUNT_FAILURE
  unset T_COUNT_SUCCESS
  unset T_CURRENT_CHAPTER
  unset T_CHAPTER_START_FAILURES
  unset T_CHAPTER_START_SUCCESSES
  unset T_CURRENT_TEST
  unset T_COLOR_YELLOW
  unset T_COLOR_RED
  unset T_COLOR_GREEN
  unset T_COLOR_CLEAR
  unset T_INIT_COUNT
  unset T_FAILURE_ARRAY
  unset T_FIGLET_AVAILABLE
  unset T_DEBUGGING
  exit "$1"
}


function tfooter {
  # internal function only
  # Arguments:
  # 1) successes
  # 2) failures
  # 3) [optional] boolean; if set Project title, otherwise Chapter title
  local indent=""
  if [[ "$3" == "" ]]; then
    indent="  "
    local chapter
    if [[ "$T_FILE_NAME" == "" ]]; then
      chapter=$T_CURRENT_CHAPTER
    else
      chapter="$T_CURRENT_CHAPTER ($T_FILE_NAME)"
    fi
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo -e "$T_COLOR_YELLOW$indent""Chapter : $chapter$T_COLOR_CLEAR"
  else
    echo "========================================================================================================================"
    echo -e "$T_COLOR_YELLOW$indent""Project  : $T_PROJECT_NAME$T_COLOR_CLEAR"
  fi
  echo -e "$T_COLOR_YELLOW$indent""Successes: $1$T_COLOR_CLEAR"
  echo -e "$T_COLOR_YELLOW$indent""Failures : $2$T_COLOR_CLEAR"
}


function theader {
  # internal function only
  local header=$1
  echo "========================================================================================================================"
  if [ $T_FIGLET_AVAILABLE -eq 0 ]; then
    figlet -c -w 120 "$header"
  else
    printf "%*s\n" $(( (${#header} + 120) / 2)) "$header"
  fi
  echo "========================================================================================================================"
}


function tmessage {
  echo -e "$T_COLOR_YELLOW$T_PROJECT_NAME [  info   ] $*$T_COLOR_CLEAR"
}


function tdebug {
  if [[ "$T_CURRENT_TEST" == "" ]]; then
    echo "calling tdebug without a test, call ttest first"
    exit 1
  fi
  T_DEBUGGING=true
  set -x
}


function tinitialize {
  # Initializes either a test suite or a single test file. Every tinitialize
  # MUST be followed by a tfinish, after the tests are completed.
  # Arguments:
  # 1) [required] name of the test suite  (ignored if already set)
  # 2) [optional] filename of the testfile
  if [[ ! "$T_CURRENT_CHAPTER" == "" ]]; then
    echo "calling tinitialize after testing already started"
    exit 1
  fi
  if [[ "$1" == "" ]]; then
    echo "calling tinitialize without project name"
    exit 1
  fi

  if [[ $T_INIT_COUNT -eq 0 ]]; then
    # first time we're being initialized
    T_PROJECT_NAME=$1
    theader "$T_PROJECT_NAME"
    ((T_INIT_COUNT = T_INIT_COUNT + 1))
  else
    # we're being called multiple times, because multiple files run in a row
    # do not intialize again, just update the counter
    ((T_INIT_COUNT = T_INIT_COUNT + 1))
  fi
  T_FILE_NAME=$2
}


function tchapter {
  # Initializes a test chapter.
  # Call after tinitialize, and before ttest.
  if [[ ! "$T_CURRENT_TEST" == "" ]]; then
    echo "calling tchapter while test is unfinished, call tfailure or tsuccess first"
    exit 1
  fi
  if [[ "$1" == "" ]]; then
    echo "calling tchapter without chapter name"
    exit 1
  fi

  if [[ ! "$T_CURRENT_CHAPTER" == "" ]]; then
    tfooter $((T_COUNT_SUCCESS - T_CHAPTER_START_SUCCESSES)) $((T_COUNT_FAILURE - T_CHAPTER_START_FAILURES))
  fi

  T_CURRENT_CHAPTER="$*"
  T_CHAPTER_START_FAILURES=$T_COUNT_FAILURE
  T_CHAPTER_START_SUCCESSES=$T_COUNT_SUCCESS

  theader "$T_CURRENT_CHAPTER"
}


function ttest {
  # Marks the start of a test.
  # The test MUST be finished with either tsuccess or tfailure.
  # Arguments:
  # 1) name of the test
  if [[ "$T_CURRENT_CHAPTER" == "" ]]; then
    echo "calling ttest without chapter, call tchapter first"
    exit 1
  fi
  if [[ "$1" == "" ]]; then
    echo "calling ttest without test description"
    exit 1
  fi
  T_CURRENT_TEST="$*"
  echo -e "$T_COLOR_YELLOW$T_PROJECT_NAME [  start  ] $T_CURRENT_CHAPTER: $T_CURRENT_TEST$T_COLOR_CLEAR"
}


function tfailure {
  # Marks the end of a test, with a failure.
  # no arguments
  if [[ "$T_DEBUGGING" == "true" ]]; then set +x; T_DEBUGGING=""; fi
  if [[ "$T_CURRENT_TEST" == "" ]]; then
    echo "calling tfailure without a test, call ttest first"
    exit 1
  fi
  [[ ! "$1" == "" ]] && tmessage "$*"
  local failure="$T_CURRENT_CHAPTER: $T_CURRENT_TEST"
  echo -e "$T_COLOR_YELLOW$T_PROJECT_NAME$T_COLOR_RED [ failed  ]$T_COLOR_YELLOW $failure$T_COLOR_CLEAR"

  if [[ ! $T_FILE_NAME == "" ]]; then
    failure="$failure ($T_FILE_NAME)"
  fi

  T_FAILURE_ARRAY+=("$failure")

  ((T_COUNT_FAILURE = T_COUNT_FAILURE + 1))
  T_CURRENT_TEST=""
}


function tsuccess {
  # Marks the end of a test, as a success.
  # no arguments
  if [[ "$T_DEBUGGING" == "true" ]]; then set +x; T_DEBUGGING=""; fi
  if [[ "$T_CURRENT_TEST" == "" ]]; then
    echo "calling tsuccess without a test, call ttest first"
    exit 1
  fi
  [[ ! "$1" == "" ]] && tmessage "$*"
  echo -e "$T_COLOR_YELLOW$T_PROJECT_NAME$T_COLOR_GREEN [ success ]$T_COLOR_YELLOW $T_CURRENT_CHAPTER: $T_CURRENT_TEST$T_COLOR_CLEAR"
  ((T_COUNT_SUCCESS = T_COUNT_SUCCESS + 1))
  T_CURRENT_TEST=""
}


function tfinish {
  # Finishes either a test suite or a single test file.
  # no arguments
  if [[ ! "$T_CURRENT_TEST" == "" ]]; then
    echo "calling tfinish while test is unfinished, call tfailure or tsuccess first"
    exit 1
  fi

  if [[ ! "$T_CURRENT_CHAPTER" == "" ]]; then
    tfooter $((T_COUNT_SUCCESS - T_CHAPTER_START_SUCCESSES)) $((T_COUNT_FAILURE - T_CHAPTER_START_FAILURES))
    T_CURRENT_CHAPTER=""
  fi

  ((T_INIT_COUNT = T_INIT_COUNT - 1))
  if [[ $T_INIT_COUNT -eq 0 ]]; then
    # this was the last testfile running, so actually wrap it up
    tfooter $((T_COUNT_SUCCESS)) $((T_COUNT_FAILURE)) Project
    local failure
    for failure in "${T_FAILURE_ARRAY[@]}"; do
      echo -e "$T_COLOR_YELLOW  $failure$T_COLOR_CLEAR"
    done

    if [ "$T_COUNT_FAILURE" -eq 0 ] && [ "$T_COUNT_SUCCESS" -gt 0 ]; then
      if [ $T_FIGLET_AVAILABLE -eq 0 ]; then
        # split in lines and colorize each individually for CI
        figlet -c -w 120 "Success!" | while IFS= read -r line; do echo -e "$T_COLOR_GREEN$line $T_COLOR_CLEAR"; done
      else
        echo -e "$T_COLOR_GREEN  Overall succes!$T_COLOR_CLEAR"
      fi
      texit 0
    else
      if [ $T_FIGLET_AVAILABLE -eq 0 ]; then
        # split in lines and colorize each individually for CI
        figlet -c -w 120 "Failed!" | while IFS= read -r line; do echo -e "$T_COLOR_RED$line $T_COLOR_CLEAR"; done
      else
        echo -e "$T_COLOR_RED  Overall failed!$T_COLOR_CLEAR"
      fi
      texit 1
    fi
  else
    # we've finished a file, but not the last one yet.
    T_FILE_NAME=""
  fi
}


function tcreate {
  # Creates a new testfile from template.
  # Arguments:
  # 1) filename of the new testfile (.test.sh extension auto-appended)
  # 2) test suite name
  if [ "$1" == "" ]; then
    echo "first argument missing: filename to create"
    texit 1
  elif [ "$2" == "" ]; then
    echo "second argument missing: test suite name"
    texit 1
  elif [ ! "$3" == "" ]; then
    echo "too many arguments"
    texit 1
  fi

  local FILENAME="$1"
  if [[ "$FILENAME" != *.test.sh ]]; then
    FILENAME=$FILENAME.test.sh
  fi

  if [ -f "$FILENAME" ]; then
    echo "file already exists: $FILENAME"
    texit 1
  fi

cat <<EOF > "$FILENAME"
#!/usr/bin/env bash

: '
There is one dependency; "test.sh", the "figlet" utility is optional.

Usage test.sh:
  1: ./test.sh [--suite <suite name>] [files/dirs...]
  2: ./test.sh --create <testfile> <suite name>

  1: Runs tests. When "files/dirs" is not provided, it will run all "*.test.sh" files
  located in the same directory as "test.sh". The suite name defaults to "unknown
  test suite".

  2: Creates a new template test file

Usage test files:
  ./this.test.sh [path-to-test.sh]

  When "path-to-test.sh" is not provided it defaults to the same directory where
  the test file is located.

Assuming "test.sh" is in the same directory as this file:

  /some/path/this.test.sh                       # runs only this file
  /some/path/test.sh                            # runs all "/some/path/*.test.sh" files
  /some/path/test.sh this.test.sh that.test.sh  # runs "this.test.sh" and "that.test.sh" files

When not in the same directory

  /some/path/this.test.sh other/path/test.sh    # runs only this file
  /other/path/test.sh /some/path/this.test.sh   # runs only this file


The test themselves are located below this comment in the "run_test" function
'

function run_test {
  # the suite name below will only be used when running this file directly, when
  # running through "test.sh" it must be provided using the "--suite" option.
  tinitialize "$2" "\${BASH_SOURCE[0]}"

  tchapter "great tests"

  ttest "ensures the file exists"
  tdebug  # this enables 'set -x' until the first tfailure or tsuccess call
  if [ ! -f "some/local/file" ]; then
    tmessage "The file did not exist"
    tfailure
  else
    tmessage "The file was found"
    tsuccess
  fi

  tchapter "awesome tests"

  ttest "ensures the file does NOT exist"
  if [ ! -f "some/local/file" ]; then
    tsuccess "a success message"
  else
    tfailure "a failure message"
  fi

  tfinish
}

# No need to modify anything below this comment

# shellcheck disable=SC1090  # do not follow source
[[ "\$T_PROJECT_NAME" == "" ]] && set -e && if [[ -f "\${1:-\$(dirname "\$(realpath "\$0")")/test.sh}" ]]; then source "\${1:-\$(dirname "\$(realpath "\$0")")/test.sh}"; else source "\${1:-\$(dirname "\$(realpath "\$0")")/run.sh}"; fi && set +e
run_test
EOF

  if [ ! $? -eq 0 ]; then
    echo "failed to write file $FILENAME"
    texit 1
  fi
  chmod +x "$FILENAME"
  #bash ./test.sh "$FILENAME"

  echo "Successfully created a new test file: $FILENAME"
  echo "Instructions are in the file."
  texit 0
}


function main {
  # usage: test.sh [--suite <suitename>] [filenames...]
  # if no filenames given then will execute all "*.test.sh" files in the
  # same directory
  local FILE_LIST=()
  local FILENAME
  local SUITE_NAME

  if [[ "$1" == "--create" ]]; then
    shift
    tcreate "$@"
    texit 0
  elif [[ "$1" == "--suite" ]]; then
    shift
    SUITE_NAME=$1
    shift
  else
    SUITE_NAME="unknown test suite"
  fi

  if [[ $# -gt 0 ]]; then
    # filenames passed; only execute filenames passed in
    while [[ $# -gt 0 ]]; do
      if [ ! -f "$1" ] ; then
        if [ ! -d "$1" ] ; then
          echo "test file not found: $1"
          texit 1
        fi
        # it's a directory, add all files in it
        for FILENAME in "$1"/*.test.sh; do
          if [ -f "$FILENAME" ] ; then
            FILE_LIST+=("$FILENAME")
          fi
        done
      else
        # add a single file
        FILE_LIST+=("$1")
      fi
      shift
    done

  else
    # no parameters passed, go execute all test files we can find
    local MY_PATH
    if [[ "$0" == "/dev/stdin" ]]; then
      # script is executed from stdin, probably through run.sh
      MY_PATH=$PWD
    else
      MY_PATH=$(dirname "$(realpath "$0")")
    fi
    for FILENAME in "$MY_PATH"/*.test.sh; do
      if [[ "$FILENAME" != "$(realpath "$0")" ]]; then
        if [ -f "$FILENAME" ] ; then
          FILE_LIST+=("$FILENAME")
        fi
      fi
    done
  fi

  tinitialize "$SUITE_NAME"

  for FILENAME in ${FILE_LIST[*]}; do
    # shellcheck disable=SC1090
    source "$FILENAME"
  done

  tfinish
}


# see 'main' for usage
if [[ $0 == "${BASH_SOURCE[0]}" ]]; then
  # this script is executed, not sourced, so initiate a test run
  main "$@"
fi
