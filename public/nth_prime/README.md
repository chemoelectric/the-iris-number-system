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
   OMP_NUM_THREADS=24 ./nth-prime 10^11
   ```

## Key Optimization & Architectural Features

- **Fortran 2023 Standard**: Standard intrinsic modules (`iso_fortran_env`), strict typing, and lowercase code style.
- **Quad Precision (`r128`) Arithmetic**: 128-bit IEEE floating-point arithmetic for asymptotic logarithmic and exponent calculations, preserving exact integer mantissas for large \(n\).
- **Exact Sieve Upper Bound Allocation**: Initial prime sieve threshold scaled to \(x_0^{2/3}\) (up to 2 billion), guaranteeing that all \(y = x / p_i\) evaluation arguments in the $P_2$ parallel reduction reside strictly within the pre-sieved array bounds, eliminating recursive cache thrashing.
- **Adaptive Secant Interval Stepping**: Logarithmic secant step adjustments for candidate search windows around $x_1$, converging to the $n$-th prime boundary in minimum steps.
- **Open-Addressing Hash Table Memoization**: Full memoization of \(\phi(x, a)\) state evaluations across all \(a\) indices using linear probing and a 2,097,152-entry hash structure.
- **Flexible Numeric Input Parser**: Exact ASCII character-by-character digit parsing, support for scientific floating-point inputs (“1e12”), exponent operators (“10^12”, “10**12”), and digit separators (“1_000_000”).
- **OpenMP Multithreading**: Parallel \(P_2\) summation reduction across multi-core CPUs (e.g. 24-core AMD Zen 5).
- **Fast Base-Case Pruning**: Exact identity \(\phi(x, a) = \pi(x) - a + 1\) whenever \(x < p_a^2\), accelerating recursive sub-tree evaluation.
- **Overflow-Safe Integer Guards**: Division-based boundary testing for power checks to prevent signed `int64` wrapping.
- **Strict Control Flow**: Cyclomatic complexity \(\le 10\) per subprogram and single operation per statement.
