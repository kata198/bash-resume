#!/bin/bash

# Just an example of the concepts. This script will fail first run (on purpose) and complete on second run.
#  use example_reset.sh to reset it.
#
# Expected output from first run:
# -------------------------------
#
# Executed just once
# Print Twice
# Print Twice
# Script will fail in next line first run, run again should skip above prints and continue from this point.
#
# Expected output from second run:
# --------------------------------
#
# Second run, will resume from last point:
# Completed test. Run example_cleanup.sh to run it again.



source bash-resume.sh

br_init ".br-test"

fail_first_time() {
    if [ ! -f ".blah.txt" ];
    then
        echo "ok" > .blah.txt;
        return 1;
    fi
    return 0
}

# This comand will only be executed once
br echo "Executed just once"

nbr blargie echo "Print Twice"
nbr blargiz echo "Print Twice"

if [ ! -f ".blah.txt" ];
then
    echo "Script will fail in next line first run, run again should skip above prints and continue from this point."
else
    echo "Second run, will resume from last point:"
fi
# Script should fail here, second run will proceed.
br fail_first_time

# Clear the "done test" marker
br_clear done_test 

br echo "Executed just once"
nbr done_test echo "Completed test. Run example_cleanup.sh to reset the state before running it again."
