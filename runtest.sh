#!/bin/sh

TEST_CASES="test undef"


runtest () {
    local testname=$1
    local option

    case $testname in
        undef) option="--ignore-undef" ;;
        *)     option=""
    esac

    ./ets $option test/$testname.config test/$testname.template |
        diff -u test/$testname.expected -
}


echo "Running tests ..."
for test in $TEST_CASES
do
    echo -n "* $test ... "
    if runtest $test
    then
        echo OK
    else
        echo FAIL
    fi
done
