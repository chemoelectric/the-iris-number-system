FC := gfortran
FCFLAGS := -std=f2023 -O3 -march=native
MKDIR_P := mkdir -p

TARGET := nth-prime

.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

SRC_DIR = src
OBJ_DIR = build

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

.PHONY: clean

.PHONY: all
all:: $(TARGET)
clean::
	-rm -f $(TARGET)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.f90
	$(MKDIR_P) $(@D) && $(FC) -c $(FCFLAGS) -J$(OBJ_DIR) -o $(@) $(<)
clean::
	-rm -R -f $(OBJ_DIR)

$(TARGET): $(OBJS)
	$(FC) $(FCFLAGS) -o $(@) $(^)

$(OBJ_DIR)/types_mod.o: $(SRC_DIR)/types_mod.f90
$(OBJ_DIR)/sieve_mod.o: $(SRC_DIR)/sieve_mod.f90 $(OBJ_DIR)/types_mod.o
$(OBJ_DIR)/prime_count_mod.o: $(SRC_DIR)/prime_count_mod.f90 $(OBJ_DIR)/types_mod.o $(OBJ_DIR)/sieve_mod.o
$(OBJ_DIR)/nth_prime_mod.o: $(SRC_DIR)/nth_prime_mod.f90 $(OBJ_DIR)/types_mod.o $(OBJ_DIR)/sieve_mod.o $(OBJ_DIR)/prime_count_mod.o
$(OBJ_DIR)/main.o: $(SRC_DIR)/main.f90 $(OBJ_DIR)/types_mod.o $(OBJ_DIR)/nth_prime_mod.o
