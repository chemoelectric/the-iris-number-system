# Digital Grover Search Engine via Givens Rotations

Author: Frédéric Blondin Custer

This module implements a numerical digital Grover search inference
engine using Givens rotations in Ada 2022.

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
\sin \!\left( \frac{\theta}{2} \right) = \frac{1}{\sqrt{N}}
\]

## Computational Advantages of Givens Rotations

- **Numerical Stability**: Elementary Givens rotations are strictly
  orthogonal and preserve vector norm across arbitrary step counts.
- **Granular Concurrency**: Givens rotations operate on localized
  pairs of coordinates, eliminating global synchronization bottlenecks
  inherent in full Householder reflection steps.
- **Precision \( m \)-Resolution Integration**: Rotations on discrete
  coordinates operate strictly in finite digital arithmetic without
  requiring continuum approximations.

## Building and Running

To compile the Ada 2022 implementation using `gprbuild` or `gnatmake`:

```bash
make
./grover_search_givens
```
