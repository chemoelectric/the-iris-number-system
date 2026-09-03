# Digital Grover Search Engine via Givens Rotations

Author: Frédéric Blondin Custer

This module implements a numerical digital Grover search inference
engine using Givens rotations in both Ada 2022 and modern C25 (ISO C23/C25).

## Overview

In traditional descriptions, Grover’s search algorithm is formulated as
a sequence of global Householder reflections:

1. Oracle Phase Inversion: \( U_w = I - 2 |w\rangle \langle w| \)
2. Uniform State Diffusion: \( U_s = 2 |s\rangle \langle s| - I \)

In a discrete \( N \)-dimensional space, state vector evolution is
constrained to a two-dimensional invariant subspace spanned by the
marked target state vector \( |w\rangle \) and the orthogonal state
vector \( |s'\rangle \).

By geometric equivalence, the combined Grover search operator
\( G = U_s \cdot U_w \) acts on this invariant subspace as a
two-dimensional Givens rotation matrix:

\[
R(\theta) =
\begin{pmatrix}
\cos \theta & -\sin \theta \\
\sin \theta & \cos \theta
\end{pmatrix}
\]

where the discrete rotation step angle \( \theta \) satisfies:

\[
\sin \!\left( \frac{\theta}{2} \right) = \sqrt{\frac{M}{N}}
\]

When searching for a unique item (\( M = 1 \)),
\( \theta = 2 \arcsin(1/\sqrt{N}) \).
When searching for highly non-unique items (\( M \gg 1 \), such as empty
unused slots in an associative table), the rotation step angle scales as
\( \theta \approx 2\sqrt{M/N} \), drastically reducing the required steps
to \( k \approx \frac{\pi}{4}\sqrt{N/M} \).

## C25 Implementation & Thread-Free Zen 5 Vector Acceleration

The C implementation provides:

1. **Unique & Multi-Target Givens Dynamics**: Direct 2D subspace rotation
   with optimal step count calculation for single items (\( M=1 \)) and
   multi-target distributions (\( M > 1 \)).
2. **Vector-Parallel Unique `uintmax_t` Scanning**: Operates across
   512-bit vector blocks (8 `uintmax_t` words per vector block) to utilize
   Zen 5 dual 512-bit vector execution pipelines without operating system
   threads.
3. **Associative Table with Sentinel Slot Recycling (`GIVENS_KEY_UNUSED`)**:
   High-performance associative table storing unique `uintmax_t` keys (e.g.
   holding `uintptr_t` pointers or integer hashes). Empty slots are marked with
   a reserved sentinel key value (`GIVENS_KEY_UNUSED = UINTMAX_MAX`).
   - Deletions simply rewrite the key word to `GIVENS_KEY_UNUSED` in \( O(1) \)
     time without heap rearrangement.
   - Insertions execute a high-multiplicity vector search for `GIVENS_KEY_UNUSED`
     to immediately reoccupy vacant slots.
   - Eliminates auxiliary free stacks, pointers, and memory fragmentation.
4. **Thread-Safe FFI Ready**: Being strictly thread-free and reentrant,
   it is immediately linkable into non-thread-safe runtime environments
   such as CHICKEN 6 Scheme (`foreign-lambda`), Python (`ctypes`/CFFI),
   Ada 2022 (`Interfaces.C`), and Fortran (`iso_c_binding`).

## CHICKEN 6 Scheme FFI Integration Example

```scheme
;; Example CHICKEN Scheme foreign binding
(import (chicken foreign))

(foreign-declare "#include \"givens_grover.h\"")

(define givens-angle-compute
  (foreign-lambda double "givens_angle_compute" unsigned-integer))

(define givens-angle-multi-compute
  (foreign-lambda double "givens_angle_multi_compute"
                  unsigned-integer unsigned-integer))

(define givens-optimal-steps
  (foreign-lambda unsigned-integer "givens_optimal_steps" unsigned-integer))
```

## Ada 2022 Interface Binding Example

```ada
pragma ada_2022;
with interfaces.c; use interfaces.c;

package givens_grover_c_binding is
   function givens_angle_compute (space_size : size_t) return double
     with import, convention => c, external_name => "givens_angle_compute";

   function givens_angle_multi_compute
     (space_size : size_t; mult : size_t) return double
     with import, convention => c,
          external_name => "givens_angle_multi_compute";
end givens_grover_c_binding;
```

## Building and Running

### C25 Implementation

```bash
make
./grover_search_c
```

### Ada 2022 Implementation

```bash
gnatmake -gnat2022 grover_search_givens.adb
./grover_search_givens
```
