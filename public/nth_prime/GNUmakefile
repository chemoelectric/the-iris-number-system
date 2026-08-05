.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

MKDIR_P = mkdir -p
FC = gfortran
FCFLAGS = -std=f2023 -O3 -fopenmp -march=native -mtune=native $(MORE_OPTS) -Wall -Wextra
TARGET = nth-prime

MORE_OPTS =
MORE_OPTS += -ffast-math
MORE_OPTS += -funroll-loops
#MORE_OPTS += -ftree-parallelize-loops=24
#MORE_OPTS += -fno-stack-arrays
MORE_OPTS += -flto

SRC_DIR := src
OBJ_DIR := build

SRCS = $(SRC_DIR)/types_mod.f90 \
       $(SRC_DIR)/sieve_mod.f90 \
       $(SRC_DIR)/prime_count_mod.f90 \
       $(SRC_DIR)/nth_prime_mod.f90 \
       $(SRC_DIR)/main.f90

OBJS = $(OBJ_DIR)/types_mod.o \
       $(OBJ_DIR)/sieve_mod.o \
       $(OBJ_DIR)/prime_count_mod.o \
       $(OBJ_DIR)/nth_prime_mod.o \
       $(OBJ_DIR)/main.o

.PHONY: all clean

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.f90
	$(FC) $(FCFLAGS) -J$(OBJ_DIR) -I$(OBJ_DIR) -c $(<) -o $(@)

all:: $(TARGET)

$(TARGET): $(OBJS)
	$(FC) $(FCFLAGS) -o $(@) $(^)

$(OBJ_DIR)/types_mod.o: $(SRC_DIR)/types_mod.f90 | $(OBJ_DIR)
$(OBJ_DIR)/sieve_mod.o: $(SRC_DIR)/sieve_mod.f90 $(OBJ_DIR)/types_mod.o | $(OBJ_DIR)
$(OBJ_DIR)/prime_count_mod.o: $(SRC_DIR)/prime_count_mod.f90 $(OBJ_DIR)/types_mod.o $(OBJ_DIR)/sieve_mod.o | $(OBJ_DIR)
$(OBJ_DIR)/nth_prime_mod.o: $(SRC_DIR)/nth_prime_mod.f90 $(OBJ_DIR)/types_mod.o $(OBJ_DIR)/sieve_mod.o $(OBJ_DIR)/prime_count_mod.o | $(OBJ_DIR)
$(OBJ_DIR)/main.o: $(SRC_DIR)/main.f90 $(OBJ_DIR)/types_mod.o $(OBJ_DIR)/nth_prime_mod.o | $(OBJ_DIR)

$(OBJ_DIR):
	$(MKDIR_P) $(OBJ_DIR)

clean::
	-rm -R -f $(OBJ_DIR) $(TARGET)
