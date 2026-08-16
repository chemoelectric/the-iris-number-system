.DELETE_ON_ERROR:
.DEFAULT_GOAL := default

MKDIR_P = mkdir -p

DC = gdc
CC = gcc
FC = gfortran
M2C = gm2

ifeq ($(COVERAGE),1)
# We strip -O3 and -march so lcov can accurately map assembly back to
# lines.
DFLAGS = -g -O0 --coverage
CFLAGS = -g -O0 --coverage
FCFLAGS = -g -O0 --coverage
M2FLAGS = -g -O0 -fiso
LDFLAGS = --coverage
else
DFLAGS = $(DOPTSFLAGS) $(WARNFLAGS)
CFLAGS = $(COPTSFLAGS) $(WARNFLAGS)
FCFLAGS = $(FCOPTSFLAGS) $(WARNFLAGS)
M2FLAGS = $(M2OPTSFLAGS) $(WARNFLAGS)
LDFLAGS =
endif

F64_TARGET = nth-prime-64-f
D64_TARGET = nth-prime-64-d
C64_TARGET = nth-prime-64-c
M2_TARGET = nth-prime-64-m2

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

FCOPTSFLAGS =
FCOPTSFLAGS += -std=f2023
FCOPTSFLAGS += -O3
FCOPTSFLAGS += -march=native -mtune=native
FCOPTSFLAGS += -fopenmp
FCOPTSFLAGS += -funroll-loops
FCOPTSFLAGS += -flto=auto

M2OPTSFLAGS =
M2OPTSFLAGS += -fiso
M2OPTSFLAGS += -O3
M2OPTSFLAGS += -march=native -mtune=native
M2OPTSFLAGS += -funroll-loops
M2OPTSFLAGS += -flto=auto

WARNFLAGS =
WARNFLAGS += -Wall
WARNFLAGS += -Wextra

SRC_DIR = src
OBJ_DIR = build

.PHONY: clean

$(F64_TARGET): $(SRC_DIR)/types_mod.f90 $(SRC_DIR)/nth_prime_64.f90 $(SRC_DIR)/main.f90
	$(FC) $(FCFLAGS) -o $(@) $(^)

$(D64_TARGET): $(SRC_DIR)/nth_prime_64.d
	$(DC) $(DFLAGS) -fversion=standalone -o $(@) $(<)

$(C64_TARGET): $(SRC_DIR)/nth_prime_64.c
	$(CC) $(CFLAGS) -DSTANDALONE=1 -o $(@) $(<) -lm

$(M2_TARGET): $(SRC_DIR)/NthPrime64.def $(SRC_DIR)/NthPrime64.mod $(SRC_DIR)/MainM2.mod
	$(M2C) $(M2FLAGS) -I$(SRC_DIR) -c $(SRC_DIR)/NthPrime64.mod -o $(SRC_DIR)/NthPrime64.o
	$(M2C) $(M2FLAGS) -I$(SRC_DIR) -c $(SRC_DIR)/MainM2.mod -o $(SRC_DIR)/MainM2.o
	$(M2C) $(M2FLAGS) -I$(SRC_DIR) -o $(@) $(SRC_DIR)/MainM2.o $(SRC_DIR)/NthPrime64.o

.PHONY: f64 d64 c64 m2
f64:: $(F64_TARGET)
d64:: $(D64_TARGET)
c64:: $(C64_TARGET)
m2:: $(M2_TARGET)

clean::
	-rm -f $(F64_TARGET) $(D64_TARGET) $(C64_TARGET) $(M2_TARGET) $(SRC_DIR)/*.o

.PHONY: default all
default:: all
all:: f64 d64 c64 m2

$(OBJ_DIR):
	$(MKDIR_P) $(OBJ_DIR)

clean::
	-rm -R -f $(OBJ_DIR)
