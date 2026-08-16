# Sub-Linear n-th Prime Filter in Fortran 2023 & C23

An optimized hybrid Fortran 2023 / C23 implementation of the
Sub-Linear \(n\)-th Prime Extraction algorithm with IEEE 754
128-bit Quad Precision (`r128`), hardware-accelerated `POPCNT`
bitset \(\pi(y)\) indexing, C subroutines for fast recursion,
open-addressing hash table memoization, and OpenMP parallelization,
targeting `gfortran` / `gcc` 16.1 on hardware architectures
such as AMD Zen 5.

## Building

Build the parallelized 64-bit binaries using GNU Make:

```bash
make -f GNUmakefile
```

To build individual Fortran 2023, D, and C23 64-bit implementations:

```bash
make -f GNUmakefile f64
make -f GNUmakefile d64
make -f GNUmakefile c64
```

To compile with custom compiler flags or standard specifications:

```bash
CC=gcc CFLAGS="-std=gnu23 -O3 -fopenmp -march=native" \
FC=gfortran FCFLAGS="-std=f2023 -O3 -fopenmp -march=native" \
DC=gdc DFLAGS="-O3 -march=native" \
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
- **Fortran 2023 Hardware 64-Bit \(n\)-th Prime Engine**:
  Standalone Fortran 2023 engine in `src/nth_prime_64.f90`
  (`nth-prime-64-f` target) using native IEEE 754 128-bit Quad
  Precision (`real128`), hardware bitwise intrinsics (`popcnt`,
  `iand`, `ishft`, `ieor`), recursive memoized Buchstab decomposition,
  and bit-packed 64-bit word segmented window extraction.
- **D 64-Bit Engine and Demo Program**: Reusable D module in
  `src/nth_prime_64.d` (`nth-prime-64-d` target). Function
  overloads support `std.bigint.BigInt`, native
  `core.int128.Cent`, and `ulong` values directly without
  ASCII conversions. Includes an optionally compiled built-in
  demo program via `-fversion=standalone`.
- **C23 Hardware 64-Bit \(n\)-th Prime Engine**:
  Reusable C23 engine and standalone program in `src/nth_prime_64.c`
  (`nth-prime-64-c` target) operating purely on standard hardware
  64-bit unsigned integers (`uint64_t`). Features typed entry points
  (`get_nth_prime_u64`, `get_nth_prime_u32`, `get_nth_prime_str`),
  sublinear Lehmer prime counting, bit-packed segmented sieve
  extraction, and OpenMP multithreading.
- **Modula-2 ISO Hardware 64-Bit \(n\)-th Prime Engine**:
  High-performance ISO Modula-2 engine (`NthPrime64.def`,
  `NthPrime64.mod`, `MainM2.mod` targeting `gm2` in GCC 16.1 via
  `nth-prime-64-m2`). Implements full sublinear Lehmer prime counting,
  $O(1)$ primorial wheel ($P_6 = 30030$) periodic acceleration,
  dynamic heap allocation (`Storage.ALLOCATE`), bit-packed word sieving,
  hardware popcount emulation/intrinsics, and memoized Buchstab
  recursion.
- **Modular SIMD Buchstab Tree Decomposition & OEIS Anchors**:
  Modular Buchstab recursion trees ($\phi(x, a)$) with $O(1)$ wheel
  base cases, divisionless modular reduction, and prior OEIS anchor
  tables ($n \le 10^9$) providing instant $x_0$ initial candidate
  coordinates to accelerate Newton-Vernier interval convergence.
- **Gilbreath Invariant Multi-Grid Local Segment Sieving**:
  Multi-grid local segment sieving validating stream alignment
  across channels using Gilbreath prime difference invariants
  ($d_1^{(k)} = 1$).
- **Strict Control Flow & Standard Compliance**:
  Cyclomatic complexity \(\le 10\) per subprogram (and main program),
  max line length \(\le 72\) characters, single operation per statement,
  and zero ++/-- increment operators across C23 and D modules.
