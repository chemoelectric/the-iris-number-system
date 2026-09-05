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

## The Fundamental Duality: Part (1) 2D Planar Geometry vs. Part (2) Physical Memory Search

A common source of confusion in discussions of Grover's search algorithm stems from conflating two separate activities:

1. **Part (1): The 2D Givens Rotation Angle Calculator**: Calculating the theoretical rotation angle \( \theta = 2 \arcsin(\sqrt{M/N}) \) and the optimal step count \( k_\text{opt} = \lfloor \frac{\pi}{4}\sqrt{N/M} \rfloor \) within an abstract 2-dimensional planar subspace.
2. **Part (2): The Physical Memory Array Search**: Inspecting actual memory words in computer hardware (cache, RAM, or registers) to locate a target key or an empty sentinel slot (`GIVENS_KEY_UNUSED`).

### Why Bother with Part (1) if Part (2) Does the Search?

When examining physical reality, **Part (1) performs zero search operations on memory cells**. It does not read a single data word from RAM and does not compare any keys. It is purely an abstract mathematical calculation evaluated over two floating-point numbers: space size \( N \) and target multiplicity \( M \).

Why not execute Part (1) directly as an iterative state-vector algorithm to find data in memory? Because software state-vector simulation suffers a catastrophic efficiency penalty:
- Representing an \( N \)-element database as a state vector in computer memory requires allocating \( N \) coordinate amplitudes \( \mathbf{v} = (v_0, v_1, \dots, v_{N-1}) \).
- Each Grover step requires evaluating the oracle (inspecting all \( N \) elements to flip the target sign) and performing the diffusion operator (summing all \( N \) amplitudes to find the mean, then writing back \( 2\bar{v} - v_i \) to every element). This requires \( \mathcal{O}(N) \) memory reads, additions, and writes per step.
- Since Grover search requires \( \mathcal{O}(\sqrt{N}) \) sequential steps, simulating the state vector on digital hardware requires:
  \[
  T_\text{simulation} = \mathcal{O}(\sqrt{N}) \times \mathcal{O}(N) = \mathcal{O}(N\sqrt{N})
  \]
A routine requiring \( \mathcal{O}(N^{1.5}) \) work to search \( N \) items is vastly slower and more wasteful than a simple classical linear scan, which takes \( \mathcal{O}(N) \) operations.

Therefore, on any physical computer, Part (1) serves exclusively as a closed-form mathematical model predicting how an idealized planar state vector would rotate. When the computer actually searches physical memory, Part (2) is executed: and Part (2) is, in unvarnished physical reality, an **unrolled brute-force parallel vector scan**.

---

## Physical Time Analysis: Grover's Algorithm versus Parallel Search

Conventional literature claims Grover's algorithm achieves an \( \mathcal{O}(\sqrt{N}) \) time complexity versus classical \( \mathcal{O}(N) \). This claim is physically defective: it treats the entire database as a zero-dimensional point occupying zero physical space, between which signals travel at infinite speed.

Once physical geometry and the finite speed of electromagnetic influences (\( c \)) are respected, the quadratic speedup disappears:

### 1. Spatial Extent of Physical Data Storage
Physical data storage units cannot occupy zero volume. In physical hardware, each bit or word occupies a finite physical volume \( v_0 > 0 \):
- **In Three Dimensions (3D packaging)**: A volume of \( N \) items scales as \( V \ge N v_0 \), so the physical radius from the controller to the furthest memory element scales as:
  \[
  R_\text{3D} \propto N^{1/3}
  \]
- **On a Two-Dimensional Substrate (2D silicon chip)**: The surface area scales as \( A \ge N a_0 \), so the physical radius scales as:
  \[
  R_\text{2D} \propto N^{1/2}
  \]

### 2. Finite Propagation Delay per Sequential Step
Signals travel at finite velocity \( \le c \). Every step of Grover's algorithm requires global operations (oracle evaluation and global inversion about the mean) requiring round-trip signal propagation across the database:
\[
\tau_\text{step, 3D} \ge \frac{2 R_\text{3D}}{c} \propto \frac{N^{1/3}}{c}, \qquad \tau_\text{step, 2D} \ge \frac{2 R_\text{2D}}{c} \propto \frac{N^{1/2}}{c}
\]

### 3. Total Physical Wall-Clock Execution Time
Because Grover's algorithm is strictly sequential (step \( k+1 \) cannot begin until step \( k \) has diffused across all elements), the total physical elapsed wall-clock time is the product of the step count \( k_\text{opt} \propto N^{1/2} \) and the delay per step \( \tau_\text{step} \):
- **In Three Dimensions (3D)**:
  \[
  T_\text{Grover, 3D} = \mathcal{O}(N^{1/2} \cdot N^{1/3}) = \mathcal{O}(N^{5/6}) \approx \mathcal{O}(N^{0.833})
  \]
- **On a Two-Dimensional Chip (2D)**:
  \[
  T_\text{Grover, 2D} = \mathcal{O}(N^{1/2} \cdot N^{1/2}) = \mathcal{O}(N^1) = \mathcal{O}(N)
  \]
**On a standard planar silicon chip, Grover's algorithm requires \( \mathcal{O}(N) \) physical time—the theoretical speedup is completely eliminated by finite signal propagation delay.**

### 4. Comparison with Classical Parallel Hardware (Content-Addressable Memory)
If the exact same physical space is equipped with classical parallel comparator hardware (CAM or an associative comparator mesh):
1. The target key is broadcast across the spatial grid via an \( H \)-tree: time \( \tau_\text{broadcast} \propto N^{1/3} \) (3D) or \( N^{1/2} \) (2D).
2. All cells compare their local word simultaneously in parallel: time \( \tau_\text{gate} = \mathcal{O}(1) \) (less than 10 picoseconds).
3. The match response returns through a binary priority encoder tree: time \( \tau_\text{encode} \propto \log N \).

The total physical wall-clock time for the classical parallel search is:
\[
T_\text{CAM, 3D} = \mathcal{O}(N^{1/3}), \qquad T_\text{CAM, 2D} = \mathcal{O}(N^{1/2})
\]

Comparing the physical wall-clock times:
- **3D Space**: Classical CAM \( \mathcal{O}(N^{1/3}) \) is strictly faster than Grover \( \mathcal{O}(N^{5/6}) \).
- **2D Chip**: Classical CAM \( \mathcal{O}(N^{1/2}) \) is strictly faster than Grover \( \mathcal{O}(N) \).

In every physical dimension, classical parallel associative hardware is asymptotically faster than Grover's algorithm.

---

## Microarchitectural Loop Execution: Why Only the Innermost Loop Needs Unrolling

When implementing search routines on general-purpose microprocessors (such as scanning cache lines and memory tables), optimizing the loop structure is essential:

### 1. Loop Hierarchy: Outer Control versus Innermost Scan
Search implementations partition memory into hierarchical structures: outer loops manage coarse blocks, partitions, or hash buckets, while the innermost loop executes the fine-grained word-by-word key comparison.

### 2. Why Outer Loop Unrolling is Useless
In an array of \( 1{,}000{,}000 \) words divided into 1,000 blocks of 1,000 words:
- The outer loop runs only 1,000 times. Its loop control instructions account for less than 0.1% of all executed instructions.
- The innermost loop runs up to 1,000,000 times, performing 1,000,000 memory reads and comparisons.
Unrolling the outer loop does not reduce memory bus transactions or ALU comparator cycles; it only bloats code size. Virtually 100% of memory traffic, comparator cycles, and branch instructions reside exclusively inside the innermost loop. Therefore, **only the innermost loop needs unrolling**.

### 3. The Fragility of Compiler Loop Unrolling
Optimizing compilers (such as GCC and Clang) possess automatic loop unrolling heuristics (`-O3`, `-funroll-loops`), but they routinely fail on search loops:
- **Early-Exit Search Failure**: Unlike definite for-loops with a fixed upper bound, search loops must break immediately upon finding a matching key (`if (array[i] == target) break;`). Compilers are notoriously timid when encountering conditional early exits, frequently disabling unrolling entirely or defaulting to a trivial factor of 2.
- **Inability to Unroll Outer Loops**: Compilers cannot safely unroll outer loops with non-constant bounds or potential pointer aliasing.

### 4. Deterministic Source Generation via m4 Macros
By employing the standard `m4` macro processor, the software engineer generates unrolled loop code deterministically at compile time:
- The `m4` macro expands the innermost search loop into an explicit, straight-line sequence of C or assembly statements.
- The unroll factor is precisely matched to the target architecture's cache line width and vector execution pipelines. For modern 64-bit processors with 512-bit vector capabilities (e.g. AMD Zen 5 with dual 512-bit pipelines), each 64-byte cache line holds exactly 8 `uintmax_t` (64-bit) words.
- An 8-way unrolled innermost block generated via `m4` inspects a complete 512-bit vector block in a single straight-line pass with zero loop counter increments, zero loop boundary tests, and zero backward branch mispredictions.
- This allows memory reads to stream at the processor's full memory bandwidth (exceeding 50 to 100+ GB/s), checking keys in sub-nanosecond intervals per item.

---

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

---

## Structured Loop Architecture & Generic Ada 2022 Package for the Iris Typesetter

### 1. Structured Control Flow without Early Exits
In performance-critical vector pipelines, replacing irregular `break` or `exit` control flow with unified single-entry, single-exit loop continuation predicates:
- Eliminates irregular jump edges from the compiler's control-flow graph (CFG).
- Enables predictable software pipelining and clean register allocation across SIMD execution blocks.
- In Ada 2022, structured loops strictly enforce `while ... loop ... end loop;` without early `exit` statements or early returns, guaranteeing modified McCabe cyclomatic complexity \( \le 10 \).

### 2. Generic Parameterized Package (`iris_sentinel_hash`)
For the Iris typesetter, hash lookups are executed natively in Ada 2022 via the generic package `iris_sentinel_hash` (`iris_sentinel_hash.ads` and `iris_sentinel_hash.adb`). The package is completely parameterized for:
- **Keys & Values**: Arbitrary private types `key_type` and `value_type`.
- **Modular Hash Sizes**: Parameterized over `type hash_type is mod <>`, accommodating 16-bit, 32-bit, or 64-bit hash values (`interfaces.unsigned_16`, `interfaces.unsigned_32`, `interfaces.unsigned_64`).
- **Sentinel Slot Design**: Parameterized by `sentinel_key` and `sentinel_value`. An unused slot is identified by `sentinel_key`, allowing open-addressing probe chains to terminate immediately upon encountering a vacant cell without maintaining auxiliary state.
- **Hardware Vector Block Size**: Parameterized by `block_size` (defaulting to 8 words, perfectly matching 512-bit vector registers and 64-byte cache lines on modern hardware like AMD Zen 5).
- **Table Capacity**: Parameterized by `max_table_size`, enabling deterministic, zero-heap static allocation for real-time typographic processing.

### 3. Application in the Iris Typesetter
The typesetter queries tables millions of times during paragraph breaking, hyphenation, and outline rasterization. Instantiations include:
- **Glyph Metrics Table**: Mapping 32-bit character/glyph IDs to metric records (advance width, left-side bearing, bounding box).
- **Kerning Pair Table**: Mapping composite character pairs to discrete metric adjustments.
- **Ligature & Substitution Table**: Resolving multi-glyph ligature groupings into unified typographic glyph indices.
- **Hyphenation & Macro Dictionaries**: High-throughput prefix and pattern lookups streaming at the memory bus bandwidth.

A complete test driver is provided in `test_iris_sentinel_hash.adb`.

## Building and Running

### C25 Implementation

```bash
make
./grover_search_c
```

### Ada 2022 Implementations

```bash
# 2D Givens Grover Search Demo
gnatmake -gnat2022 grover_search_givens.adb
./grover_search_givens

# Parameterized Sentinel Block Hash Table Test for Typesetter
gnatmake -gnat2022 test_iris_sentinel_hash.adb
./test_iris_sentinel_hash
```
