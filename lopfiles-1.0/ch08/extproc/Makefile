# $Id: Makefile,v 1.1 2001/11/30 23:26:32 bill Exp $
# From "Learning Oracle PL/SQL" Chapter 8

# Simple "Makefile" to use when building pllp.so on Solaris

all:	pllp.o pllp.so

pllp.so: pllp.o
	/usr/ccs/bin/ld -G -o pllp.so pllp.o

pllp.o:	pllp.c
	gcc -c pllp.c

