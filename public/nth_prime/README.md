# Sub-Linear n-th Prime Filter in Fortran 2023 & C23 with Quad Precision & OpenMP Parallelization

An optimized hybrid Fortran 2023 / C23 implementation of the Sub-Linear \(n\)-th Prime Extraction algorithm with IEEE 754 128-bit Quad Precision (`r128`), hardware-accelerated `POPCNT` bitset \(\pi(y)\) indexing, C subroutines for fast recursion, open-addressing hash table memoization, and OpenMP parallelization, targeting `gfortran` / `gcc` 16.1 (and modern GCC releases) on hardware architectures such as AMD Zen 5.

## Building

Build the parallelized `nth-prime` binary using GNU Make:

```bash
make -f GNUmakefile
```

To compile with custom compiler flags or standard specifications:

```bash
CC=gcc CFLAGS="-std=gnu23 -O3 -fopenmp -march=native -ffast-math -funroll-loops" FC=gfortran FCFLAGS="-std=f2023 -O3 -fopenmp -march=native -ffast-math -funroll-loops" make -f GNUmakefile
```

## Usage & Flexible Input Parsing

The executable accepts input via command-line arguments or standard input, supporting standard integers, formatted digit strings, scientific notation, and power expressions:

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

- **C23 / Fortran 2023 Interoperability**: Direct ISO C Binding interface linking Fortran subprogram callers to optimized C23 backend subroutines.
- **Hardware `POPCNT` Bitset $O(1)$ $\pi(y)$ Evaluation**: Memory-efficient bitset with 64-bit word sampling, evaluating $\pi(y)$ for any $y \le x^{2/3}$ in $O(1)$ constant time with zero branch mispredictions using the x86_64 / Zen 5 `POPCNT` instruction.
- **Quad Precision (`r128`) Arithmetic**: 128-bit IEEE floating-point arithmetic for asymptotic logarithmic and exponent calculations, preserving exact integer mantissas for large \(n\).
- **\(O(1)\) Periodic Wheel Base Case (\(\phi(x, 7)\))**: Precomputed lookup table for $P_7 = 510510$ ($\phi(510510, 7) = 92160$), instantly evaluating sub-trees at $a = 7$ without recursive branching.
- **64-Bit Word-Oriented Segmented Sieve**: Bitset-backed segmented sieve with 64-candidate word clearing and hardware `POPCNT` skipping for sub-linear prime extraction.
- **Fast Open-Addressing Hash Table**: $2^{24}$-entry (16,777,216 entries) memoization table for $\phi(x, a)$ evaluations in C with 64-probe linear collision resolution and cache-aligned structs.
- **Adaptive Secant Interval Stepping**: Logarithmic secant step adjustments for candidate search windows around $x_1$, converging to the $n$-th prime boundary in minimum steps.
- **Flexible Numeric Input Parser**: Exact ASCII character-by-character digit parsing, support for scientific floating-point inputs (“1e12”), exponent operators (“10^12”, “10**12”), and digit separators (“1_000_000”).
- **OpenMP Multithreading**: Parallel \(P_2\) summation reduction across multi-core CPUs (e.g. 24-core AMD Zen 5).
- **Icon Procedure Implementation**: Clean, standalone `nth_prime(n)` procedure implemented in `nth_prime.icn` for string input filtering, asymptotic estimation, and prime calculation.
- **Strict Control Flow**: Cyclomatic complexity \(\le 10\) per subprogram, max line length \(\le 72\) characters, and single operation per statement.
