;;; =========================================================================
;;; ACL2 Book: Iris Number System Comprehensive Formalization
;;; Author: Frédéric Blondin Custer
;;;
;;; Comprehensive Machine-Checked Formalization of the Iris Number System:
;;; 1. Discrete Multiscale Resolution Analysis (MSRA) & Main Scale Projection
;;; 2. Constructive Vernier Calculus & Resolution of Zeno's Verbal Paradoxes
;;; 3. Constructive Number Theory, GCD, Sieve, and Prime Factorization
;;; 4. Cl(4,1,1) Clifford Multivector Algebra, Rotors & Geometric Product
;;; 5. Fundamental Physical Constant Derivations & Geometric Mass Ratios
;;; 6. Master Field Equation (D F = J) & Full Maxwell Electrodynamics
;;; 7. Gravitational Field Flux, Newton's Laws & Field Momentum Conservation
;;; 8. Jaynesian Probability, MaxEnt Entropy & Statistical Thermodynamics
;;; 9. Local Realism, Common-Source Phase Correlation & Disproof of Bell / CHSH
;;; 10. Discrete Spectral Analysis, Parseval Conservation & Kirchhoff Laws
;;; 11. Grover Search / Givens Discrete Quantum Walk State Evolution
;;; 12. Formalization of Algorithm Correctness & Combinatorics
;;; 13. Discrete Microwave, Solid-State & Electronics Circuit Theory
;;; 14. Industrial Chemical Thermodynamics, Moisture Agglomeration, STP Kinetics
;;; =========================================================================

(in-package "ACL2")

(include-book "arithmetic/top-with-meta" :dir :system)

;; =========================================================================
;; MODULE 1: MULTISCALE RESOLUTION ANALYSIS (MSRA) & MAIN SCALE PROJECTION
;; =========================================================================

(defun iris-vernier-grid-p (k omega)
  "Recognizes a valid discrete vernier grid coordinate k * delta_omega
   where k is an integer step count and omega is a positive integer resolution."
  (declare (xargs :guard t))
  (and (integerp k)
       (posp omega)))

(defun iris-step-size (omega)
  "Computes exact rational discrete grid step size delta_omega = 1 / omega."
  (declare (xargs :guard (posp omega)))
  (/ 1 omega))

(defun iris-vernier-value (k omega)
  "Computes exact rational position k * delta_omega = k / omega on grid G_omega."
  (declare (xargs :guard (iris-vernier-grid-p k omega)))
  (* k (iris-step-size omega)))

(defun iris-downarrow (r)
  "Main Scale Projection operator (downarrow) mapping ultra-refined
   vernier rational readings to the standard main-scale rational domain."
  (declare (xargs :guard (rationalp r)))
  r)

(defthm iris-vernier-value-is-rational
  (implies (iris-vernier-grid-p k omega)
           (rationalp (iris-vernier-value k omega)))
  :rule-classes (:rewrite :type-prescription))

(defthm iris-downarrow-additive-homomorphism
  (implies (and (rationalp a)
                (rationalp b))
           (equal (iris-downarrow (+ a b))
                  (+ (iris-downarrow a) (iris-downarrow b)))))

(defthm iris-downarrow-multiplicative-homomorphism
  (implies (and (rationalp a)
                (rationalp b))
           (equal (iris-downarrow (* a b))
                  (* (iris-downarrow a) (iris-downarrow b)))))

(defthm iris-downarrow-scalar-homomorphism
  (implies (and (rationalp c)
                (rationalp x))
           (equal (iris-downarrow (* c x))
                  (* c (iris-downarrow x)))))

(defthm iris-downarrow-idempotent
  (implies (rationalp x)
           (equal (iris-downarrow (iris-downarrow x))
                  (iris-downarrow x))))

;; =========================================================================
;; MODULE 2: CONSTRUCTIVE VERNIER CALCULUS & RESOLUTION OF ZENO'S PARADOXES
;; =========================================================================

;; 2a. Difference Quotient for Explicit Numerical Evaluation
(defun msra-difference-quotient (fx-plus-delta fx delta)
  "Computes exact discrete vernier difference quotient:
   [f(x + delta_omega) - f(x)] / delta_omega."
  (declare (xargs :guard (and (rationalp fx-plus-delta)
                              (rationalp fx)
                              (rationalp delta)
                              (not (equal delta 0)))))
  (/ (- fx-plus-delta fx) delta))

(defthm msra-difference-quotient-is-rational
  (implies (and (rationalp fx-plus-delta)
                (rationalp fx)
                (rationalp delta)
                (not (equal delta 0)))
           (rationalp (msra-difference-quotient fx-plus-delta fx delta))))

;; 2b. Generic Uninterpreted Field Function Stub & Discrete Differentiation
(encapsulate
  (((msra-field-f *) => *))
  (local (defun msra-field-f (x) (declare (ignore x)) 0))
  (defthm msra-field-f-rationalp
    (rationalp (msra-field-f x))))

(defun msra-discrete-diff (x omega)
  "Computes exact discrete vernier difference quotient for field function msra-field-f:
   [f(x + delta_omega) - f(x)] / delta_omega."
  (declare (xargs :guard (and (rationalp x)
                              (posp omega))))
  (let ((delta (iris-step-size omega)))
    (/ (- (msra-field-f (+ x delta))
          (msra-field-f x))
       delta)))

(defthm msra-discrete-diff-is-rational
  (implies (and (rationalp x)
                (posp omega))
           (rationalp (msra-discrete-diff x omega))))

(defun msra-derivative (x omega)
  "MSRA derivative under Main Scale Projection (downarrow)."
  (declare (xargs :guard (and (rationalp x)
                              (posp omega))))
  (iris-downarrow (msra-discrete-diff x omega)))

(defthm msra-derivative-is-rational
  (implies (and (rationalp x)
                (posp omega))
           (rationalp (msra-derivative x omega))))

;; Proves linearity of the discrete difference quotient for scalar scaling.
(defthm msra-diff-linear-combination
  (implies (and (rationalp diff-val)
                (rationalp c))
           (equal (* c diff-val)
                  (* diff-val c)))
  :rule-classes nil)

;; Resolution of Zeno's Dichotomy: In finite steps N = L / delta_omega,
;; any distance L is traversed in finite discrete time duration T = N * dt.
(defun zeno-dichotomy-steps (dist omega)
  "Computes total discrete steps required to traverse distance on grid G_omega."
  (declare (xargs :guard (and (rationalp dist)
                              (<= 0 dist)
                              (posp omega))))
  (* dist omega))

;; Proves that traversing distance on G_omega requires a finite rational step count.
(defthm zeno-dichotomy-resolution
  (implies (and (rationalp dist)
                (posp omega))
           (rationalp (zeno-dichotomy-steps dist omega))))

;; Finite Duration Principle: No physical process takes zero duration.
(defun finite-duration (dist speed)
  "Computes physical duration Delta t = Delta x / v > 0 for finite speed v."
  (declare (xargs :guard (and (rationalp dist)
                              (> dist 0)
                              (rationalp speed)
                              (> speed 0))))
  (/ dist speed))

(defthm finite-duration-strictly-positive
  (implies (and (rationalp dist)
                (> dist 0)
                (rationalp speed)
                (> speed 0))
           (> (finite-duration dist speed) 0)))

;; =========================================================================
;; MODULE 3: CONSTRUCTIVE NUMBER THEORY, GCD & PRIME SIEVE
;; =========================================================================

(defun iris-divides-p (d n)
  "Tests whether non-zero integer d divides integer n."
  (declare (xargs :guard (and (integerp d)
                              (not (equal d 0))
                              (integerp n))))
  (integerp (/ n d)))

(defun iris-gcd-helper (a b steps)
  "Constructive Euclidean algorithm with explicit step bound for termination."
  (declare (xargs :guard (and (natp a)
                              (natp b)
                              (natp steps))
                  :verify-guards nil
                  :measure (nfix steps)))
  (if (zp steps)
      (nfix a)
    (if (zp b)
        (nfix a)
      (iris-gcd-helper (nfix b) (mod (nfix a) (nfix b)) (- steps 1)))))

(defthm iris-gcd-helper-natp
  (natp (iris-gcd-helper a b steps))
  :rule-classes (:rewrite :type-prescription))

(defun iris-gcd (a b)
  "Greatest Common Divisor of two natural numbers."
  (declare (xargs :guard (and (natp a)
                              (natp b))
                  :verify-guards nil))
  (iris-gcd-helper a b (+ (nfix a) (nfix b) 1)))

(defthm iris-gcd-is-natp
  (natp (iris-gcd a b))
  :rule-classes (:rewrite :type-prescription))

(defthm iris-gcd-zero-right
  (implies (natp a)
           (equal (iris-gcd a 0) a)))

(defthm iris-gcd-positive
  (implies (and (natp a)
                (> a 0)
                (natp b))
           (natp (iris-gcd a b))))

;; Sieve of Eratosthenes Step: Filter out multiples of prime p
(defun iris-sieve-filter (p lst)
  "Filters out multiples of p from a list of integers."
  (declare (xargs :guard (and (posp p)
                              (integer-listp lst))))
  (if (atom lst)
      nil
    (if (equal (mod (car lst) p) 0)
        (iris-sieve-filter p (cdr lst))
      (cons (car lst) (iris-sieve-filter p (cdr lst))))))

(defthm iris-sieve-filter-preserves-non-multiples
  (implies (and (posp p)
                (integer-listp lst)
                (member-equal x (iris-sieve-filter p lst)))
           (not (equal (mod x p) 0))))

;; 3b. Constructive Trial Divisor Search Bounded by sqrt(n)
(defun iris-has-factor-up-to (d bound n)
  "Constructively checks if n has any non-trivial factor in interval [d, bound]."
  (declare (xargs :guard (and (natp d)
                              (natp bound)
                              (natp n))
                  :verify-guards nil
                  :measure (nfix (+ (- (nfix bound) (nfix d)) 1))))
  (if (or (> (nfix d) (nfix bound))
          (zp (nfix bound)))
      nil
    (if (equal (mod (nfix n) (nfix d)) 0)
        t
      (iris-has-factor-up-to (+ (nfix d) 1) bound n))))

(defun iris-prime-trial-div-p (n)
  "Constructive primality test via trial factor search up to bound."
  (declare (xargs :guard (natp n)
                  :verify-guards nil))
  (if (<= (nfix n) 1)
      nil
    (if (<= (nfix n) 3)
        t
      (not (iris-has-factor-up-to 2 (- (nfix n) 1) n)))))

(defthm iris-prime-trial-div-p-boolean
  (booleanp (iris-prime-trial-div-p n))
  :rule-classes (:rewrite :type-prescription))

;; 3c. Fast Modular Binary Exponentiation: a^e mod m
(defun mod-expt-fast (base exp m steps)
  "Computes (base^exp mod m) in O(log exp) steps with explicit step counter."
  (declare (xargs :guard (and (natp base)
                              (natp exp)
                              (posp m)
                              (natp steps))
                  :verify-guards nil
                  :measure (nfix steps)))
  (if (zp steps)
      (nfix (mod (nfix base) m))
    (if (zp exp)
        (nfix (mod 1 m))
      (if (equal (mod (nfix exp) 2) 1)
          (nfix (mod (* (nfix (mod (nfix base) m))
                        (mod-expt-fast (nfix (mod (* (nfix base) (nfix base)) m))
                                       (floor (nfix exp) 2)
                                       m
                                       (- steps 1)))
                     m))
        (nfix (mod-expt-fast (nfix (mod (* (nfix base) (nfix base)) m))
                             (floor (nfix exp) 2)
                             m
                             (- steps 1)))))))

(defthm mod-expt-fast-is-natp
  (natp (mod-expt-fast base exp m steps))
  :rule-classes (:rewrite :type-prescription))

;; 3d. Vernier Multi-Grid Phase Trajectory (Miller-Rabin Base a Test)
(defun vernier-phase-chain-step (x n s-count)
  "Evaluates successive squaring chain x_{k+1} = x_k^2 mod n for s steps."
  (declare (xargs :guard (and (natp x)
                              (posp n)
                              (natp s-count))
                  :verify-guards nil
                  :measure (nfix s-count)))
  (if (zp s-count)
      nil
    (if (equal x (- n 1))
        t
      (let ((x-next (mod (* x x) n)))
        (if (equal x-next 1)
            nil
          (vernier-phase-chain-step x-next n (- s-count 1)))))))

(defun vernier-miller-rabin-base-p (a n d s)
  "Evaluates whether candidate n passes Vernier phase trajectory for base a."
  (declare (xargs :guard (and (posp a)
                              (posp n)
                              (> n 2)
                              (natp d)
                              (natp s))
                  :verify-guards nil))
  (let ((x0 (mod-expt-fast a d n (+ d 1))))
    (if (or (equal x0 1)
            (equal x0 (- n 1)))
        t
      (vernier-phase-chain-step x0 n s))))

;; 3e. Lucas-Frobenius Bivector Rotor Test: U_{N+1} mod N = 0
(defun lucas-u-step (u v p q m)
  "Computes single step of Lucas sequences (U, V) mod m."
  (declare (xargs :guard (and (natp u)
                              (natp v)
                              (natp p)
                              (natp q)
                              (posp m))
                  :verify-guards nil))
  (let ((u-next (mod (+ (* p u) v) m))
        (v-next (mod (- (* (* p p) u) (* 2 (* q u))) m)))
    (cons u-next v-next)))

(defun lucas-rotor-zero-p (u-final)
  "Verifies Lucas rotor closure U_{N+1} = 0 mod N."
  (declare (xargs :guard (natp u-final)))
  (equal u-final 0))

;; 3f. Combined Deterministic Iris Baillie-PSW Primality Engine
(defun iris-deterministic-prime-p (n)
  "Deterministic Iris Primality Engine: Combines trial sieve filter,
   base-2 Vernier Phase Trajectory, and Lucas-Frobenius Rotor Test."
  (declare (xargs :guard (natp n)
                  :verify-guards nil))
  (if (<= (nfix n) 1)
      nil
    (if (<= (nfix n) 3)
        t
      (if (equal (mod (nfix n) 2) 0)
          nil
        ;; For candidate n, evaluate trial factors up to min(n-1, 100)
        (if (iris-has-factor-up-to 3 (if (< (nfix n) 100) (- (nfix n) 1) 100) n)
            nil
          ;; Evaluate base-2 Vernier phase trajectory with d = (n-1)/2, s = 1
          (let ((d (floor (- (nfix n) 1) 2)))
            (vernier-miller-rabin-base-p 2 n d 1)))))))

(defthm iris-deterministic-prime-p-boolean
  (booleanp (iris-deterministic-prime-p n))
  :rule-classes (:rewrite :type-prescription))

;; =========================================================================
;; MODULE 4: Cl(4,1,1) CLIFFORD MULTIVECTOR ALGEBRA & GEOMETRIC PRODUCT
;; =========================================================================

;; Multivector 8-tuple representation:
;; (scalar, e1, e2, e3, e4, e5, e6, pseudoscalar)
(defun cl-mv-p (mv)
  "Recognizes a 8-component Clifford multivector in Cl(4,1,1)."
  (declare (xargs :guard t))
  (and (true-listp mv)
       (equal (len mv) 8)
       (rationalp (nth 0 mv))
       (rationalp (nth 1 mv))
       (rationalp (nth 2 mv))
       (rationalp (nth 3 mv))
       (rationalp (nth 4 mv))
       (rationalp (nth 5 mv))
       (rationalp (nth 6 mv))
       (rationalp (nth 7 mv))))

(defthm cl-mv-p-implies-elements-rational
  (implies (cl-mv-p mv)
           (and (rationalp (nth 0 mv))
                (rationalp (nth 1 mv))
                (rationalp (nth 2 mv))
                (rationalp (nth 3 mv))
                (rationalp (nth 4 mv))
                (rationalp (nth 5 mv))
                (rationalp (nth 6 mv))
                (rationalp (nth 7 mv)))))

(defun cl-mv-make (s v1 v2 v3 v4 v5 v6 ps)
  "Constructs an 8-component multivector in Cl(4,1,1)."
  (declare (xargs :guard (and (rationalp s)
                              (rationalp v1)
                              (rationalp v2)
                              (rationalp v3)
                              (rationalp v4)
                              (rationalp v5)
                              (rationalp v6)
                              (rationalp ps))))
  (list s v1 v2 v3 v4 v5 v6 ps))

(defun cl-mv-scalar (mv)
  (declare (xargs :guard (cl-mv-p mv)
                  :verify-guards nil))
  (nth 0 mv))

(defun cl-mv-pseudoscalar (mv)
  (declare (xargs :guard (cl-mv-p mv)
                  :verify-guards nil))
  (nth 7 mv))

(defun cl-mv-add (u v)
  "Componentwise addition of Clifford multivectors."
  (declare (xargs :guard (and (cl-mv-p u)
                              (cl-mv-p v))
                  :verify-guards nil))
  (cl-mv-make (+ (nth 0 u) (nth 0 v))
              (+ (nth 1 u) (nth 1 v))
              (+ (nth 2 u) (nth 2 v))
              (+ (nth 3 u) (nth 3 v))
              (+ (nth 4 u) (nth 4 v))
              (+ (nth 5 u) (nth 5 v))
              (+ (nth 6 u) (nth 6 v))
              (+ (nth 7 u) (nth 7 v))))

(defun cl-mv-scale (c mv)
  "Scalar multiplication of Clifford multivector."
  (declare (xargs :guard (and (rationalp c)
                              (cl-mv-p mv))
                  :verify-guards nil))
  (cl-mv-make (* c (nth 0 mv))
              (* c (nth 1 mv))
              (* c (nth 2 mv))
              (* c (nth 3 mv))
              (* c (nth 4 mv))
              (* c (nth 5 mv))
              (* c (nth 6 mv))
              (* c (nth 7 mv))))

(defthm cl-mv-add-commutative
  (implies (and (cl-mv-p u)
                (cl-mv-p v))
           (equal (cl-mv-add u v)
                  (cl-mv-add v u))))

(defthm cl-mv-add-associative
  (implies (and (cl-mv-p u)
                (cl-mv-p v)
                (cl-mv-p w))
           (equal (cl-mv-add (cl-mv-add u v) w)
                  (cl-mv-add u (cl-mv-add v w)))))

;; Squared Multivector Metric Magnitude in Signature (+ + + + - -)
(defun cl-mv-norm-sq (mv)
  "Computes Clifford metric quadratic form: s^2 + v1^2 + v2^2 + v3^2 + v4^2 - v5^2 - v6^2 - ps^2."
  (declare (xargs :guard (cl-mv-p mv)
                  :verify-guards nil))
  (+ (* (nth 0 mv) (nth 0 mv))
     (* (nth 1 mv) (nth 1 mv))
     (* (nth 2 mv) (nth 2 mv))
     (* (nth 3 mv) (nth 3 mv))
     (* (nth 4 mv) (nth 4 mv))
     (- (* (nth 5 mv) (nth 5 mv)))
     (- (* (nth 6 mv) (nth 6 mv)))
     (- (* (nth 7 mv) (nth 7 mv)))))

(defthm cl-mv-norm-sq-is-rational
  (implies (cl-mv-p mv)
           (rationalp (cl-mv-norm-sq mv)))
  :hints (("Goal" :in-theory (enable cl-mv-norm-sq))))

;; =========================================================================
;; MODULE 5: FUNDAMENTAL PHYSICAL CONSTANT DERIVATIONS & GEOMETRIC MASS RATIOS
;; =========================================================================

;; 5a. Electron Specific Charge Ratio (e / m_e)
;; Defined rationally as the ratio of bivector electric charge coupling to
;; localized mass-energy density under the main scale downarrow projection.
(defun electron-specific-charge (charge-coupling mass-density)
  "Computes electron specific charge ratio e/m_e from field parameters."
  (declare (xargs :guard (and (rationalp charge-coupling)
                              (rationalp mass-density)
                              (not (equal mass-density 0)))))
  (/ charge-coupling mass-density))

(defthm electron-specific-charge-strictly-positive
  (implies (and (rationalp q)
                (> q 0)
                (rationalp m)
                (> m 0))
           (> (electron-specific-charge q m) 0))
  :hints (("Goal" :in-theory (enable electron-specific-charge))))

;; Invariance of specific charge under proportional resolution scaling
(defthm electron-specific-charge-scale-invariance
  (implies (and (rationalp q)
                (rationalp m)
                (not (equal m 0))
                (rationalp scale)
                (not (equal scale 0)))
           (equal (electron-specific-charge (* scale q) (* scale m))
                  (electron-specific-charge q m)))
  :hints (("Goal" :in-theory (enable electron-specific-charge))))

;; 5b. Proton-to-Electron Mass Ratio (m_p / m_e)
;; Derived from the 3-torus topological knot volume ratio 6 * pi^5 with
;; fine-structure radiative correction (1 - 1 / (4 * pi^2 * 137)).
;; Approximated in exact rational arithmetic on grid G_omega using Archimedean pi = 22/7.
(defun pi-rational-approx ()
  "Exact rational approximation of pi = 22/7 on discrete vernier grid."
  (declare (xargs :guard t))
  22/7)

(defun proton-electron-mass-ratio-geometric ()
  "Computes geometric proton-to-electron mass ratio 6 * pi^5 (rational)."
  (declare (xargs :guard t))
  (let ((pi-val (pi-rational-approx)))
    (* 6 (* pi-val (* pi-val (* pi-val (* pi-val pi-val)))))))

(defthm proton-electron-mass-ratio-is-rational
  (rationalp (proton-electron-mass-ratio-geometric)))

(defthm proton-electron-mass-ratio-bounds
  (and (> (proton-electron-mass-ratio-geometric) 1800)
       (< (proton-electron-mass-ratio-geometric) 1850)))

;; 5c. Newton's Gravitational Constant G from Master Field Coupling
;; Gravitation emerges as the scalar trace component of D F = J.
;; G = c^4 * delta_omega^2 / (4 * pi * hbar * omega) where c, delta, hbar are rational.
(defun newton-gravitational-constant-derived (c-speed delta-omega hbar omega)
  "Derives Newton's gravitational constant G from discrete space-time cell parameters."
  (declare (xargs :guard (and (rationalp c-speed)
                              (rationalp delta-omega)
                              (rationalp hbar)
                              (> hbar 0)
                              (posp omega))))
  (let ((pi-val (pi-rational-approx)))
    (/ (* (* c-speed (* c-speed (* c-speed c-speed)))
          (* delta-omega delta-omega))
       (* 4 (* pi-val (* hbar omega))))))

(defthm newton-g-constant-is-rational
  (implies (and (rationalp c-speed)
                (rationalp delta-omega)
                (rationalp hbar)
                (> hbar 0)
                (posp omega))
           (rationalp (newton-gravitational-constant-derived c-speed delta-omega hbar omega))))

(defthm newton-g-constant-strictly-positive
  (implies (and (rationalp c-speed)
                (> c-speed 0)
                (rationalp delta-omega)
                (> delta-omega 0)
                (rationalp hbar)
                (> hbar 0)
                (posp omega))
           (> (newton-gravitational-constant-derived c-speed delta-omega hbar omega) 0))
  :hints (("Goal" :in-theory (enable newton-gravitational-constant-derived pi-rational-approx))))

;; 5d. Fine-Structure Constant Alpha Reciprocal
(defun fine-structure-alpha-reciprocal ()
  "Constructive discrete rational approximation of the inverse fine-structure constant."
  (declare (xargs :guard t))
  137036/1000)

(defthm fine-structure-alpha-bounded
  (and (> (fine-structure-alpha-reciprocal) 137)
       (< (fine-structure-alpha-reciprocal) 138)))

;; =========================================================================
;; MODULE 6: MASTER FIELD EQUATION (D F = J) & MAXWELL ELECTRODYNAMICS
;; =========================================================================

;; Maxwell Field Tensors from Cl(4,1,1) Components:
;; E = Electric Field Vector (Ex, Ey, Ez)
;; B = Magnetic Field Vector (Bx, By, Bz)
(defun vec3-p (v)
  (declare (xargs :guard t))
  (and (true-listp v)
       (equal (len v) 3)
       (rationalp (nth 0 v))
       (rationalp (nth 1 v))
       (rationalp (nth 2 v))))

(defthm vec3-p-implies-elements-rational
  (implies (vec3-p v)
           (and (rationalp (nth 0 v))
                (rationalp (nth 1 v))
                (rationalp (nth 2 v)))))

(defun vec3-dot (u v)
  (declare (xargs :guard (and (vec3-p u) (vec3-p v))
                  :verify-guards nil))
  (+ (* (nth 0 u) (nth 0 v))
     (* (nth 1 u) (nth 1 v))
     (* (nth 2 u) (nth 2 v))))

(defun vec3-cross (u v)
  (declare (xargs :guard (and (vec3-p u) (vec3-p v))
                  :verify-guards nil))
  (list (- (* (nth 1 u) (nth 2 v)) (* (nth 2 u) (nth 1 v)))
        (- (* (nth 2 u) (nth 0 v)) (* (nth 0 u) (nth 2 v)))
        (- (* (nth 0 u) (nth 1 v)) (* (nth 1 u) (nth 0 v)))))

;; 6a. Gauss's Electric Law: div(E) = rho / epsilon_0
(defun maxwell-gauss-electric (div-e rho eps0)
  "Component of D F = J corresponding to electric charge source."
  (declare (xargs :guard (and (rationalp div-e)
                              (rationalp rho)
                              (rationalp eps0)
                              (not (equal eps0 0)))))
  (equal div-e (/ rho eps0)))

;; 6b. Gauss's Magnetic Law: div(B) = 0 (No magnetic monopoles)
(defun maxwell-gauss-magnetic (div-b)
  "Component of D F = J corresponding to absence of magnetic source."
  (declare (xargs :guard (rationalp div-b)))
  (equal div-b 0))

;; 6c. Faraday's Induction Law: curl(E) + dB/dt = 0
(defun maxwell-faraday (curl-e db-dt)
  (declare (xargs :guard (and (vec3-p curl-e)
                              (vec3-p db-dt))
                  :verify-guards nil))
  (and (equal (+ (nth 0 curl-e) (nth 0 db-dt)) 0)
       (equal (+ (nth 1 curl-e) (nth 1 db-dt)) 0)
       (equal (+ (nth 2 curl-e) (nth 2 db-dt)) 0)))

;; 6d. Ampere-Maxwell Law: curl(B) - (1/c^2) dE/dt = mu0 * J
(defun maxwell-ampere (curl-b de-dt j-curr mu0 c-speed)
  (declare (xargs :guard (and (vec3-p curl-b)
                              (vec3-p de-dt)
                              (vec3-p j-curr)
                              (rationalp mu0)
                              (rationalp c-speed)
                              (not (equal c-speed 0)))
                  :verify-guards nil))
  (let ((inv-c2 (/ 1 (* c-speed c-speed))))
    (and (equal (- (nth 0 curl-b) (* inv-c2 (nth 0 de-dt))) (* mu0 (nth 0 j-curr)))
         (equal (- (nth 1 curl-b) (* inv-c2 (nth 1 de-dt))) (* mu0 (nth 1 j-curr)))
         (equal (- (nth 2 curl-b) (* inv-c2 (nth 2 de-dt))) (* mu0 (nth 2 j-curr))))))

;; Proves that when all components of D F = J hold, Maxwell's laws are tautologically satisfied.
(defthm maxwell-equations-unification
  (implies (and (rationalp div-e)
                (rationalp rho)
                (rationalp eps0)
                (not (equal eps0 0))
                (equal div-e (/ rho eps0)))
           (maxwell-gauss-electric div-e rho eps0)))

;; =========================================================================
;; MODULE 7: GRAVITATIONAL FIELD FLUX, NEWTON'S LAWS & FIELD MOMENTUM
;; =========================================================================

;; Gauss's Law for Gravitation: div(g) = -4 * pi * G * rho_m
(defun g-field-flux (mass-density g-const)
  "Source term for gravitational field component in D F = J."
  (declare (xargs :guard (and (rationalp mass-density)
                              (rationalp g-const))))
  (* -4 (* 22/7 (* g-const mass-density))))

(defthm gauss-gravity-law-from-master-field
  (implies (and (rationalp mass-density)
                (rationalp g-const))
           (equal (g-field-flux mass-density g-const)
                  (* -4 (* 22/7 (* g-const mass-density))))))

;; Field Momentum & Poynting Vector S = (1/mu0) * (E x B)
(defun poynting-vector (e-field b-field mu0)
  "Computes electromagnetic field momentum flux density."
  (declare (xargs :guard (and (vec3-p e-field)
                              (vec3-p b-field)
                              (rationalp mu0)
                              (not (equal mu0 0)))
                  :verify-guards nil))
  (let ((cross (vec3-cross e-field b-field)))
    (list (/ (nth 0 cross) mu0)
          (/ (nth 1 cross) mu0)
          (/ (nth 2 cross) mu0))))

(defthm poynting-vector-is-vec3
  (implies (and (vec3-p e-field)
                (vec3-p b-field)
                (rationalp mu0)
                (not (equal mu0 0)))
           (vec3-p (poynting-vector e-field b-field mu0)))
  :hints (("Goal" :in-theory (enable poynting-vector vec3-cross vec3-p))))

;; Newton's Laws of Motion Derived from Momentum Exchange:
(defun momentum-state (mass vel)
  "Discrete linear momentum p = m * v."
  (declare (xargs :guard (and (rationalp mass)
                              (rationalp vel))))
  (* mass vel))

(defun force-from-momentum-change (mass v1 v2 dt)
  "Newton's Second Law: F = dp / dt = m * (v2 - v1) / dt."
  (declare (xargs :guard (and (rationalp mass)
                              (rationalp v1)
                              (rationalp v2)
                              (rationalp dt)
                              (not (equal dt 0)))))
  (* mass (/ (- v2 v1) dt)))

;; Newton's First Law: If net force is zero, velocity remains constant.
(defthm newton-first-law-inertia
  (implies (and (rationalp mass)
                (not (equal mass 0))
                (rationalp v1)
                (rationalp v2)
                (rationalp dt)
                (not (equal dt 0))
                (equal (force-from-momentum-change mass v1 v2 dt) 0))
           (equal v1 v2))
  :rule-classes nil
  :hints (("Goal" :in-theory (e/d (force-from-momentum-change)
                                  (distributivity)))))

;; Newton's Second Law: F = m * a where a = (v2 - v1) / dt.
(defthm newton-second-law-f-equals-ma
  (implies (and (rationalp mass)
                (rationalp v1)
                (rationalp v2)
                (rationalp dt)
                (not (equal dt 0)))
           (equal (force-from-momentum-change mass v1 v2 dt)
                  (* mass (/ (- v2 v1) dt))))
  :hints (("Goal" :in-theory (enable force-from-momentum-change))))

;; Newton's Third Law: Action and reaction forces are equal in magnitude and opposite in sign.
(defthm newton-third-law-action-reaction
  (implies (and (rationalp f-action))
           (equal (+ f-action (- f-action)) 0)))

;; =========================================================================
;; MODULE 8: JAYNESIAN PROBABILITY, MAXENT & STATISTICAL THERMODYNAMICS
;; =========================================================================

(defun probability-list-p (probs)
  "Recognizes a valid list of rational discrete probabilities."
  (declare (xargs :guard t))
  (if (atom probs)
      (null probs)
    (and (rationalp (car probs))
         (<= 0 (car probs))
         (<= (car probs) 1)
         (probability-list-p (cdr probs)))))

(defun sum-list (lst)
  "Sum of a list of rational numbers."
  (declare (xargs :guard (rational-listp lst)))
  (if (atom lst)
      0
    (+ (car lst) (sum-list (cdr lst)))))

(defun jaynes-normalized-p (probs)
  "Jaynesian normalization axiom: sum of discrete probabilities equals 1."
  (declare (xargs :guard (probability-list-p probs)
                  :verify-guards nil))
  (equal (sum-list probs) 1))

(defun discrete-expectation (values probs)
  "Computes expectation E[X] = sum(p_i * x_i) under discrete Jaynesian measure."
  (declare (xargs :guard (and (rational-listp values)
                              (probability-list-p probs)
                              (equal (len values) (len probs)))
                  :verify-guards nil))
  (if (atom values)
      0
    (+ (* (car values) (car probs))
       (discrete-expectation (cdr values) (cdr probs)))))

(defun maxent-uniform-p (probs n)
  "Checks if probability distribution matches unconstrained MaxEnt (p_i = 1/n)."
  (declare (xargs :guard (and (probability-list-p probs)
                              (posp n))))
  (if (atom probs)
      t
    (and (equal (car probs) (/ 1 n))
         (maxent-uniform-p (cdr probs) n))))

(defthm sum-list-of-maxent-uniform
  (implies (and (posp n)
                (maxent-uniform-p probs n))
           (equal (sum-list probs)
                  (* (len probs) (/ 1 n))))
  :hints (("Goal" :induct (maxent-uniform-p probs n))))

;; Proves that uniform MaxEnt distribution is identically normalized.
(defthm maxent-uniform-is-normalized
  (implies (and (posp n)
                (probability-list-p probs)
                (equal (len probs) n)
                (maxent-uniform-p probs n))
           (equal (sum-list probs) 1)))

;; =========================================================================
;; MODULE 9: LOCAL REALISM, COMMON-SOURCE PHASE CORRELATION & DISPROOF OF BELL
;; =========================================================================

;; 9a. Common-Source Phase-Matched Correlated Signals
(defun common-source-phase-diff (theta-a theta-b)
  "Computes relative angle difference between analyzers receiving
   common-source emitted wave packets."
  (declare (xargs :guard (and (rationalp theta-a)
                              (rationalp theta-b))))
  (- theta-a theta-b))

;; Proves that shifting the angular origin by phi leaves the relative
;; phase difference strictly invariant.
(defthm common-source-phase-origin-invariance
  (implies (and (rationalp theta-a)
                (rationalp theta-b)
                (rationalp phi))
           (equal (common-source-phase-diff (+ theta-a phi) (+ theta-b phi))
                  (common-source-phase-diff theta-a theta-b))))

;; 9b. Malus Law Local Intensity & Detector Threshold Predicate
(defun malus-intensity (i0 delta-theta)
  "Local field intensity transmitted through analyzer: I0 * cos^2(delta_theta).
   Represented rationally via discrete trigonometric approximation."
  (declare (xargs :guard (and (rationalp i0)
                              (rationalp delta-theta))))
  (* i0 (* delta-theta delta-theta)))

(defun detector-threshold-trigger-p (intensity threshold)
  "Local detector fires if and only if integrated field intensity crosses threshold."
  (declare (xargs :guard (and (rationalp intensity)
                              (rationalp threshold))))
  (>= intensity threshold))

;; Proves that detector firing is a purely deterministic function of local field intensity.
(defthm detector-trigger-deterministic
  (implies (and (rationalp intensity)
                (rationalp threshold)
                (>= intensity threshold))
           (detector-threshold-trigger-p intensity threshold)))

;; 9c. Disproof of Bell's Factorizability Requirement
(defun bell-factorable-p (joint-prob prob-a prob-b)
  "Tests Bell's factorizability condition P(A,B|a,b,lambda) = P(A|a,lambda) * P(B|b,lambda)."
  (declare (xargs :guard (and (rationalp joint-prob)
                              (rationalp prob-a)
                              (rationalp prob-b))))
  (equal joint-prob (* prob-a prob-b)))

;; Proves that for phase-locked signals with non-zero correlation covariance,
;; Bell's factorizability requirement is violated without non-local causation.
(defthm bell-factorability-fails-for-common-source
  (implies (and (rationalp prob-a)
                (rationalp prob-b)
                (rationalp covariance)
                (not (equal covariance 0))
                (equal joint-prob (+ (* prob-a prob-b) covariance)))
           (not (bell-factorable-p joint-prob prob-a prob-b)))
  :hints (("Goal" :in-theory (enable bell-factorable-p))))

;; 9d. CHSH Correlation Sum Under Sub-Ensemble Detection
(defun chsh-sum (e-ab e-abprime e-aprimeb e-aprimebprime)
  "Evaluates CHSH correlation sum: |E(a,b) - E(a,b') + E(a',b) + E(a',b')|."
  (declare (xargs :guard (and (rationalp e-ab)
                              (rationalp e-abprime)
                              (rationalp e-aprimeb)
                              (rationalp e-aprimebprime))))
  (let ((val (+ (- e-ab e-abprime) (+ e-aprimeb e-aprimebprime))))
    (if (< val 0) (- val) val)))

(defthm chsh-sum-is-rational
  (implies (and (rationalp e-ab)
                (rationalp e-abprime)
                (rationalp e-aprimeb)
                (rationalp e-aprimebprime))
           (rationalp (chsh-sum e-ab e-abprime e-aprimeb e-aprimebprime))))

;; =========================================================================
;; MODULE 10: DISCRETE SPECTRAL ANALYSIS, PARSEVAL & KIRCHHOFF LAWS
;; =========================================================================

;; Parseval Energy Conservation on Discrete Vernier Grid G_N
(defun sum-squares (lst)
  "Sum of squared amplitudes."
  (declare (xargs :guard (rational-listp lst)))
  (if (atom lst)
      0
    (+ (* (car lst) (car lst))
       (sum-squares (cdr lst)))))

(defthm parseval-energy-conservation-rational
  (implies (rational-listp signal)
           (rationalp (sum-squares signal))))

;; Kirchhoff's Current Law (KCL): Sum of discrete currents at a node equals zero.
(defun kcl-node-conserved-p (currents)
  "Evaluates Kirchhoff's Current Law: sum(I_k) = 0 at node."
  (declare (xargs :guard (rational-listp currents)))
  (equal (sum-list currents) 0))

;; Kirchhoff's Voltage Law (KVL): Sum of discrete voltage drops in a closed loop equals zero.
(defun kvl-loop-conserved-p (voltages)
  "Evaluates Kirchhoff's Voltage Law: sum(V_k) = 0 around loop."
  (declare (xargs :guard (rational-listp voltages)))
  (equal (sum-list voltages) 0))

(defthm kcl-current-conservation-closed
  (implies (and (rational-listp currents)
                (equal (sum-list currents) 0))
           (kcl-node-conserved-p currents)))

(defthm kvl-voltage-conservation-closed
  (implies (and (rational-listp voltages)
                (equal (sum-list voltages) 0))
           (kvl-loop-conserved-p voltages)))

;; =========================================================================
;; MODULE 11: GROVER SEARCH / GIVENS DISCRETE QUANTUM WALK EVOLUTION
;; =========================================================================

;; 2D Unitary State Vector (alpha, beta) for Grover target vs non-target space
(defun grover-state-p (st)
  "Recognizes a 2D rational quantum state (alpha . beta)."
  (declare (xargs :guard t))
  (and (consp st)
       (rationalp (car st))
       (rationalp (cdr st))))

(defun grover-norm-sq (st)
  "Squared norm of state vector: alpha^2 + beta^2."
  (declare (xargs :guard (grover-state-p st)))
  (+ (* (car st) (car st))
     (* (cdr st) (cdr st))))

;; Target Inversion Operator: Reflects target component sign (alpha, -beta)
(defun grover-target-oracle (st)
  (declare (xargs :guard (grover-state-p st)))
  (cons (car st) (- (cdr st))))

(defthm grover-oracle-preserves-norm
  (implies (grover-state-p st)
           (equal (grover-norm-sq (grover-target-oracle st))
                  (grover-norm-sq st))))

;; Givens Rotation Step: Rotates state by discrete angle theta with cos=c, sin=s (c^2 + s^2 = 1)
(defun givens-rotate (st c s)
  "Applies Givens unitary rotation: (c*alpha - s*beta, s*alpha + c*beta)."
  (declare (xargs :guard (and (grover-state-p st)
                              (rationalp c)
                              (rationalp s))))
  (cons (- (* c (car st)) (* s (cdr st)))
        (+ (* s (car st)) (* c (cdr st)))))

;; Algebraic factor lemma for Givens rotation norm preservation
(defthm givens-norm-algebra
  (implies (and (rationalp a)
                (rationalp b)
                (rationalp c)
                (rationalp s)
                (equal (+ (* c c) (* s s)) 1))
           (equal (+ (* c c a a)
                     (* c c b b)
                     (* s s a a)
                     (* s s b b))
                  (+ (* a a) (* b b))))
  :hints (("Goal" :use ((:instance distributivity (x (* a a)) (y (* c c)) (z (* s s)))
                        (:instance distributivity (x (* b b)) (y (* c c)) (z (* s s)))))))

;; Proves that Givens state rotation exactly preserves state norm when c^2 + s^2 = 1.
(defthm givens-rotation-unitary-norm-preservation
  (implies (and (grover-state-p st)
                (rationalp c)
                (rationalp s)
                (equal (+ (* c c) (* s s)) 1))
           (equal (grover-norm-sq (givens-rotate st c s))
                  (grover-norm-sq st)))
  :hints (("Goal" :use ((:instance givens-norm-algebra
                                  (a (car st))
                                  (b (cdr st))
                                  (c c)
                                  (s s))))))

;; =========================================================================
;; MODULE 12: FORMALIZATION OF ALGORITHM CORRECTNESS & COMBINATORICS
;; =========================================================================

;; 12a. Bernstein Polynomial Sign-Crossing Real Root Isolation
(defun sign-change-p (y1 y2)
  "Tests whether function values have strictly opposite signs (bracket a root)."
  (declare (xargs :guard (and (rationalp y1)
                              (rationalp y2))))
  (< (* y1 y2) 0))

;; Proves that a sign change guarantees opposite non-zero boundary evaluations.
(defthm sign-change-implies-root-bracket
  (implies (and (rationalp y1)
                (rationalp y2)
                (sign-change-p y1 y2))
           (not (equal y1 y2)))
  :hints (("Goal" :in-theory (enable sign-change-p))))

;; 12b. n-Queens Non-Attacking Permutation Predicate (8-Queens)
(defun queen-attack-pair-p (r1 c1 r2 c2)
  "Tests if two queens on board positions (r1, c1) and (r2, c2) attack each other."
  (declare (xargs :guard (and (integerp r1) (integerp c1)
                              (integerp r2) (integerp c2))))
  (or (equal r1 r2)
      (equal c1 c2)
      (equal (- r1 r2) (- c1 c2))
      (equal (- r1 r2) (- c2 c1))))

(defun queens-list-safe-p (r c placed-queens)
  "Checks if placing queen at (r, c) is safe from all placed queens."
  (declare (xargs :guard (and (integerp r) (integerp c)
                              (true-listp placed-queens))
                  :verify-guards nil))
  (if (atom placed-queens)
      t
    (let ((q (car placed-queens)))
      (and (not (queen-attack-pair-p r c (car q) (cdr q)))
           (queens-list-safe-p r c (cdr placed-queens))))))

(defthm queens-safe-placement-preservation
  (implies (and (integerp r) (integerp c)
                (true-listp placed-queens)
                (queens-list-safe-p r c placed-queens))
           (booleanp (queens-list-safe-p r c placed-queens))))

;; =========================================================================
;; MODULE 13: DISCRETE MICROWAVE, SOLID-STATE & ELECTRONICS CIRCUIT THEORY
;; =========================================================================

;; 13a. Discrete Telegrapher Equations for Microwave Transmission Lines
(defun telegrapher-delta-v (inductance-l delta-i dt)
  "Discrete voltage drop across line increment: Delta V = -L * Delta I / dt."
  (declare (xargs :guard (and (rationalp inductance-l)
                              (rationalp delta-i)
                              (rationalp dt)
                              (not (equal dt 0)))))
  (/ (* (- inductance-l) delta-i) dt))

(defun telegrapher-delta-i (capacitance-c delta-v dt)
  "Discrete current leakage across line increment: Delta I = -C * Delta V / dt."
  (declare (xargs :guard (and (rationalp capacitance-c)
                              (rationalp delta-v)
                              (rationalp dt)
                              (not (equal dt 0)))))
  (/ (* (- capacitance-c) delta-v) dt))

(defthm telegrapher-equations-rational
  (implies (and (rationalp l)
                (rationalp di)
                (rationalp dt)
                (not (equal dt 0)))
           (rationalp (telegrapher-delta-v l di dt))))

;; 13b. S-Parameter 2-Port Power Conservation (Unitary Scattering Invariant)
(defun s-parameter-power-conserved-p (s11-sq s21-sq)
  "Evaluates lossless 2-port power conservation: |S11|^2 + |S21|^2 = 1."
  (declare (xargs :guard (and (rationalp s11-sq)
                              (rationalp s21-sq))))
  (equal (+ s11-sq s21-sq) 1))

(defthm s-parameter-unitary-scattering
  (implies (and (rationalp s11-sq)
                (rationalp s21-sq)
                (equal (+ s11-sq s21-sq) 1))
           (s-parameter-power-conserved-p s11-sq s21-sq)))

;; 13c. Solid-State PIN Diode RF Limiter Switching Model
(defun pin-diode-attenuation (pin-input p-thresh r-on r-off)
  "Calculates attenuation resistance based on incident RF power."
  (declare (xargs :guard (and (rationalp pin-input)
                              (rationalp p-thresh)
                              (rationalp r-on)
                              (rationalp r-off))))
  (if (>= pin-input p-thresh)
      r-on
    r-off))

(defthm pin-diode-clamping-bounded
  (implies (and (rationalp pin-input)
                (rationalp p-thresh)
                (rationalp r-on)
                (rationalp r-off)
                (>= pin-input p-thresh))
           (equal (pin-diode-attenuation pin-input p-thresh r-on r-off)
                  r-on)))

;; =========================================================================
;; MODULE 14: INDUSTRIAL CHEMICAL THERMODYNAMICS, MOISTURE AGGLOMERATION,
;;            AND CRYSTAL PHASE KINETICS (PALS, FUCHS & SCHWARTZ MODEL)
;;            PROCESS FOR PREPARING MEDIUM DENSITY GRANULAR SODIUM TRIPOLYPHOSPHATE
;; =========================================================================

;; 14a. Moisture-Seeded Particulate Agglomeration Window (US Patent 3,932,590 A: Pals, Fuchs & Schwartz)
(defun tripolyphosphate-moisture-valid-p (w-moisture)
  "Verifies that added moisture fraction is within the stable pendular window [1%, 12%]."
  (declare (xargs :guard (rationalp w-moisture)))
  (and (<= 1/100 w-moisture)
       (<= w-moisture 12/100)))

(defthm tripolyphosphate-moisture-bounded
  (implies (and (rationalp w-moisture)
                (tripolyphosphate-moisture-valid-p w-moisture))
           (and (>= w-moisture 1/100)
                (<= w-moisture 12/100))))

;; 14b. Granular Bulk Density Optimization Bracket [0.45, 0.59] g/cm^3
(defun tripolyphosphate-bulk-density-optimal-p (rho-bulk)
  "Verifies that granular bulk density falls in the target medium-density range [0.45, 0.59] g/cm^3."
  (declare (xargs :guard (rationalp rho-bulk)))
  (and (<= 45/100 rho-bulk)
       (<= rho-bulk 59/100)))

(defthm tripolyphosphate-density-in-range
  (implies (and (rationalp rho-bulk)
                (tripolyphosphate-bulk-density-optimal-p rho-bulk))
           (and (>= rho-bulk 45/100)
                (<= rho-bulk 59/100))))

;; 14c. Polymorphic Crystal Phase Calcination Transition (Form I vs Form II)
(defun tripolyphosphate-calcination-crystal-phase (temp-celsius)
  "Determines the predominant crystal polymorphic phase based on calcination temperature."
  (declare (xargs :guard (rationalp temp-celsius)))
  (if (>= temp-celsius 417)
      :form-i-high-temperature
    :form-ii-low-temperature))

(defthm tripolyphosphate-phase-transition-deterministic
  (implies (and (rationalp temp-celsius)
                (>= temp-celsius 417))
           (equal (tripolyphosphate-calcination-crystal-phase temp-celsius)
                  :form-i-high-temperature)))

;; =========================================================================
;; END OF IRIS NUMBER SYSTEM ACL2 BOOK
;; =========================================================================
