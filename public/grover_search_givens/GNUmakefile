CC ?= gcc
CFLAGS ?= -O3 -std=c2x -Wall -Wextra -pedantic -march=native -mavx512f
LDFLAGS ?= -lm

SRCS = givens_grover.c givens_grover_table.c main.c
OBJS = $(SRCS:.c=.o)
TARGET = grover_search_c

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDFLAGS)

%.o: %.c givens_grover.h givens_grover_table.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET) *.o

.PHONY: all clean
