#!/bin/bash

# Cleans up example.sh so it can run again

source bash-resume.sh

br_init ".br-test"

br_reset;
rm -f .blah.txt >/dev/null 2>&1

