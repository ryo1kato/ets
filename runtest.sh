#!/bin/sh

##
## A test case has a name "BASENAME[__SUBNAME]" and in its testcase-configuration file,
## (in name BASENAME[_SUBNAME].test) it may define
##    - ETS-configuration file (set by "config" variable. default: *.config)
##    - Template file (set by "template" variable. default: *.template)
##    - setup() shell function (default empty)
##    - teardown() function (default is to diff against BASENAME.expected)
##
## If a testcase-configuration is not exist or omits any of above definitions,
## the default file/function shall be used.
##
## The basename of files/functions are searched in order of BASENAME__SUBNAME
## to BASENAME. Take a *.config file as an example, if a testcase name is "foo__bar".
##    1. foo__bar.test is loaded as a testcase-configuration.
##    2. A file named "$config" is searched if $config is defined.
##    3. "foo__bar.config" is searched.
##    4. "foo.config" is searched.
##

TEST_CASES="basic undef template_name outfile_name outfile_name__O_opt outfile_name__overwrite"
TEST_CASES_FAIL="basic__t_opt basic__o_opt undef__fail outfile_name__O_and_o_opt outfile_name__overwrite_no_W"

PYTHON="python2.5"
TESTDIR="./test"
TESTDATA="./test/data"


##############################################################################

is_defined ()
{
    type $1 > /dev/null 2>&1
}

search_file_and_use ()
{
    local testname=$1
    local type=$2

    local fullname="$TESTDATA/$testname.$type"
    local super="$TESTDATA/${testname%__*}.$type"

    if [ -e $fullname ]; then
        echo "Using $type=$fullname"
        eval $type=$fullname
    elif [ -e $super ]; then
        echo "Using $type=$super"
        eval $type=$super
    else
        echo "ERROR: coudn't find *.$type file for $testname"
        exit 1
    fi
}

runtest ()
{
    case $1 in
        -f|--fail)
            local opt_fail=yes
            shift;;
    esac
    local testname=$1

    (
        echo "TestCase $testname"
        export testname=$testname
        export stdout="out-$testname.stdout"
        export stderr="out-$testname.stderr"

        # this set -e doesn't work... Why?
        #set -e

        ##
        ## Setup
        ##
        if [ -e $TESTDIR/$testname.test ]
        then
            echo "Using file $testname.test"
            . $TESTDIR/$testname.test
        else
            echo "No testcase config found: Trying default."
        fi

        if is_defined setup
        then
            echo "Using function setup()"
            setup || exit 2
        fi

        [ -z $config ] && search_file_and_use $testname config || exit 1
        [ -z $template ] && search_file_and_use $testname template || exit 1
        if [ "$opt_fail" != "yes" ] && ! is_defined teardown; then
            [ -z $expected ] && search_file_and_use $testname expected || exit 1
        fi

        ##
        ## Execute
        ##
        cmdline="$PYTHON ./ets.py ${option} ${config} ${template}"
        echo ">>>> $cmdline"
        $cmdline 1> $stdout 2> $stderr
        command_ret=$?
        echo "command_ret: $?"

        echo "--- stdout ----"
        cat $stdout
        echo "--- stderr ----"
        cat $stderr
        echo "---------------"


        ##
        ## Tear-down
        ##
        if is_defined teardown
        then
            echo "Using function teardown()"
            teardown $command_ret
        else
            if [ "$opt_fail" = "yes" ]; then
                # If it's a 'should-fail' testcase, just check
                # $command_ret is non-zero
                echo "Using default teardown(just check ret!=0)"
                [ $command_ret -ne 0 ]
            elif [ $command_ret -eq 0 ]; then
                echo "Using default teardown(diff)"
                # Default behaviour is to check the stdout against
                # $testname.expected for normal testcase.
                echo ">>>> diff $expected out-$testname.stdout ----"
                diff -u $expected out-$testname.stdout
            else
                false
            fi
        fi
        teardown_ret=$?

        rm -f out-$testname.stdout
        rm -f out-$testname.stderr

        exit $teardown_ret
    )
    return $?
}

##############################################################################
case $1 in
    '')
        : ;;
    -k|--keep)
        opt_keep=yes;;
    *)
        echo "runtest.sh: ERROR: Unknown option: $1"
        exit 1
        ;;
esac

count_total=0
count_fail=0

echo "Running tests ..."
echo
for test in $TEST_CASES
do
    let count_total++
    echo -n "    * $test ... "
    if runtest $test > test-$test.log
    then
        echo OK
        [ "$opt_keep" = yes ] || rm -f test-$test.log
    else
        echo FAIL
        let count_fail++
    fi
done

for test in $TEST_CASES_FAIL
do
    let count_total++
    echo -n "    ! $test ... "
    if runtest --fail $test > test-$test.log
    then
        echo OK
        [ "$opt_keep" = yes ] || rm -f test-$test.log
    else
        echo FAIL
        let count_fail++
    fi
done

echo
echo "Summary: $count_fail/$count_total failure"
echo

if [ $count_fail -ge 1 ]; then
    exit 1
else
    exit 0
fi

