# bash-resume
Adds support in shell scripts to resume scripts at last failing point with subsequent invocations.

Use this for long-running scripts that may fail (like builds) and need corrections, and it will resume where last left off.

It will run each command just once (unless manual intervention, see commands below br\_reset and br\_clear), so upon failure calling the script again

will cause it to continue where it left off, by running the failing command again.


Example
-------

See https://raw.githubusercontent.com/kata198/bash-resume/master/example.sh

Another Example
---------------

Here is a common example. If you are fixing errors, you don't want "configure" to run again if it completed successfully, so rerunning the script will cause it to skip to the last completed command.

    source bash-resume.sh

    br_init build_script


    br ./configure --prefix=/usr

    nbr root_make make

    pushd otherdir

    nbr otherdir_make make -j2

    popd

    br make install


Commands
--------

    br_init  - Takes one argument, the "resume" filename. Must be writeable. If this is not called, all br and nbr commands will be no-ops (that is, they will always just execute).

    nbr      - Takes an argument of a given name (like myMake) for the command, and the remainder is the command. Use this if you need to clear specific commands, or execute the same command signature multiple times. If command successful (returns 0), will not be run on subsequent calls to the script. Otherwise the script will abort with the error code.

    br       - Takes just the command to run and arguments. Generates a hash of the command based on the signature, and will run this for one successful run.

    br_reset  - Resets the state, clearing the note of all "Successful" commands. Use this to invoke a script again and run everything.

    br_clear  - Takes a single argument, the name given to nbr (or a hash if you used br, see br_hash function for generating one, but be smart and just name it with nbr). Clears the runstate of that command so it will execute again on next invocation.

    br_hash   - Generates a hash from a command, uses md5sum.


Complex Commands
----------------

If you need to pipe or capture output, etc, it is best to write that in a function and use br/nbr to call that function.


Installation / License
----------------------

bash-resume.sh can be shipped with your code for portability. It is under LGPL, so you may redistribute it with your software, but must publish any modifications. You must also distribute the LICENSE file.

It comes with an install.sh which will install it into /etc if you want it on all your systems. It will use the standard env variable DESTDIR if you want to package it (like in $RPM_BUILD_ROOT or $pkgdir)

Compatability
-------------

bash-resume should be compatiable with any sh-based shell, and has been tested with dash, ksh, mksh, zsh, and bash. Will not run on csh-based shells (like tcsh)
