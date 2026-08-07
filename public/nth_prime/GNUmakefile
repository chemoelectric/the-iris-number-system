.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

MKDIR_P = mkdir -p

FC = gfortran
FCFLAGS = -std=f2023 $(OPTSFLAGS) $(WARNFLAGS)

CC = gcc
CFLAGS = -std=gnu23 $(OPTSFLAGS) $(WARNFLAGS)

DC = gdc
DFLAGS = $(DOPTSFLAGS) $(WARNFLAGS)

TARGET = nth-prime
D_TARGET = nth-prime-d
D128_TARGET = nth-prime-128-d

OPTSFLAGS =
OPTSFLAGS += -march=native -mtune=native
OPTSFLAGS += -O3
OPTSFLAGS += -fopenmp
OPTSFLAGS += -ffast-math
OPTSFLAGS += -funroll-loops
#OPTSFLAGS += -ftree-parallelize-loops=24
#OPTSFLAGS += -fno-stack-arrays
OPTSFLAGS += -flto

DOPTSFLAGS =
DOPTSFLAGS += -march=native -mtune=native
DOPTSFLAGS += -O3
DOPTSFLAGS += -ffast-math
DOPTSFLAGS += -funroll-loops
DOPTSFLAGS += -flto

WARNFLAGS =
WARNFLAGS += -Wall
WARNFLAGS += -Wextra

SRC_DIR = src
OBJ_DIR = build

FCSOURCES =
FCSOURCES += types_mod
FCSOURCES += sieve_mod
FCSOURCES += prime_count_mod
FCSOURCES += nth_prime_mod
FCSOURCES += main

CSOURCES =
CSOURCES += prime_c

SRCS =
SRCS += $(FCSOURCES:%=$(SRC_DIR)/%.f90)
SRCS += $(CSOURCES:%=$(SRC_DIR)/%.c)

OBJS =
OBJS += $(FCSOURCES:%=$(OBJ_DIR)/%.o)
OBJS += $(CSOURCES:%=$(OBJ_DIR)/%.o)

.PHONY: all clean d d128

$(D_TARGET): $(SRC_DIR)/nth_prime.d
	$(DC) $(DFLAGS) -o $(@) $(<)

$(D128_TARGET): $(SRC_DIR)/nth_prime_128.d
	$(DC) $(DFLAGS) -o $(@) $(<)

d: $(D_TARGET)
d128: $(D128_TARGET)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.f90
	$(FC) $(FCFLAGS) -J$(OBJ_DIR) -I$(OBJ_DIR) -c $(<) -o $(@)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $(<) -o $(@)

all:: $(TARGET)

$(TARGET): $(OBJS)
	$(FC) $(FCFLAGS) -o $(@) $(^)

$(OBJ_DIR)/prime_c.o: \
	$(SRC_DIR)/prime_c.c \
	$(SRC_DIR)/prime_c.h \
	| $(OBJ_DIR)
$(OBJ_DIR)/types_mod.o: \
	$(SRC_DIR)/types_mod.f90 \
	| $(OBJ_DIR)
$(OBJ_DIR)/sieve_mod.o: \
	$(SRC_DIR)/sieve_mod.f90 \
	$(OBJ_DIR)/types_mod.o \
	| $(OBJ_DIR)
$(OBJ_DIR)/prime_count_mod.o: \
	$(SRC_DIR)/prime_count_mod.f90 \
	$(OBJ_DIR)/types_mod.o \
	$(OBJ_DIR)/sieve_mod.o \
	| $(OBJ_DIR)
$(OBJ_DIR)/nth_prime_mod.o: \
	$(SRC_DIR)/nth_prime_mod.f90 \
	$(OBJ_DIR)/types_mod.o \
	$(OBJ_DIR)/sieve_mod.o \
	$(OBJ_DIR)/prime_count_mod.o \
	| $(OBJ_DIR)
$(OBJ_DIR)/main.o: \
	$(SRC_DIR)/main.f90 \
	$(OBJ_DIR)/types_mod.o \
	$(OBJ_DIR)/nth_prime_mod.o \
	| $(OBJ_DIR)

$(OBJ_DIR):
	$(MKDIR_P) $(OBJ_DIR)

clean::
	-rm -R -f $(OBJ_DIR) $(TARGET) $(D_TARGET) $(D128_TARGET)
