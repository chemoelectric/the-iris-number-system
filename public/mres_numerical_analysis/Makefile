# Makefile for m-resolution numerical analysis library and tests
# Strictly complies with C23 standard and GNU coding standards.

CC ?= gcc
CFLAGS ?= -O2 -Wall -Wextra -pedantic
AR ?= ar
ARFLAGS ?= rcs

all: libmres.a test_mres_analysis

mres_types.o: mres_types.c mres_types.h
	$(CC) $(CFLAGS) -c mres_types.c -o mres_types.o

mres_stiff_solver.o: mres_stiff_solver.c mres_stiff_solver.h mres_types.h
	$(CC) $(CFLAGS) -c mres_stiff_solver.c -o mres_stiff_solver.o

libmres.a: mres_types.o mres_stiff_solver.o
	$(AR) $(ARFLAGS) libmres.a mres_types.o mres_stiff_solver.o

test_mres_analysis: test_mres_analysis.c libmres.a
	$(CC) $(CFLAGS) test_mres_analysis.c -L. -lmres -lm -o test_mres_analysis

check: test_mres_analysis
	./test_mres_analysis

clean:
	rm -f *.o *.a test_mres_analysis

.PHONY: all check clean
