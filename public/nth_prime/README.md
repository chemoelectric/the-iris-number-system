# Sub-Linear n-th Prime Filter in Fortran 2023 & C23

An optimized hybrid Fortran 2023 / C23 implementation of the
Sub-Linear \(n\)-th Prime Extraction algorithm with IEEE 754
128-bit Quad Precision (`r128`), hardware-accelerated `POPCNT`
bitset \(\pi(y)\) indexing, C subroutines for fast recursion,
open-addressing hash table memoization, and OpenMP parallelization,
targeting `gfortran` / `gcc` 16.1 on hardware architectures
such as AMD Zen 5.

## Building

Build the parallelized `nth-prime` binary using GNU Make:

```bash
make -f GNUmakefile
```

To build the D and C implementations:

```bash
make -f GNUmakefile d
make -f GNUmakefile d64
make -f GNUmakefile c
make -f GNUmakefile c64
```

To compile with custom compiler flags or standard specifications:

```bash
CC=gcc CFLAGS="-std=gnu23 -O3 -fopenmp -march=native" \
FC=gfortran FCFLAGS="-std=f2023 -O3 -fopenmp -march=native" \
make -f GNUmakefile
```

## Usage & Flexible Input Parsing

The executable accepts input via command-line arguments or standard
input, supporting standard integers, formatted digit strings,
scientific notation, and power expressions:

1. **Standard Integer Input**:
   ```bash
   ./nth-prime 256789
   ```

2. **Scientific & Power Notation** (`1e12`, `10^12`, `10**12`):
   ```bash
   ./nth-prime 1e12
   ```
   ```bash
   echo "10^12" | ./nth-prime
   ```

3. **Formatted String Input** (Commas / Underscores):
   ```bash
   ./nth-prime 1_000_000_000
   ```

4. **Multi-Threaded Execution**:
   ```bash
   OMP_NUM_THREADS=24 ./nth-prime 10^12
   ```

## Key Optimization & Architectural Features

- **C23 / Fortran 2023 Interoperability**: Direct ISO C Binding
  interface linking Fortran subprogram callers to optimized C23
  backend subroutines.
- **Hardware `POPCNT` Bitset $O(1)$ $\pi(y)$ Evaluation**:
  Memory-efficient bitset with 64-bit word sampling, evaluating
  $\pi(y)$ for any $y \le x^{2/3}$ in $O(1)$ constant time with
  zero branch mispredictions using x86_64 `POPCNT`.
- **Quad Precision (`r128`) Arithmetic**: 128-bit IEEE floating-point
  arithmetic for asymptotic logarithmic calculations, preserving
  exact integer mantissas for large \(n\).
- **\(O(1)\) Periodic Wheel Base Case (\(\phi(x, 7)\))**: Precomputed
  lookup table for $P_7 = 510510$ ($\phi(510510, 7) = 92160$),
  instantly evaluating sub-trees at $a = 7$ without recursive
  branching.
- **64-Bit Word-Oriented Segmented Sieve**: Bitset-backed segmented
  sieve with 64-candidate word clearing and hardware `POPCNT`
  skipping for sub-linear prime extraction.
- **Fast Open-Addressing Hash Table**: $2^{24}$-entry (16,777,216
  entries) memoization table for $\phi(x, a)$ evaluations in C with
  64-probe linear collision resolution and cache-aligned structs.
- **Adaptive Secant Interval Stepping**: Logarithmic secant step
  adjustments for candidate search windows around $x_1$,
  converging to the $n$-th prime boundary in minimum steps.
- **Flexible Numeric Input Parser**: Exact ASCII character digit
  parsing, support for scientific floating-point inputs (“1e12”),
  exponent operators (“10^12”, “10**12”), and digit separators
  (“1_000_000”).
- **OpenMP Multithreading**: Parallel \(P_2\) summation reduction
  across multi-core CPUs (e.g. 24-core AMD Zen 5).
- **Icon Procedure Implementation**: Clean, standalone `nth_prime(n)`
  procedure implemented in `nth_prime.icn` for string input filtering,
  asymptotic estimation, and prime calculation.
- **D Modules and Demo Programs**: Reusable D modules in
  `src/nth_prime.d` and `src/nth_prime_64.d`. Function
  overloads support `std.bigint.BigInt`, native
  `core.int128.Cent`, and `ulong` values directly without
  ASCII conversions.
  The multi-limb module (`nth_prime.d`) supports compile-time limb count
  parameterization (`-fversion=LIMBS_128`, `-fversion=LIMBS_256`, etc.,
  defaulting to 8192 bits). Each module includes an optionally
  compiled built-in demo program via `-fversion=standalone`.
- **C23 Hardware and Arbitrary-Precision \(n\)-th Prime Engines**:
  Reusable C23 engines and standalone programs in `src/nth_prime.c`
  (`nth-prime-c` target) and `src/nth_prime_64.c`
  (`nth-prime-64-c` target) matching `nth_prime.d` and
  `nth_prime_64.d`. `src/nth_prime_64.c` operates purely on
  standard hardware 64-bit unsigned integers (`uint64_t`).
  `src/nth_prime.c` features compile-time arbitrary fixed-limb
  arithmetic (`LimbNumber`) parameterized via `-DNUM_LIMBS=...` or
  version macros (`-DLIMBS_128`, `-DLIMBS_256`, etc.) and GNU MP
  (`gmp.h`) bignum interface routines. Both engines feature
  typed entry points (`get_nth_prime_u64`, `get_nth_prime_u32`,
  `get_nth_prime_str`), sublinear Lehmer prime counting, segmented
  sieve extraction, and OpenMP multithreading.
- **Strict Control Flow**: Cyclomatic complexity \(\le 10\) per
  subprogram, max line length \(\le 72\) characters, and single
  operation per statement.
