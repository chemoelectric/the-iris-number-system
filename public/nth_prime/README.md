# Sub-Linear n-th Prime Filter in Fortran 2023

An implementation of the Sub-Linear $n$-th Prime Extraction algorithm in Fortran 2023 targeting `gfortran` 16.1 (and modern GCC releases) on hardware architectures such as AMD Zen 5.

## Building

Build the `nth-prime` binary using GNU Make:

```bash
make -f GNUmakefile
```

To compile with custom compiler flags or standard specifications:

```bash
FC=gfortran FCFLAGS="-std=f2023 -O3 -march=native" make -f GNUmakefile
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

## Design Highlights

- **Fortran 2023 Standard**: Utilizes modern Fortran features, standard intrinsic modules (`iso_fortran_env`), and strict typing.
- **Strict Control Flow**: Adheres strictly to structured control flow with single operations per line, subprogram contracts, and low cyclomatic complexity (under 10 per procedure and main program).
- **Sub-Linear Algorithm**: Employs initial 5-term asymptotic estimation, Lehmer prime counting, and targeted local segmented sieving.
