#!/bin/bash

# bash-resume.sh - Allows executing scripts with resume support. Will track what commands have completed, and (by default) exit on failure,
#  with subsequent runs skipping already-completed tasks.
#
#  See https://github.com/kata198/bash-resume
#
#   Look for example.sh for example usage, and use comments herein or README.md for documentation.
#
# Copyright (c) 2015 Timothy Savannah All Rights Reserved
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3.0 of the License, or (at your option) any later version.

# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this library.
# It can be found as LICENSE

# vim: set ts=4 sw=4 expandtab :

# Internal - Don't mess with these variables
_BR_INITTED=0
_BR_FILENAME=

br_init() {
    # Inits bash-resume. Takes a single argument, which is the filename used for tracking command success.
    #  If you don't call this, but still source this file, br and nbr will always execute commands.
    if [ -z "$1" -o "$#" -ne 1 ];
    then
        echo "br_init must be called with a filename as the argument. Resuming is disabled." 2>&1
    return 1
    fi
    _BR_FILENAME="$1"
    touch "$_BR_FILENAME"
    if [ $? -ne 0 ];
    then
        echo "Failed to modify/create $_BR_FILENAME. Resuming is disabled." 2>&1
        return 1
    fi
    export _BR_FILENAME
    export _BR_INITTED=1
}

br_reset() {
    # br_reset - Will reset the resume file, thus next execution will run everything
    if [ "$_BR_INITTED" -eq 1 ];
    then
        > "$_BR_FILENAME"
    fi
}

br_clear() {
    #br_clear - Will clear a specific command. Should be used with nbr, but you can pass the full command to br_hash to generate the hash as well.
    if [ $_BR_INITTED = 0 ];
    then
        return
    fi
    sed "/$1/d" -i "$_BR_FILENAME"
}

br() {
    # br - Run a command with a generated identifier.
    #  Using this will generate an hash of the given command.
    #  Use this for unique commands, use `nbr` and provide a name instead
    #  if you have multiple commands with the same signature.
    #
    #  Example: br rm x -Rf;
    if [ "$_BR_INITTED" -eq 0 ];
    then
        _br_just_exec "$@"
        return $?
    fi
    HASH=$(br_hash "$@")
    nbr "$HASH" "$@"
    return $?
}


nbr() {
    # nbr - Run a command with a specific identifier.
    #  use this if you have the same command that is executed multiple times,
    #  to prevent subsequent executions from being skipped.
    #   Names should be alpha-numeric only.
    #
    #  Example: nbr make_x make -j4

    HASH="$1"
    shift
    CMD="$1"
    shift
    if [ "$_BR_INITTED" -ne 1 ];
    then
        _br_just_exec "$CMD" "$@"
        return $?
    fi
    ALREADY_RAN=$(grep "^${HASH}$" "$_BR_FILENAME" 2>/dev/null || true)
    [ ! -z "$ALREADY_RAN" ] && return 0;
    "$CMD" "$@"
    RET=$?
    if [ $RET -eq 0 ];
    then
        echo "$HASH" >> "$_BR_FILENAME"
        return 0
    fi
    exit $RET
}

br_hash() {
    # Generates a hash from a command
    printf "%s" "$@" | md5sum | awk {'print $1'}
}

_br_just_exec() {
    # Just executes the command, used if br_init is never called.
    CMD="$1"
    shift
    "$CMD" "$@"
    return $?
}
