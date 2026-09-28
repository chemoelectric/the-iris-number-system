.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

CC = gcc
CFLAGS = -O3 -std=gnu23 -march=native -mavx512f
LDFLAGS = -lm

grover_search_c_SRCS =
grover_search_c_SRCS += givens_grover.c
grover_search_c_SRCS += givens_grover_table.c
grover_search_c_SRCS += main.c
grover_search_c_SRCS += givens_grover.h
grover_search_c_SRCS += givens_grover_table.h

grover_search_c_OBJS = \
	$(patsubst %.c,%.o,$(filter %.c,$(grover_search_c_SRCS)))

.PHONY: clean
clean:: ; -rm -f $(grover_search_c_OBJS)

.PHONY: all
all:: grover_search_c
clean:: ; -rm -f grover_search_c

grover_search_c: $(grover_search_c_OBJS)
	$(CC) $(CFLAGS) $(filter %.o %.a %.so,$(^)) $(LDFLAGS) -o $(@)
