#!/bash/bin

# if 0, redirect benchmark output to /dev/null
# if 1, print benchmark output to stdout
[[ -n $DEBUG ]] || DEBUG=0

# Specify the timeout. Default is INF(0)
[[ -n $RUNTIME ]] || RUNTIME=0

# Execute the benchmark
[[ -n $EXEC ]] || EXEC=1

# Compile
[[ -n $COMPILE ]] || COMPILE=1

# JOBS
[[ -n $JOBS ]] || JOBS=1

# ANALYZE
[[ -n $ANALYZE ]] || ANALYZE=1

# INSTRUMENT
[[ -n $INSTRUMENT ]] || INSTRUMENT=0

# Optimization level
[[ -n $OPT ]] || OPT="-O3"

# CBench
[[ -n $CBENCH ]] || CBENCH=1

# PASS NAME
if [[ -n $INSTRUMENT && $INSTRUMENT -eq 1 ]]; then
  if [[ -z $PASS ]]; then
    echo "You must specify a pass to use when INSTRUMENT=1"
    exit 1
  fi
  
  if [[ $PASS = "DAG"  ]]; then
    if [[ -z $PASS_OPT ]]; then
      echo "You must specify the pass option for DAG"
      exit 1
    fi
  else
    PASS_OPT=""
  fi
fi

# DIFF
[[ -n $DIFF ]] || DIFF=0

[[ $DIFF -eq 1 && $DEBUG -eq 1 ]] && {
  echo "Can't use DIFF=1 & DEBUG=1 at the same time"
  exit 1
}

# Remove all temp files
[[ -n CLEAN ]] || CLEAN=0

# Set the lib suffix.
suffix="dylib"
if [[ $(uname -s) == "Linux" ]]; then
  suffix="so"
fi

# if we're on osx, we must use `gtimeout` instead of `timeout`
# `gtimeout` can be download from homebrew
TIMEOUT=timeout
if [[ $(uname -s) == "Darwin" ]]; then
  TIMEOUT=gtimeout
fi


# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- 

# LLVM_PATH  => The place where I have all the LLVM tools
LLVM_PATH=""

[[ -n "${LLVM_PATH}" ]] || {
	echo "One must define LLVM_PATH before running tf"
	exit 1
}

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- 

PHOENIX_PATH=""

[[ -n "${PHOENIX_PATH}" ]] || {
  echo "One must define PHOENIX_PATH before running tf"
  exit 1
}

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- 

[[ -n $SANITIZE ]] || SANITIZE=0

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- 

# THIS PART IS LEFT AS AN EXAMPLE FOR THE PEOPLE WORKING WITH PIN!

# PIN 
[[ -n $PIN ]] || PIN=0

if [[ $PIN -eq 1 ]]; then
  # PIN_PATH   => The place where I keep the pin source code
	PIN_PATH=""
  [[ -n $PIN_PATH ]] || {
		echo "One must define the PIN before when PIN=1"
		exit 1
	}
  
  # PIN_LIB    => The place where I keep the Pin lib implemented.
	PIN_LIB=""
  [[ -n $PIN_LIB ]] || {
		echo "One must define PIN_LIB when PIN=1"
		exit 1
	}

  # PIN_TOOL   => The tool used
  [[ -z $PIN_TOOL ]] || {
    echo "You must define a PIN_TOOL variable before using tf with PIN"
    exit 1
  }

  # PIN_FLAGS  => Flags to pass to PIN
  [[ -n $PIN_FLAGS ]] || PIN_FLAGS=" "

  echo "PIN_PATH is set to $PIN_PATH"
  echo "PIN_LIB is set to $PIN_LIB"
  echo "PIN_TOOL is set to $PIN_TOOL"
  PIN_ROOT=$PIN_PATH make -C $PIN_LIB
fi

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # --

# perf
[[ -n $PERF ]] || PERF=0

if [[ $PERF -eq 1 ]]; then
  #PERF EVENT
  [[ -n $PERF_TOOL ]] || PERF_TOOL="mem_uops_retired.all_loads" # mem-stores

  #USER OR KERNEL SPACE
  [[ -n $PERF_TYPE ]] || PERF_TYPE="u"

  #OUTPUT FILE
  [[ -n $PERF_FILE ]] || PERF_FILE="perf_${PERF_TOOL}_${PERF_TYPE}.out"
  
  PERF_BIN="${HOME}/pmu-tools/ocperf.py"
  
  echo "PERF_BIN is set to $PERF_BIN"
  echo "PERF_TOOL is set to $PERF_TOOL"
  echo "PERF_TYPE is set to $PERF_TYPE"
fi

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- 

BASEDIR="$(pwd)"

BENCHSDIR="$BASEDIR/Benchs/"

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- 

echo "#########################"
echo "DEBUG is set to $DEBUG"
echo "RUNTIME is set to $RUNTIME"
echo "CLEAN is set to $CLEAN"
echo "PIN is set to $PIN"
echo "EXEC is set to $EXEC"
echo "COMPILE is set to $COMPILE"
echo "suffix is set to $suffix"
echo "BASEDIR is set to $BASEDIR"
echo "BENCHSDIR is set to $BENCHSDIR"
echo "PHOENIX is set to $PHOENIX_PATH"
echo "PASS is set to $PASS"
echo "DIFF is set to $DIFF"
echo "OPT is set to $OPT"
echo "PERF is set to $PERF"
echo "#########################"
