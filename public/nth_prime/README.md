# Sub-Linear n-th Prime Filter in Fortran 2023 with OpenMP Parallelization

An optimized implementation of the Sub-Linear $n$-th Prime Extraction algorithm in Fortran 2023 with OpenMP parallelization, targeting `gfortran` 16.1 (and modern GCC releases) on hardware architectures such as AMD Zen 5.

## Building

Build the parallelized `nth-prime` binary using GNU Make:

```bash
make -f GNUmakefile
```

To compile with custom compiler flags or standard specifications:

```bash
FC=gfortran FCFLAGS="-std=f2023 -O3 -fopenmp -march=native -ffast-math -funroll-loops" make -f GNUmakefile
```

## Usage

The executable acts as a standard Unix filter:

1. **Command Line Argument**:
   ```bash
   ./nth-prime 256789
   ```
   Output:
   ```
   3600847
   ```

2. **Standard Input**:
   ```bash
   echo 256789 | ./nth-prime
   ```
   Output:
   ```
   3600847
   ```

3. **Multi-Threaded Execution**:
   ```bash
   OMP_NUM_THREADS=24 ./nth-prime 1000000000
   ```

## Key Optimization Features

- **Fortran 2023 Standard**: Standard intrinsic modules (`iso_fortran_env`), strict typing, and lowercase code style.
- **OpenMP Multithreading**: Parallel $P_2$ summation reduction across multi-core CPUs (e.g. 24-core AMD Zen 5).
- **Fast Base-Case Pruning**: Exact identity $\phi(x, a) = \pi(x) - a + 1$ whenever $x < p_a^2$, accelerating recursive sub-tree evaluation.
- **Compiler Flags**: `-O3 -fopenmp -march=native -ffast-math -funroll-loops` for auto-vectorization and OpenMP execution.
- **Strict Control Flow**: Cyclomatic complexity $\le 10$ per subprogram and single operation per statement.
