FC ?= gfortran
FCFLAGS ?= -std=f2023 -O3 -fopenmp -march=native -ffast-math -funroll-loops -Wall -Wextra
TARGET = nth-prime

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

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(FC) $(FCFLAGS) -o $@ $^

$(OBJ_DIR)/types_mod.o: $(SRC_DIR)/types_mod.f90 | $(OBJ_DIR)
	$(FC) $(FCFLAGS) -J$(OBJ_DIR) -c $< -o $@

$(OBJ_DIR)/sieve_mod.o: $(SRC_DIR)/sieve_mod.f90 $(OBJ_DIR)/types_mod.o | $(OBJ_DIR)
	$(FC) $(FCFLAGS) -J$(OBJ_DIR) -I$(OBJ_DIR) -c $< -o $@

$(OBJ_DIR)/prime_count_mod.o: $(SRC_DIR)/prime_count_mod.f90 $(OBJ_DIR)/types_mod.o $(OBJ_DIR)/sieve_mod.o | $(OBJ_DIR)
	$(FC) $(FCFLAGS) -J$(OBJ_DIR) -I$(OBJ_DIR) -c $< -o $@

$(OBJ_DIR)/nth_prime_mod.o: $(SRC_DIR)/nth_prime_mod.f90 $(OBJ_DIR)/types_mod.o $(OBJ_DIR)/sieve_mod.o $(OBJ_DIR)/prime_count_mod.o | $(OBJ_DIR)
	$(FC) $(FCFLAGS) -J$(OBJ_DIR) -I$(OBJ_DIR) -c $< -o $@

$(OBJ_DIR)/main.o: $(SRC_DIR)/main.f90 $(OBJ_DIR)/types_mod.o $(OBJ_DIR)/nth_prime_mod.o | $(OBJ_DIR)
	$(FC) $(FCFLAGS) -J$(OBJ_DIR) -I$(OBJ_DIR) -c $< -o $@

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

clean:
	rm -rf $(OBJ_DIR) $(TARGET)
