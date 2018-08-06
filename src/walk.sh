#!/bin/bash

trap 'echo "Killing build_exec.sh script" ; exit' INT TERM

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # --

function cleanup() {
  rm -f *.bc
  rm -f *.rbc ;
  rm -f *.ibc ;
  rm -f *.o ;
  # rm -f *.exe ;
  # rm -f table.csv
  # rm -f prof.dat ;
  # rm -f feat.dat ;
}

function unset_vars() {
  unset COMPILER ;
  unset STDIN ;
  unset STDOUT ;
  unset RUN_OPTIONS ;
}

function set_vars(){
  source info.sh

  # Let's set the variables that are unset

  # sometimes we need to use clang++
  [[ -n $COMPILER ]] || COMPILER=clang ;
  # We can specify STDIN to something other than /dev/stdin
  [[ -n $STDIN ]] || STDIN=/dev/stdin ;
  # And STDOUT default is /dev/null.
  [[ -n $STDOUT ]] || STDOUT=/dev/null ;
  # But if we set DEBUG=1, than we ignore the previous definition of STDOUT
  if [[ $DEBUG == 1 ]]; then
    STDOUT=/dev/stdout ;
  fi

  # if we're on osx, we must use `gtimeout` instead of `timeout`
  # `gtimeout` can be download from homebrew
  TIMEOUT=timeout
  if [[ $(uname -s) == "Darwin" ]]; then
    TIMEOUT=gtimeout
  fi
}

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # --

function walk() {

  if [[ $# == 0 ]]; then
    echo "Error, you must specify the directories this script must compile"
    echo 'ex: walk $( ls -d */ )'
    exit ;
  else
    dirs=("$@") ;
  fi

  parent_dir=$(pwd) ;

  for dir in "${dirs[@]}"; do
    cd "$parent_dir"/"$dir" ;

    d=$(basename $(pwd))
    echo "Sourcing info.sh from $d" ;

    set_vars ;
    cleanup ;

    if [[ $COMPILE -eq 1 ]]; then
      compile ;
    fi

    execute ;

    unset_vars ;

    echo
    echo "###############"
    echo

    cd "$parent_dir"

  done
}
