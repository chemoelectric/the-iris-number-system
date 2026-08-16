.DELETE_ON_ERROR:
.DEFAULT_GOAL := default

MKDIR_P = mkdir -p

DC = gdc
CC = gcc

ifeq ($(COVERAGE),1)
# We strip -O3 and -march so lcov can accurately map assembly back to
# lines.
DFLAGS = -g -O0 --coverage
CFLAGS = -g -O0 --coverage
LDFLAGS = --coverage
else
DFLAGS = $(DOPTSFLAGS) $(WARNFLAGS)
CFLAGS = $(COPTSFLAGS) $(WARNFLAGS)
LDFLAGS =
endif

D64_TARGET = nth-prime-64-d
C64_TARGET = nth-prime-64-c

GMP_LIBS := $(shell pkg-config --libs gmp 2>/dev/null || echo "")

DOPTSFLAGS =
DOPTSFLAGS += -frelease
DOPTSFLAGS += -march=native -mtune=native
DOPTSFLAGS += -O3
DOPTSFLAGS += -funroll-loops
DOPTSFLAGS += -flto=auto

COPTSFLAGS =
COPTSFLAGS += -O3
COPTSFLAGS += -march=native -mtune=native
COPTSFLAGS += -fopenmp
COPTSFLAGS += -funroll-loops
COPTSFLAGS += -flto=auto

WARNFLAGS =
WARNFLAGS += -Wall
WARNFLAGS += -Wextra

SRC_DIR = src
OBJ_DIR = build

.PHONY: clean

$(D64_TARGET): $(SRC_DIR)/nth_prime_64.d
	$(DC) $(DFLAGS) -fversion=standalone -o $(@) $(<)

$(C64_TARGET): $(SRC_DIR)/nth_prime_64.c
	$(CC) $(CFLAGS) -DSTANDALONE=1 -o $(@) $(<) -lm $(GMP_LIBS)

.PHONY: d64 c64
d64:: $(D64_TARGET)
c64:: $(C64_TARGET)

clean::
	-rm -f $(D64_TARGET) $(C64_TARGET)

.PHONY: default all
default:: all
all:: d64 c64

$(OBJ_DIR):
	$(MKDIR_P) $(OBJ_DIR)

clean::
	-rm -R -f $(OBJ_DIR)
