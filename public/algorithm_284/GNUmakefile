# GNUmakefile for Algorithm 284: In-Place Block Interchange
# Author: Frédéric Blondin Custer

CC ?= gcc
CFLAGS ?= -std=c2x -Wall -Wextra -pedantic -O3 -march=native

TARGET = alg284_demo
SRCS = main.c
HEADERS = algorithm_284.h

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(SRCS) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ $(SRCS)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) *.o
