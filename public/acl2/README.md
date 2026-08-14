# ACL2 Book: The Iris Number System

This directory contains the ACL2 formalization of the **Iris Number System**.

## Files
- `iris_number_system.lisp`: Main ACL2 book formalizing the discrete Multiscale Resolution Analysis (MSRA) grid, vernier step sizes, the Main Scale Projection operator $(\downarrow)$, derivative operators, and $Cl(2,0)$ multivector bivector rotor operations.

## Usage Guide

To use this book with ACL2:

1. **Start ACL2**:
   ```bash
   acl2
   ```

2. **Certify the Book**:
   In the ACL2 read-eval-print loop (REPL), run:
   ```lisp
   (certify-book "iris_number_system" 0 t)
   ```

3. **Include the Book in Other Files**:
   ```lisp
   (include-book "public/acl2/iris_number_system")
   ```

4. **Interactive Execution & Verification**:
   - Evaluate vernier grid coordinates:
     ```lisp
     (iris-vernier-value 5 100) ; Returns 1/20
     ```
   - Test $Cl(2,0)$ bivector rotor addition and geometric product:
     ```lisp
     (cl2-add '(1 0 0 2) '(3 1 0 0)) ; Returns (4 1 0 2)
     (cl2-mul '(0 1 0 0) '(0 1 0 0)) ; Returns (1 0 0 0), e1^2 = 1
     ```
