.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

MKDIR_P = mkdir -p

DC = gdc

ifeq ($(COVERAGE),1)
# We strip -O3 and -march so lcov can accurately map assembly back to
# lines. Uncomment atomic update if multithreaded.
DFLAGS = -g -O0 --coverage # -fprofile-update=atomic
LDFLAGS = --coverage # -fprofile-update=atomic
else
DFLAGS = $(DOPTSFLAGS) $(WARNFLAGS)
LDFLAGS =
endif

D_TARGET = nth-prime-d
D128_TARGET = nth-prime-128-d

DOPTSFLAGS =
DOPTSFLAGS += -march=native -mtune=native
DOPTSFLAGS += -Ofast
#DOPTSFLAGS += -ffast-math
DOPTSFLAGS += -funroll-loops
DOPTSFLAGS += -flto
DOPTSFLAGS += -mprefer-vector-width=512
DOPTSFLAGS += -fopt-info-vec-optimized

WARNFLAGS =
WARNFLAGS += -Wall
WARNFLAGS += -Wextra

SRC_DIR = src
OBJ_DIR = build

.PHONY: all clean d d128

$(D_TARGET): $(SRC_DIR)/nth_prime.d
	$(DC) $(DFLAGS) -o $(@) $(<)

$(D128_TARGET): $(SRC_DIR)/nth_prime_128.d
	$(DC) $(DFLAGS) -o $(@) $(<)

.PHONY: d d128
d: $(D_TARGET)
d128: $(D128_TARGET)

all:: d d128

$(OBJ_DIR):
	$(MKDIR_P) $(OBJ_DIR)

clean::
	-rm -R -f $(OBJ_DIR) $(D_TARGET) $(D128_TARGET)

