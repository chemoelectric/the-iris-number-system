# Algorithm 284: Interchange of Two Blocks of Data

Author: Frédéric Blondin Custer  
Original Algorithm: B. Boothroyd (*Communications of the ACM*, Vol. 9, No. 5, May 1966)

## Mathematical Description

Algorithm 284 solves the in-place block interchange problem: given a contiguous
array of \( n \) elements partitioned into two adjacent sub-blocks:

\[
X = [\, A_0, A_1, \dots, A_{p-1}, \; B_0, B_1, \dots, B_{q-1} \,]
\]

where \( \text{length}(A) = p \) and \( \text{length}(B) = q \) (with \( n = p + q \)),
rearrange the elements in-place such that block \( B \) precedes block \( A \):

\[
X' = [\, B_0, B_1, \dots, B_{q-1}, \; A_0, A_1, \dots, A_{p-1} \,]
\]

using \( O(n) \) total element moves and \( O(1) \) auxiliary storage.

## Three-Reversal Duality

Algorithm 284 achieves the block interchange via three successive sub-array
reversals:

1. Reverse block \( A \): \( A \to A^R \)
2. Reverse block \( B \): \( B \to B^R \)
3. Reverse the combined array \( A^R B^R \):

\[
(A^R B^R)^R = (B^R)^R (A^R)^R = B A
\]

This eliminates all auxiliary memory buffers and dynamic allocations.

## Implementation Features

- **Header-Only Library**: Direct inclusion via `#include "algorithm_284.h"`.
- **Specialized Fast-Paths**:
  - `alg284_interchange_uintmax`: Direct word-level reversals for `uintmax_t`.
  - `alg284_interchange_ptr`: In-place rotation for pointer (`void *`) arrays.
  - `alg284_interchange`: Generic byte-level block interchange for arbitrary types.
- **Rotation Utilities**: `alg284_rotate_left` and `alg284_rotate_right`.
- **C25 Structured Standard**: Strict compliance with line length \( \le 72 \),
  modified McCabe cyclomatic complexity \( \le 10 \), and single operation per statement.

## Building and Running

```bash
make
./alg284_demo
```
