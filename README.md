# bash-resume
Adds support in shell scripts to resume scripts at last failing point with subsequent invocations. Think of it like "make" for shell scripts.

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


Installation
------------

**Install for all users on Local System**

1. Check out the git repo, or download and unpack one of the releases from https://github.com/kata198/bash-resume/releases

2. Inside the unpacked directory, either run *sudo ./install.sh* or change user to root and run *./install.sh*.

    If you want to install to an alternate prefix (default is to just install into /etc), execute like:

      ./install.sh PREFIX="/opt/bash-resume"

    To install as /opt/bash-resume/etc/bash-resume.sh

    DESTDIR will also affect installation path.

    For example, to install into your home directory, run:

      ./install.sh DESTDIR="${HOME}"

    And it will install as "${HOME}/etc/bash-resume.sh"


    If you want to just "force it" and have it go into a specific directory, such as if you have a script install it into a site somewhere as part of setup, or if you want it in a special directory in your home dir and don't want to mess with two variables, set *INSTALL_DIR*. The presence of *$INSTALL_DIR* means that PREFIX and DESTDIR are both ignored, and what is given is used as the path. 
    
    For example, to install as /mnt/thumbdrive/Shared:

      ./install.sh INSTALL_DIR=/mnt/thumbdrive/Shared

**Packaging**

Just set DESTDIR to the "package directory" variable in yourpackaging software.

For ArchLinux (pacman/makepkg) : 

	./install.sh DESTDIR="${pkgdir}"

For RPM:
	
	./install.sh DESTDIR="${RPM_BUILD_ROOT}"


If you use another packaging medium, use whatever "package root" is for that environment.

**Shipping with your code / Redistribution**

bash-resume.sh can be shipped with your code for portability.
It is under LGPL, so you may redistribute it with your software without modification, but should you alter the contents of bash-resume.sh in any way, you must publish those changes to https://github.com/kata198/bash-resume after which you may resume distribution of your modified bash-resume.sh. *To reiterate, you can ship bash-resume verbatim alongside your product/project/scripts/whatever . You must also include the LICENSE file. If you modify the code in whole or in part or reuse it or embed it within your product, you must submit your changes back to me in order to distribute it.* 

Compatability
-------------

bash-resume should be compatiable with any sh-based shell, and has been tested with dash, ksh, mksh, zsh, and bash. Will not run on csh-based shells (like tcsh)
