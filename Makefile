# Makefile for bunzip2 for GNO (for use with dmake)
# Based on Unix Makefile for bzip2
# Modified for GNO by Stephen Heumann

# ORCA/C 2.1.0 may need more than 8 megabytes of RAM to compile decompress.c
# with full optimization enabled.  Thus, this makefile can only
# be used as is on an emulated system with 14 megabyte RAM support.

# To assist in cross-compiling
# Uncomment this if make doesn't have the $CC variable set appropriately
# CC=occ
RM=cp -p rm

LDFLAGS=

# The "-I /usr/include" shouldn't be needed but seemed to fix problems for me
CFLAGS=-a0 -w -O -I /usr/include

NOROOTFLAG=-r

# Where you want it installed when you do 'make install'
PREFIX=/usr/local


OBJS= stristr.o    \
      huffman.o    \
      crctable.o   \
      randtable.o  \
      decompress.o \
      bzlib.o

all: bunzip2 bzip2recover test

bunzip2: bzip2.o $(OBJS)
	$(CC) -o bunzip2 bunzip2.rez
	$(CC) $(CFLAGS) $(LDFLAGS) bzip2.o $(OBJS) -o bunzip2

bzip2recover: bzip2recover.o
	$(CC) -o bzip2recover bzip2recover.rez
	$(CC) $(CFLAGS) $(LDFLAGS) bzip2recover.o  -o bzip2recover

check: test
test: bunzip2
	@cat words1
	./bunzip2 -dk  < sample1.bz2 > sample1.tst
	./bunzip2 -dk  < sample2.bz2 > sample2.tst
	./bunzip2 -dks < sample3.bz2 > sample3.tst
	@cat words2
	cmp sample1.tst sample1.ref
	cmp sample2.tst sample2.ref
	cmp sample3.tst sample3.ref
	@cat words3

install: bunzip2 bzip2recover test justinstall

justinstall:
#	This should install bunzip2 for GNO under /usr/local
	mkdir $(PREFIX)/bin >& .null
	mkdir $(PREFIX)/man >& .null
	mkdir $(PREFIX)/man/man1 >& .null
	cp -f bunzip2 $(PREFIX)/bin/bunzip2
	cp -f bzip2recover $(PREFIX)/bin/bzip2recover
	cp -f bunzip2.1 $(PREFIX)/man/man1/bunzip2.1
	cp -f bzip2recover.1 $(PREFIX)/man/man1/bzip2recover.1
	cp -f bzcat.1 $(PREFIX)/man/man1/bzcat.1
	@cat words4

distclean: clean
clean:
	$(RM) -f *.o *.a *.sym *.root bunzip2 bzip2recover \
	sample1.tst sample2.tst sample3.tst

stristr.o: stristr.c
	$(CC) $(CFLAGS) $(NOROOTFLAG) -c stristr.c
huffman.o: huffman.c bzlib_private.h
	$(CC) $(CFLAGS) $(NOROOTFLAG) -c huffman.c
crctable.o: crctable.c bzlib_private.h
	$(CC) $(CFLAGS) $(NOROOTFLAG) -c crctable.c
randtable.o: randtable.c bzlib_private.h
	$(CC) $(CFLAGS) $(NOROOTFLAG) -c randtable.c
decompress.o: decompress.c bzlib_private.h
	$(CC) $(CFLAGS) $(NOROOTFLAG) -c decompress.c
bzlib.o: bzlib.c bzlib_private.h
	$(CC) $(CFLAGS) $(NOROOTFLAG) -c bzlib.c
bzip2.o: bzip2.c bzlib.h
	$(CC) $(CFLAGS) -s 2048 -C1 -c bzip2.c
#	$(CC) $(CFLAGS) -C1 -D __STACK_CHECK__ -c bzip2.c
bzip2recover.o: bzip2recover.c
	$(CC) $(CFLAGS) -s 1024 -c bzip2recover.c
#	$(CC) $(CFLAGS) -D __STACK_CHECK__ -c bzip2recover.c
bzlib_private.h: bzlib.h

chtyp:
	chtyp -l cc *.c *.h
