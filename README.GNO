README FOR BUNZIP2 FOR GNO
==========================
This is a port of the bunzip2 archive decompression program to the GNO
environment on the Apple IIgs.  It is based on Julian Seward's original
bzip2 program, but it includes only the decompression (and testing)
functionality; compression is disabled.  This archive also includes the
bzip2recover program, which may allow you to recover some data from a
partially corrupted bzip2 archive file.  These programs correspond to
Julian Seward's bzip2 version 1.0.2.


REQUIREMENTS
============
Bunzip2 reguires a ROM 01 or ROM 3 Apple IIgs (or an emulator thereof)
running IIgs System Software 6.0.1 and GNO 2.0.6 (or later).

Bunzip2 also needs considerable memory.  It will not be able to decompress
most archives if you have less than 4 megabytes of RAM.  On 4-5 MB
systems, you will likely have to specify the -s option to minimize memory
usage; on an 8MB (or 14MB) system, this will probably not be necessary,
unless you have a very large number of system extensions or other programs
running under GNO.  See the manpage for more details on memory usage.
If bunzip2 gives you an out-of-memory error the first time you run it, try
again.  The first attempt may have caused the system to reorganize memory
and purge unneeded data, freeing up enough space to run bunzip2 on the
second attempt.

Bunzip2 will also benefit from an accelerator, although one is obviously
not required.  Even with an accelerator, it can be rather slow when
decompressing larger archives.  Be prepared to wait a very long time
(several hours or even longer) for bunzip2 to finish decompressing large
bzip2 archives.


INSTALLATION
============
To install bunzip2, simply run "dmake justinstall".  Alternatively, you can
install it manually: copy the bunzip2 and bzip2recover programs to your GNO
installation's /usr/local/bin directory, and copy the bunzip2.1, bzcat.1,
and bzip2recover.1 manpages to the /usr/local/man/man1 directory.

After installing bunzip2, you should read the manpage for directions on how
to use it.  You can put the following line in your gshrc file so you can use
'bzcat' as documented in the manpage:

alias bzcat "bunzip2 -c"


NOTES ON THE SOURCE CODE
========================
[If you just want to use bunzip2, you do not need to read this section.]

Please note that a couple source files use non-ProDOS compatible filenames.
If you do not have an HFS or AppleShare partition available, these can
easily be changed to fit ProDOS conventions.

I had to make several changes to the bzip2 program when porting it to GNO.
The code is not very good-looking, but it does compile without warnings.

First, I disabled the compression functionality and set up the program to
decompress by default (and I renamed the binary to 'bunzip2' to reflect
this).  The compression functionality is not very important on the GS, since
bzip2 is not a very good choice for compressing GS-specific data; ShrinkIt
will be much faster and preserves GS-specific file attributes.  Even if you
want to create archives for use on UNIX-like systems, compress or gzip is
a better choice, and both are already available under GNO.  For these
reasons, and because it reduced the amount of code that I had to modify, I
removed the compression functionality from bunzip2.

Other major changes to the code fell into several categories:
(1) Type sizes: Most of the code used defines for types such as Int32, making
    it easy to adapt to the GS's 16-bit ints.  The interface between the
    bzip2 program and code designed to be compiled as 'libbzip2,' however,
    assumes that int is 32 bits, so I had to modify it to use the appropriate
    integer types on the GS.  There were also silent assumptions in some
    other areas that native ints are 32 bits, and I had to identify and
    correct these.  There were also variables specified as 'Int32' even
    though 16 bits were sufficient to represent their possible range of
    values; when I noticed these variables, I changed them appropriately.

(2) ORCA/C compiler limitations: ORCA/C in its 'small mode' (the only one
    supported by the GNO libraries) places a 64k restriction on the size
    of data structures that can be addressed as arrays.  This is a problem
    with bunzip2, which allocates and uses multi-megabyte data structures.
    To work around this, I changed array-style references to these data
    structures to use printer arithmetic instead, working around the
    limitation (eg. I changed references to 'a[b]' to '*(a+b)'. ).  I also
    changed large local variables to be static or dynamically allocated
    in order to avoid excessive stack usage.
                        
(3) ORCA/C compiler bugs: In several cases ORCA/C 2.1.0 generated bad code
    at the maximum optimization level.  Most instances where reduced
    optimization levels are used are necessary to work around bugs encountered
    when using the disabled optimizations.  Also, the size of the main
    decompression function in decompress.c stresses ORCA/C.  I modified
    the GET_BITS macro to reduce the code size of the BZ2_decompress function
    by making some of the code into a separate function.  If this is not done
    or if optimization is not enabled (increasing the compiled code size
    as compared to when optimization is enabled), the compiler will crash,
    give an error, or generate bad object code that gives linker errors.

(4) Modifications to work well with GNO and GS/OS  These include setting the
    output filetype and disabling newline translation in GNO's stdio
    implementation.  I also set the stack  sizes of the programs to
    appropriate values and enabled stack checking for the small recursive
    segment of the program (although it shouldn't actually pose any problem).
    Additionally, I changed filename operations to be case-insensitive,
    reflecting the case-insensitive nature of filesystems in the Apple IIgs.

I made most modifications conditional on the __appleiigs__, __ORCAC__, or
__GNO__ macros.  Which macro I used gives some hint at the reason for each
modification, although all or none should be used to produce a working
executable (changes conditionalized on one macro may depend on those
conditionalized on another).


COMPILING
=========
The included Makefile can be used with dmake, occ, and ORCA/C 2.1.0, all of
which should be installed in your GNO 2.0.6 installation.  You will also need
a copy of the lsaneglue library (which is missing from the default GNO 2.0.6
installation) to be present in your GNO /lib directory.  Run 'dmake bunzip2'
to build the main program or 'dmake test' to build both programs and run a
simple test to ensure that bunzip2 is working correctly.

There are some special considerations necessary when compiling the file
decompress.c.  As noted above, it must be compiled with (nearly) full
optimization to compile properly.  To compile it with full optimization using
ORCA/C 2.1.0, however, requires more than 8MB of memory.  Thus, decompress.c
(and by extension the bunzip2 program as a whole) can only be compiled on an
emulator with 14MB memory support enabled.  The only emulators that presently
support this are Bernie ][ The Rescue and Sweet16.  I have included a
prebuilt object file (decompress.o) so that you can rebuild bunzip2 with
changes to other source files using a real IIgs.


AREAS FOR IMPROVEMENT
=====================
* Resource forks and GS/OS filetypes are not supported.  This is not a major
  problem; other programs such as ShrinkIt should be used for GS-specific
  archives.
* Compression could be reenabled.  This would require adapting the compression
  and block sorting routines to work properly under GNO on the GS.
* Some or all of the program could be rewritten in assembly language.  This
  would improve its performance by some amount, although I don't know how
  much.  It also might reduce memory usage.  This would require a full
  understanding of the BWT compression and decompression algorithms used in
  bzip2, which I do not presently possess.


SUPPORT
=======
I can be contacted by email at sheumann@myrealbox.com .  Please contect me,
rather than Julian Seward, about any problems that you are experiencing only
in the GNO version of bunzip2.

--
Stephen Heumann <sheumann@myrealbox.com>
