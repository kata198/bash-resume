#!/bin/sh

# bash-resume.sh - Allows executing scripts with resume support. 
#
# How it works:
# -------------
#
#
# **The Very Short Version**
#
#  1. Source the bash-resume.sh script from your code
#
#  2. Add to top of script: br_init '/path/to/blah.db' 
#         Where the path you give is to a database that will be created
#          and used to track execution.
#
#  3. Before your "important" steps, place the words "br" (or "nbr", see long description below)
#      in front of your critical commands.
#
#      So like:
#
#          ./addDbUser $SOME_USERNAME --db=users
#
#      Becomes:
#
#          br ./asddDbUser $SOME_USERNAME --db=users
#
#  4. Run your script. For the commands prefixed with "br", the following will occur:
#
#       If exit code = 0 ( Success )
#
#          A hash of that command (or your custom title if you used "nbr")
#            is noted in the database.
#
#          If you run the script again without clearing the database,
#           or removing that field, that command will be skipped.
#
#        If exit code != 0 ( Failure )
#
#          Your script will abort at that point.
#
#          The next time you run it, all your setup code, for loops, etc stuff without the "br" prefix
#
#            will execute again, but the "critical" commands (like add new user to database) that already
#            completed will not. The script wiil then skip up to the point at which it last failed and run that 
#            command again.
#
# **Other Functions**
#
#   br_clear - Clear a specific hash. Use br_hash to get the hash if you didn't use nbr
#
#   br_reset - Clear the entire database file. Use this to re-execute all lines on next run.
#
# More below
#
#  Long/Alternate description:
#
#  You prefix your important/critical commands within the script
#    by one of the bash-resume functions, like:
#
#  br mycmd -h a --path="/somewhere/to/elsewhere"
#
#   or
#
#  nbr myTitleHere -h a ...
#
# The lines that you prefix with "br" or "nbr" are the lines where failure/success is tracked.
#
#   If they complete successfully, either an auto-generated hash (br) or a unique identifier provided
#    by you (nbr) is noted in the database (provided as the single argument to br_init).
#
# When you have bash-resume disabled (comment out the call to "br_init"), the 'br' and 'nbr' functions
#  act as if they weren't there, i.e. it just always executes your commands like normal.
# So you can turn it on/off , which is useful for certain cases
#
# br generates a hash from the commandline string.
#
#  If you have the same commandline string multiple times, (like a flush_cache.sh command, for example),
#   you will have to run it like:
#
#      nbr 'pre_install_flush' './flush_cache.sh --for-real'
#
#  Instead of
#
#     br './flush_cache.sh --for-real'
#
# Because once a success is marked in the database, future executions of your script will skip over that function.
#
# Automatically, if a command marked by 'br' or 'nbr' fails, your script will terminate.
#
# This allows you to have your setup code and variable code, for loops, etc just as regular code, but then have distinct steps be bash-resume, like
#
#  add user to system, add database user, set password, set quotas,  these could all be commands in your "setup new user" script.
#
#  If one of those steps fails, and maybe it's even an automatic invocation, your script will terminate
#
#    with that same exit code. Once the situation is resolved, you simply invoke your script again with the same arguments,
#
#  it performs all the setup code, for loops, whatever, but it will skip things like "add system user" or "setup quotas" or whatever succeded,
#   thereby skipping and resuming at the point of last failure.

#
#  See https://github.com/kata198/bash-resume
#
#   Look for example.sh for example usage, and use comments herein or README.md for documentation.
#
# Copyright (c) 2015, 2017 Timothy Savannah All Rights Reserved
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

# Global version information. May be used to extend, or detect the presence
#  of some newer feature and offer alternate algorithms, I dunno...
# But I'm a strong believer in shared knowledge.
#   Make it easy to find and it will know
#     its purpose...
_BR_VERSION="1.0.1"
_BR_VERSION_MAJOR=1
_BR_VERSION_MINOR=0
_BR_VERSION_PATCHLEVEL=1
_BR_VERSION_EXTRA=



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
