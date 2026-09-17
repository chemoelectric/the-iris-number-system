;;; test-pi.scm - Quiet test for (fundamental-constants pi)
;;; Compatible with autotest / test harnesses. Exits 0 on success.

(import (scheme base)
        (scheme process-context)
        (scheme write)
        (fundamental-constants co-expression)
        (fundamental-constants continued-fraction)
        (fundamental-constants pi))

(cond-expand
  ((library (scheme fixnum))
   (import (scheme fixnum)))
  (else
   (import (srfi 143))))

(cond-expand
  ((library (scheme flonum))
   (import (scheme flonum)))
  (else
   (import (srfi 144))))

(define (assert-equal expected actual name)
  (unless (equal? expected actual)
    (display "FAIL: ")
    (display name)
    (newline)
    (display "  expected: ")
    (write expected)
    (newline)
    (display "  actual:   ")
    (write actual)
    (newline)
    (exit 1)))

;; Test 1: Simple continued fraction for pi (ASCII cf:pi and Unicode cf:π)
(define pi-terms-5 (cf-terms->list (cf:pi) 5))
(assert-equal '((1 . 3) (1 . 7) (1 . 15) (1 . 1) (1 . 292))
              pi-terms-5
              "pi-simple-terms-5")

(define π-terms-5 (cf-terms->list (cf:π) 5))
(assert-equal '((1 . 3) (1 . 7) (1 . 15) (1 . 1) (1 . 292))
              π-terms-5
              "π-simple-terms-5")

;; Test 2: Convergents of pi: 3, 22/7, 333/106, 355/113, 103993/33102
(define pi-conv (cf-convergents (cf:pi)))
(define pi-conv-list (cf-terms->list pi-conv 5))
(assert-equal '(3 22/7 333/106 355/113 103993/33102)
              (map (lambda (x) (if (pair? x) (car x) x)) pi-conv-list)
              "pi-convergents-5")

;; Test 3: Trigonometric fraction pi/2 and π/2
;; OEIS A019669: [1; 1, 1, 3, 31, 1, 145, 1, 4, 2, ...]
(define pi/2-terms-6 (cf-terms->list (cf:pi/2) 6))
(assert-equal '((1 . 1) (1 . 1) (1 . 1) (1 . 3) (1 . 31) (1 . 1))
              pi/2-terms-6
              "pi/2-terms-6")

(define π/2-terms-6 (cf-terms->list (cf:π/2) 6))
(assert-equal '((1 . 1) (1 . 1) (1 . 1) (1 . 3) (1 . 31) (1 . 1))
              π/2-terms-6
              "π/2-terms-6")

;; Test 4: Trigonometric fraction pi/3 and π/3
;; [1; 21, 5, 3, 97, 1, ...]
(define pi/3-terms-5 (cf-terms->list (cf:pi/3) 5))
(assert-equal '((1 . 1) (1 . 21) (1 . 5) (1 . 3) (1 . 97))
              pi/3-terms-5
              "pi/3-terms-5")

(define π/3-terms-5 (cf-terms->list (cf:π/3) 5))
(assert-equal '((1 . 1) (1 . 21) (1 . 5) (1 . 3) (1 . 97))
              π/3-terms-5
              "π/3-terms-5")

;; Test 5: Trigonometric fraction pi/4 and π/4
;; OEIS A019671: [0; 1, 3, 1, 1, 1, 15, ...]
(define pi/4-terms-5 (cf-terms->list (cf:pi/4) 5))
(assert-equal '((1 . 0) (1 . 1) (1 . 3) (1 . 1) (1 . 1))
              pi/4-terms-5
              "pi/4-terms-5")

(define π/4-terms-5 (cf-terms->list (cf:π/4) 5))
(assert-equal '((1 . 0) (1 . 1) (1 . 3) (1 . 1) (1 . 1))
              π/4-terms-5
              "π/4-terms-5")

;; Test 6: Trigonometric fraction pi/6 and π/6
;; [0; 1, 1, 10, 10, 1, ...]
(define pi/6-terms-5 (cf-terms->list (cf:pi/6) 5))
(assert-equal '((1 . 0) (1 . 1) (1 . 1) (1 . 10) (1 . 10))
              pi/6-terms-5
              "pi/6-terms-5")

(define π/6-terms-5 (cf-terms->list (cf:π/6) 5))
(assert-equal '((1 . 0) (1 . 1) (1 . 1) (1 . 10) (1 . 10))
              π/6-terms-5
              "π/6-terms-5")

;; Test 7: Reciprocal 1/pi, one/pi, inv-pi, 1/π, one/π, inv-π
;; OEIS A049541: [0; 3, 7, 15, 1, 292, ...]
(define 1/pi-terms-5 (cf-terms->list (cf:1/pi) 5))
(assert-equal '((1 . 0) (1 . 3) (1 . 7) (1 . 15) (1 . 1))
              1/pi-terms-5
              "1/pi-terms-5")

(define 1/π-terms-5 (cf-terms->list (cf:1/π) 5))
(assert-equal '((1 . 0) (1 . 3) (1 . 7) (1 . 15) (1 . 1))
              1/π-terms-5
              "1/π-terms-5")

(define inv-pi-terms-5 (cf-terms->list (cf:inv-pi) 5))
(assert-equal '((1 . 0) (1 . 3) (1 . 7) (1 . 15) (1 . 1))
              inv-pi-terms-5
              "inv-pi-terms-5")

;; Test 8: Reciprocal 2/pi, two/pi, 2/π, two/π
;; OEIS A049542: [0; 1, 1, 1, 3, 31, ...]
(define 2/pi-terms-5 (cf-terms->list (cf:2/pi) 5))
(assert-equal '((1 . 0) (1 . 1) (1 . 1) (1 . 1) (1 . 3))
              2/pi-terms-5
              "2/pi-terms-5")

(define two/π-terms-5 (cf-terms->list (cf:two/π) 5))
(assert-equal '((1 . 0) (1 . 1) (1 . 1) (1 . 1) (1 . 3))
              two/π-terms-5
              "two/π-terms-5")

;; Test 9: Reciprocal 3/pi, three/pi, 3/π, three/π
;; [0; 1, 21, 5, 3, 97, ...]
(define 3/pi-terms-5 (cf-terms->list (cf:3/pi) 5))
(assert-equal '((1 . 0) (1 . 1) (1 . 21) (1 . 5) (1 . 3))
              3/pi-terms-5
              "3/pi-terms-5")

;; Test 10: Reciprocal 4/pi, four/pi, 4/π, four/π
;; OEIS A049544: [1; 3, 1, 1, 1, 15, ...]
(define 4/pi-terms-5 (cf-terms->list (cf:4/pi) 5))
(assert-equal '((1 . 1) (1 . 3) (1 . 1) (1 . 1) (1 . 1))
              4/pi-terms-5
              "4/pi-terms-5")

(define four/π-terms-5 (cf-terms->list (cf:four/π) 5))
(assert-equal '((1 . 1) (1 . 3) (1 . 1) (1 . 1) (1 . 1))
              four/π-terms-5
              "four/π-terms-5")

;; Test 11: Reciprocal 6/pi, six/pi, 6/π, six/π
;; [1; 1, 10, 10, 1, ...]
(define 6/pi-terms-5 (cf-terms->list (cf:6/pi) 5))
(assert-equal '((1 . 1) (1 . 1) (1 . 10) (1 . 10) (1 . 1))
              6/pi-terms-5
              "6/pi-terms-5")

(define six/π-terms-5 (cf-terms->list (cf:six/π) 5))
(assert-equal '((1 . 1) (1 . 1) (1 . 10) (1 . 10) (1 . 1))
              six/π-terms-5
              "six/π-terms-5")

;; Test 12: Basel constant pi^2/6 = zeta(2) (OEIS A013679)
;; [1; 1, 1, 1, 4, 2, 4, 7, 1, 4, 2, 3, 4, 10, ...]
(define pi^2/6-terms-8 (cf-terms->list (cf:pi^2/6) 8))
(assert-equal '((1 . 1) (1 . 1) (1 . 1) (1 . 1) (1 . 4) (1 . 2) (1 . 4) (1 . 7))
              pi^2/6-terms-8
              "pi^2/6-terms-8")

(define π²/6-terms-8 (cf-terms->list (cf:π²/6) 8))
(assert-equal '((1 . 1) (1 . 1) (1 . 1) (1 . 1) (1 . 4) (1 . 2) (1 . 4) (1 . 7))
              π²/6-terms-8
              "π²/6-terms-8")

;; Test 13: Coprime probability 6/pi^2 = 1/zeta(2) (OEIS A059956)
;; [0; 1, 1, 1, 1, 4, 2, 4, 7, ...]
(define 6/pi^2-terms-8 (cf-terms->list (cf:6/pi^2) 8))
(assert-equal '((1 . 0) (1 . 1) (1 . 1) (1 . 1) (1 . 1) (1 . 4) (1 . 2) (1 . 4))
              6/pi^2-terms-8
              "6/pi^2-terms-8")

(define six/π²-terms-8 (cf-terms->list (cf:six/π²) 8))
(assert-equal '((1 . 0) (1 . 1) (1 . 1) (1 . 1) (1 . 1) (1 . 4) (1 . 2) (1 . 4))
              six/π²-terms-8
              "six/π²-terms-8")

;; Test 14: Generalized continued fractions for pi/4 (Euler) and 4/pi (Brouncker)
(define pi/4-euler-terms (cf-terms->list (cf:pi/4-euler) 5))
;; Terms: (1 . 0), (1 . 1), (1 . 3), (4 . 5), (9 . 7)
(assert-equal '((1 . 0) (1 . 1) (1 . 3) (4 . 5) (9 . 7))
              pi/4-euler-terms
              "pi/4-euler-terms")

(define four/pi-brouncker-terms (cf-terms->list (cf:four/pi-brouncker) 5))
;; Terms: (1 . 1), (1 . 2), (9 . 2), (25 . 2), (49 . 2)
(assert-equal '((1 . 1) (1 . 2) (9 . 2) (25 . 2) (49 . 2))
              four/pi-brouncker-terms
              "four/pi-brouncker-terms")

;; Silent exit 0 on success
(exit 0)
