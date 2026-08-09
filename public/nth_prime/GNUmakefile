.DELETE_ON_ERROR:
.DEFAULT_GOAL := default

MKDIR_P = mkdir -p

DC ?= gdc
CC ?= gcc

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

D_TARGET = nth-prime-d
D64_TARGET = nth-prime-64-d
C_ROOT_TARGET = nth-root-c

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

$(D_TARGET): $(SRC_DIR)/nth_prime.d
	$(DC) $(DFLAGS) -fversion=standalone -fversion=LIMBS_128 -o $(@) $(<)

$(D64_TARGET): $(SRC_DIR)/nth_prime_64.d
	$(DC) $(DFLAGS) -fversion=standalone -o $(@) $(<)

$(C_ROOT_TARGET): $(SRC_DIR)/nth_root.c
	$(CC) $(CFLAGS) -DSTANDALONE=1 -DLIMBS_8192=1 -o $(@) $(<) -lm

.PHONY: d d64 c-root
d:: $(D_TARGET)
d64:: $(D64_TARGET)
c-root:: $(C_ROOT_TARGET)

clean::
	-rm -f $(D_TARGET) $(D64_TARGET) $(C_ROOT_TARGET)

.PHONY: default all
default:: all
all:: d d64 c-root

$(OBJ_DIR):
	$(MKDIR_P) $(OBJ_DIR)

clean::
	-rm -R -f $(OBJ_DIR)
