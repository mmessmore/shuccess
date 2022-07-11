#!/bin/bash

prog="${0##*/}"
full_prog_path="$0"

GREEN="$(tput bold)$(tput setaf 2)"
RED="$(tput bold)$(tput setaf 1)"
RESET="$(tput sgr0)"
VERBOSE=0

usage() {
	cat <<EOM
${prog}
  A unit testing framework for shell.

USAGE
  ${prog} [-v] [TEST_NUM]
  ${prog} -P
  ${prog} -h

ARGUMENTS
  TEST_NUM    Optionally specify a specific test by number

OPTIONS
  -h           This friendly help message
  -P           Print all tests
  -v           Verbose, set more than once to be more verbose
EOM
}


################################################################################
# These hook functions are always run, so do not remove them.
#   - You can set them to just "return 0" if you want them to be noops.
#   - Fill them in if you want to do things within them for hooks
#
# pre_run   executed before testing starts
# post_run  executed after testing end
# pre_test  executed before every individual test
#           always passed the test function name as the first argument
# post_test executed after every individual test
#           always passed the test function name as the first argument
################################################################################

pre_run() {
	verbose 1 "Starting testing"
	return 0
}

post_run() {
	verbose 1 "Finished testing"
	return 0
}

pre_test() {
	local func="$1"
	verbose 1 "Running ${func}"
	return 0
}

post_test() {
	local func="$1"
	verbose 1 "Finished ${func}"
	return 0
}

################################################################################
# ADD TESTS HERE
# Tests need a comment before them in the format:
# test [number] [description]
################################################################################

# test 1 Dummy success test
test_positive() {
	return 0
}

# test 2 Dummy failure test
test_negative() {
	return 1
}

################################################################################
# STOP ADDING TESTS
################################################################################

verbose() {
	local verbosity="$1"
	shift
	local msg="$*"
	[ "$VERBOSE" -ge "$verbosity" ] && echo "$msg"
}

get_tests() {
	local num="$1"
	awk '/^# *test *[0-9]/{num=$3; getline; print num,$1}' "$full_prog_path" |
		sort -k1 -n |
		tr -d '()' |
		if [ -n "$num" ]; then
			grep "^${num} "
		else
			cat
		fi |
		cut -d' ' -f 2
}

list_tests() {
	awk \
		'/^# *test *[0-9]/{printf $3": ";for(i=4;i<=NF;i++) printf $i" ";print ""}'\
		"$full_prog_path" |
		sort -k1 -n
}

run_test() {
	local func="$1"
	pre_test "$func"
	if eval "$func"; then
		success "$func"
	else
		fail "$func"
	fi
	post_test "$func"
}

success() {
	local func="$1"
	desc=$(get_desc "$func")
	echo "${GREEN}SUCCESS: ${func}:${desc}${RESET}"
}

fail() {
	local func="$1"
	desc=$(get_desc "$func")
	echo "${RED}FAIL: ${func}:${desc}${RESET}"
}

get_desc() {
	local func="$1"
	awk '$1 ~ /^test_positive/{print f} {f=""; for (i=4; i<=NF; i++) f=f" "$i}' "$full_prog_path"
}

while getopts hPv OPT; do
	case "$OPT" in
		h)
			usage
			exit 0
			;;
		P)
			list_tests
			exit 0
			;;
		v)
			VERBOSE=$((VERBOSE + 1))
			;;
		*)
			error 22 "Invalid argument: ${OPT}"
			;;
	esac
done

shift $((OPTIND -1))
TEST_NUM="$1"

echo "VERBOSE=${VERBOSE}"
pre_run
get_tests "$TEST_NUM" |
	while read -r test; do
		run_test "$test"
	done
post_run
