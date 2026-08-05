# Sub-Linear n-th Prime Filter in Fortran 2023 with Quad Precision & OpenMP Parallelization

An optimized implementation of the Sub-Linear \(n\)-th Prime Extraction algorithm in Fortran 2023 with IEEE 754 128-bit Quad Precision (`r128`), recursive \(\pi(y)\) evaluation, open-addressing hash table memoization, and OpenMP parallelization, targeting `gfortran` 16.1 (and modern GCC releases) on hardware architectures such as AMD Zen 5.

## Building

Build the parallelized `nth-prime` binary using GNU Make:

```bash
make -f GNUmakefile
```

To compile with custom compiler flags or standard specifications:

```bash
FC=gfortran FCFLAGS="-std=f2023 -O3 -fopenmp -march=native -ffast-math -funroll-loops" make -f GNUmakefile
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

- **Fortran 2023 Standard**: Standard intrinsic modules (`iso_fortran_env`), strict typing, and lowercase code style.
- **Quad Precision (`r128`) Arithmetic**: 128-bit IEEE floating-point arithmetic for asymptotic logarithmic and exponent calculations, preserving exact integer mantissas for large \(n\).
- **\(O(1)\) Periodic Wheel Base Case (\(\phi(x, 6)\))**: Precomputed lookup table for $P_6 = 30030$ ($\phi(30030, 6) = 5760$), instantly evaluating sub-trees at $a = 6$ without recursive branching.
- **Thread-Safe Binary Search in $P_2$**: High-efficiency logarithmic prime counting for $y = x / p_i$, eliminating cache misses and linear step overheads in the parallel $P_2$ loop.
- **Expanded Open-Addressing Hash Table**: 16,777,216-entry ($2^{24}$) memoization table for $\phi(x, a)$ evaluations with 64-probe linear collision resolution and guaranteed slot assignment, eliminating recursive tree re-evaluations.
- **Odd-Only Bit/Byte Sieve**: Odd-only indexing in Eratosthenes sieve reducing memory footprint by 50% and doubling sieving throughput.
- **Exact Sieve Upper Bound Allocation**: Initial prime sieve threshold scaled to \(x_0^{2/3}\), guaranteeing that all \(y = x / p_i\) evaluation arguments in $P_2$ reside strictly within pre-sieved array bounds.
- **Adaptive Secant Interval Stepping**: Logarithmic secant step adjustments for candidate search windows around $x_1$, converging to the $n$-th prime boundary in minimum steps.
- **Flexible Numeric Input Parser**: Exact ASCII character-by-character digit parsing, support for scientific floating-point inputs (“1e12”), exponent operators (“10^12”, “10**12”), and digit separators (“1_000_000”).
- **OpenMP Multithreading**: Parallel \(P_2\) summation reduction across multi-core CPUs (e.g. 24-core AMD Zen 5).
- **Fast Base-Case Pruning**: Exact identity \(\phi(x, a) = \pi(x) - a + 1\) whenever \(x < p_a^2\), accelerating recursive sub-tree evaluation.
- **Overflow-Safe Integer Guards**: Division-based boundary testing for power checks to prevent signed `int64` wrapping.
- **Strict Control Flow**: Cyclomatic complexity \(\le 10\) per subprogram and single operation per statement.
