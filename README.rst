bash-resume
===========

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

	source bash\-resume.sh

	br\_init build\_script


	br ./configure \-\-prefix=/usr

	nbr root\_make make

	pushd otherdir

	nbr otherdir\_make make \-j2

	popd

	br make install


Commands
--------

	br\_init  \- Takes one argument, the "resume" filename. Must be writeable. If this is not called, all br and nbr commands will be no\-ops (that is, they will always just execute).

	nbr      \- Takes an argument of a given name (like myMake) for the command, and the remainder is the command. Use this if you need to clear specific commands, or execute the same command signature multiple times. If command successful (returns 0), will not be run on subsequent calls to the script. Otherwise the script will abort with the error code.

	br       \- Takes just the command to run and arguments. Generates a hash of the command based on the signature, and will run this for one successful run.

	br\_reset  \- Resets the state, clearing the note of all "Successful" commands. Use this to invoke a script again and run everything.

	br\_clear  \- Takes a single argument, the name given to nbr (or a hash if you used br, see br\_hash function for generating one, but be smart and just name it with nbr). Clears the runstate of that command so it will execute again on next invocation.

	br\_hash   \- Generates a hash from a command, uses md5sum.


Complex Commands
----------------

If you need to pipe or capture output, etc, it is best to write that in a function and use br/nbr to call that function.


Installation
------------

**Install for all users on Local System**

1. Check out the git repo, or download and unpack one of the releases from https://github.com/kata198/bash-resume/releases

2. Inside the unpacked directory, either run *sudo ./install.sh* or change user to root and run *./install.sh*.

	If you want to install to an alternate prefix (default is to just install into /etc), execute like:

	  ./install.sh PREFIX="/opt/bash\-resume"

	To install as /opt/bash\-resume/etc/bash\-resume.sh

	DESTDIR will also affect installation path.

	For example, to install into your home directory, run:

	  ./install.sh DESTDIR="${HOME}"

	And it will install as "${HOME}/etc/bash\-resume.sh"


	If you want to just "force it" and have it go into a specific directory, such as if you have a script install it into a site somewhere as part of setup, or if you want it in a special directory in your home dir and don't want to mess with two variables, set \*INSTALL\_DIR\*. The presence of \*$INSTALL\_DIR\* means that PREFIX and DESTDIR are both ignored, and what is given is used as the path. 
	
	For example, to install as /mnt/thumbdrive/Shared:

	  ./install.sh INSTALL\_DIR=/mnt/thumbdrive/Shared

**Packaging**

Just set DESTDIR to the "package directory" variable in yourpackaging software.

For ArchLinux (pacman/makepkg) : 

	./install.sh DESTDIR="${pkgdir}"

For RPM:
	
	./install.sh DESTDIR="${RPM\_BUILD\_ROOT}"


If you use another packaging medium, use whatever "package root" is for that environment.

**Shipping with your code / Redistribution**

bash-resume.sh can be shipped with your code for portability.

It is under LGPL, so you may redistribute it with your software without modification, but should you alter the contents of bash-resume.sh in any way, you must publish those changes to https://github.com/kata198/bash-resume after which you may resume distribution of your modified bash-resume.sh. *To reiterate, you can ship bash-resume verbatim alongside your product/project/scripts/whatever . You must also include the LICENSE file. If you modify the code in whole or in part or reuse it or embed it within your product, you must submit your changes back to me in order to distribute it.* 

Compatability
-------------

bash-resume should be compatiable with any sh-based shell, and has been tested with dash, ksh, mksh, zsh, and bash. Will not run on csh-based shells (like tcsh)


File Header
-----------

This section under construction...


	bash\-resume.sh \- Allows executing scripts with resume support. 

	How it works:

	\-\-\-\-\-\-\-\-\-\-\-\-\-


	\*\*The Very Short Version\*\*

	1. Source the bash\-resume.sh script from your code

	2. Add to top of script: br\_init '/path/to/blah.db' 

	Where the path you give is to a database that will be created

	and used to track execution.

	3. Before your "important" steps, place the words "br" (or "nbr", see long description below)

	in front of your critical commands.

	So like:

	./addDbUser $SOME\_USERNAME \-\-db=users

	Becomes:

	br ./asddDbUser $SOME\_USERNAME \-\-db=users

	4. Run your script. For the commands prefixed with "br", the following will occur:

	If exit code = 0 ( Success )

	A hash of that command (or your custom title if you used "nbr")

	is noted in the database.

	If you run the script again without clearing the database,

	or removing that field, that command will be skipped.

	If exit code != 0 ( Failure )

	Your script will abort at that point.

	The next time you run it, all your setup code, for loops, etc stuff without the "br" prefix

	will execute again, but the "critical" commands (like add new user to database) that already

	completed will not. The script wiil then skip up to the point at which it last failed and run that 

	command again.

	\*\*Other Functions\*\*

	br\_clear \- Clear a specific hash. Use br\_hash to get the hash if you didn't use nbr

	br\_reset \- Clear the entire database file. Use this to re\-execute all lines on next run.

	More below

	Long/Alternate description:

	You prefix your important/critical commands within the script

	by one of the bash\-resume functions, like:

	br mycmd \-h a \-\-path="/somewhere/to/elsewhere"

	or

	nbr myTitleHere \-h a ...

	The lines that you prefix with "br" or "nbr" are the lines where failure/success is tracked.

	If they complete successfully, either an auto\-generated hash (br) or a unique identifier provided

	by you (nbr) is noted in the database (provided as the single argument to br\_init).

	When you have bash\-resume disabled (comment out the call to "br\_init"), the 'br' and 'nbr' functions

	act as if they weren't there, i.e. it just always executes your commands like normal.

	So you can turn it on/off , which is useful for certain cases

	br generates a hash from the commandline string.

	If you have the same commandline string multiple times, (like a flush\_cache.sh command, for example),

	you will have to run it like:

	nbr 'pre\_install\_flush' './flush\_cache.sh \-\-for\-real'

	Instead of

	br './flush\_cache.sh \-\-for\-real'

	Because once a success is marked in the database, future executions of your script will skip over that function.

	Automatically, if a command marked by 'br' or 'nbr' fails, your script will terminate.

	This allows you to have your setup code and variable code, for loops, etc just as regular code, but then have distinct steps be bash\-resume, like

	add user to system, add database user, set password, set quotas,  these could all be commands in your "setup new user" script.

	If one of those steps fails, and maybe it's even an automatic invocation, your script will terminate

	with that same exit code. Once the situation is resolved, you simply invoke your script again with the same arguments,

	it performs all the setup code, for loops, whatever, but it will skip things like "add system user" or "setup quotas" or whatever succeded,

	thereby skipping and resuming at the point of last failure.


