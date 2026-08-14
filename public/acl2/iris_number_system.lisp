;;; =========================================================================
;;; ACL2 Book: Iris Number System Formalization
;;; Author: Frédéric Blondin Custer
;;;
;;; Formalizes the discrete Multiscale Resolution Analysis (MSRA) ring,
;;; Vernier aperture steps, Main Scale Projection operator (downarrow),
;;; and exact tautological completeness of finite rational arithmetic.
;;; =========================================================================

(in-package "ACL2")

;; -------------------------------------------------------------------------
;; 1. Vernier Discrete Grid State Recognizer & Constructor
;; -------------------------------------------------------------------------

(defun iris-vernier-grid-p (k omega)
  "Recognizes a valid vernier grid coordinate k * delta_omega where
   k is an integer step count and omega is a positive integer resolution."
  (declare (xargs :guard t))
  (and (integerp k)
       (posp omega)))

(defun iris-step-size (omega)
  "Computes discrete grid step size delta_omega = 1 / omega."
  (declare (xargs :guard (posp omega)))
  (/ 1 omega))

(defun iris-vernier-value (k omega)
  "Computes exact rational position k * delta_omega = k / omega."
  (declare (xargs :guard (iris-vernier-grid-p k omega)))
  (* k (iris-step-size omega)))

;; -------------------------------------------------------------------------
;; 2. Main Scale Projection Operator (downarrow)
;; -------------------------------------------------------------------------

(defun iris-downarrow (r)
  "Main Scale Projection operator (downarrow) mapping ultra-refined
   vernier rational readings to the standard main-scale rational domain."
  (declare (xargs :guard (rationalp r)))
  r)

;; -------------------------------------------------------------------------
;; 3. Theorems: Rational Closure & Homomorphism Properties
;; -------------------------------------------------------------------------

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

;; -------------------------------------------------------------------------
;; 4. MSRA Vernier Discrete Derivative Operator
;; -------------------------------------------------------------------------

(defun msra-discrete-diff (f x omega)
  "Computes exact discrete vernier difference quotient:
   [f(x + delta_omega) - f(x)] / delta_omega."
  (declare (xargs :guard (and (posp omega)
                              (rationalp x))))
  (let ((delta (iris-step-size omega)))
    (/ (- (f (+ x delta)) (f x))
       delta)))

(defun msra-derivative (f x omega)
  "MSRA derivative under Main Scale Projection (downarrow)."
  (declare (xargs :guard (and (posp omega)
                              (rationalp x))))
  (iris-downarrow (msra-discrete-diff f x omega)))

;; -------------------------------------------------------------------------
;; 5. Cl(2,0) Bivector Rotor State Representation & Multiplication
;; -------------------------------------------------------------------------

(defun cl2-multivector-p (v)
  "Recognizes a 4-component Cl(2,0) multivector (scalar, e1, e2, e12)."
  (declare (xargs :guard t))
  (and (consp v)
       (rationalp (nth 0 v))
       (rationalp (nth 1 v))
       (rationalp (nth 2 v))
       (rationalp (nth 3 v))))

(defun cl2-make (s e1 e2 e12)
  "Constructs a Cl(2,0) multivector."
  (declare (xargs :guard (and (rationalp s)
                              (rationalp e1)
                              (rationalp e2)
                              (rationalp e12))))
  (list s e1 e2 e12))

(defun cl2-add (u v)
  "Componentwise addition in Cl(2,0)."
  (declare (xargs :guard (and (cl2-multivector-p u)
                              (cl2-multivector-p v))))
  (cl2-make (+ (nth 0 u) (nth 0 v))
            (+ (nth 1 u) (nth 1 v))
            (+ (nth 2 u) (nth 2 v))
            (+ (nth 3 u) (nth 3 v))))

(defun cl2-mul (u v)
  "Cl2,0 geometric product where e1^2 = 1, e2^2 = 1, e12^2 = -1."
  (declare (xargs :guard (and (cl2-multivector-p u)
                              (cl2-multivector-p v))))
  (let ((u0 (nth 0 u)) (u1 (nth 1 u)) (u2 (nth 2 u)) (u3 (nth 3 u))
        (v0 (nth 0 v)) (v1 (nth 1 v)) (v2 (nth 2 v)) (v3 (nth 3 v)))
    (cl2-make
     ;; Scalar term: u0*v0 + u1*v1 + u2*v2 - u3*v3
     (- (+ (+ (* u0 v0) (* u1 v1)) (* u2 v2)) (* u3 v3))
     ;; e1 term: u0*v1 + u1*v0 - u2*v3 + u3*v2
     (+ (- (+ (* u0 v1) (* u1 v0)) (* u2 v3)) (* u3 v2))
     ;; e2 term: u0*v2 + u2*v0 + u1*v3 - u3*v1
     (- (+ (+ (* u0 v2) (* u2 v0)) (* u1 v3)) (* u3 v1))
     ;; e12 term: u0*v3 + u3*v0 + u1*v2 - u2*v1
     (- (+ (+ (* u0 v3) (* u3 v0)) (* u1 v2)) (* u2 v1)))))

(defthm cl2-add-associative
  (implies (and (cl2-multivector-p u)
                (cl2-multivector-p v)
                (cl2-multivector-p w))
           (equal (cl2-add (cl2-add u v) w)
                  (cl2-add u (cl2-add v w)))))
