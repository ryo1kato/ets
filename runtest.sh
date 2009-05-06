#!/bin/sh

TEST_CASES="test undef embed"
PYTHONS="python2.4 python2.5"


runtest () {
    local testname=$1
    local option=""
    local config="test/$testname.config"
    local template="test/$testname.template"


    case $testname in
        undef) option="--ignore-undef" ;;
        embed) template="" ;;
        *) : ;;
    esac

    for python in $PYTHONS
    do
        echo ---------- $python -----------
        $python ./ets $option $config $template |
            diff -u test/$testname.expected -
    done
}


echo "Running tests ..."
for test in $TEST_CASES
do
    echo -n "* $test ... "
    if runtest $test > test-$test.log 2>&1
    then
        echo OK
        rm -f test-$test.log
    else
        echo FAIL
    fi
done
