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

D_TARGET = nth-prime-d
D64_TARGET = nth-prime-64-d
C_TARGET = nth-prime-c
C64_TARGET = nth-prime-64-c
ZEN5_TARGET = nth-prime-zen5-c

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

ZEN5_CFLAGS = -O3 -march=znver5 -mtune=znver5 -mavx512f -mbmi2 -mpopcnt -funroll-loops -flto=auto

WARNFLAGS =
WARNFLAGS += -Wall
WARNFLAGS += -Wextra

SRC_DIR = src
OBJ_DIR = build

.PHONY: clean

$(D_TARGET): $(SRC_DIR)/nth_prime.d
	$(DC) $(DFLAGS) -fversion=standalone -fversion=LIMBS_256 -o $(@) $(<)

$(D64_TARGET): $(SRC_DIR)/nth_prime_64.d
	$(DC) $(DFLAGS) -fversion=standalone -o $(@) $(<)

$(C_TARGET): $(SRC_DIR)/nth_prime.c
	$(CC) $(CFLAGS) -DSTANDALONE=1 -DLIMBS_256 -o $(@) $(<) -lm $(GMP_LIBS)

$(C64_TARGET): $(SRC_DIR)/nth_prime_64.c
	$(CC) $(CFLAGS) -DSTANDALONE=1 -o $(@) $(<) -lm $(GMP_LIBS)

$(ZEN5_TARGET): $(SRC_DIR)/nth_prime_zen5.c
	$(CC) $(ZEN5_CFLAGS) $(WARNFLAGS) -DSTANDALONE=1 -o $(@) $(<) -lm $(GMP_LIBS)

.PHONY: d d64 c c64 zen5
d:: $(D_TARGET)
d64:: $(D64_TARGET)
c:: $(C_TARGET)
c64:: $(C64_TARGET)
zen5:: $(ZEN5_TARGET)

clean::
	-rm -f $(D_TARGET) $(D64_TARGET) $(C_TARGET) $(C64_TARGET) $(ZEN5_TARGET)

.PHONY: default all
default:: all
all:: d d64 c c64 zen5

$(OBJ_DIR):
	$(MKDIR_P) $(OBJ_DIR)

clean::
	-rm -R -f $(OBJ_DIR)
