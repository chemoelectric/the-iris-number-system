;;; test-continued-fraction.scm - Quiet test for continued-fraction.sld
;;; Compatible with autotest / test harnesses. Exits 0 on success.

(import (scheme base)
        (scheme process-context)
        (scheme write)
        (fundamental-constants continued-fraction))

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

;; Test 1: Rational continued fraction for 355/113
(define cf-rat (cf:rational 355/113))
(define rat-terms (cf-terms->list cf-rat 10))
(assert-equal '((1 . 3) (1 . 7) (1 . 16)) rat-terms "rat-terms")

(define rat-conv (cf-convergents (cf:rational 355/113)))
(define rat-conv-list (cf-terms->list rat-conv 10))
(assert-equal '(3 22/7 355/113)
              (map (lambda (x) (if (pair? x) (car x) x))
                   rat-conv-list)
              "rat-convergents")

;; Test 2: Golden ratio convergents (Fibonacci ratios)
(define phi-conv (cf-convergents (cf:golden-ratio)))
(define phi-list
  (let loop ((k 0) (acc '()))
    (if (= k 7)
        (reverse acc)
        (let-values (((val) (cf-step phi-conv)))
          (loop (+ k 1) (cons val acc))))))

(assert-equal '(1 2 3/2 5/3 8/5 13/8 21/13) phi-list "phi-convergents")

;; Test 3: Sqrt(2) continued fraction: [1; 2, 2, 2, ...]
(define sqrt2-terms (cf-terms->list (cf:sqrt 2) 5))
(assert-equal '((1 . 1) (1 . 2) (1 . 2) (1 . 2) (1 . 2))
              sqrt2-terms
              "sqrt2-terms")

(define sqrt2-conv (cf-convergents (cf:sqrt 2)))
(define sqrt2-conv-list
  (let loop ((k 0) (acc '()))
    (if (= k 5)
        (reverse acc)
        (let-values (((val) (cf-step sqrt2-conv)))
          (loop (+ k 1) (cons val acc))))))

(assert-equal '(1 3/2 7/5 17/12 41/29)
              sqrt2-conv-list
              "sqrt2-convergents")

;; Test 4: Base of natural logarithms e
(define e-conv (cf-convergents (cf:e)))
(define e-conv-list
  (let loop ((k 0) (acc '()))
    (if (= k 6)
        (reverse acc)
        (let-values (((val) (cf-step e-conv)))
          (loop (+ k 1) (cons val acc))))))

(assert-equal '(2 3 8/3 11/4 19/7 87/32)
              e-conv-list
              "e-convergents")

;; Test 5: Simple pi convergents
(define pi-conv (cf-convergents (cf:pi-simple)))
(define pi-conv-list
  (let loop ((k 0) (acc '()))
    (if (= k 4)
        (reverse acc)
        (let-values (((val) (cf-step pi-conv)))
          (loop (+ k 1) (cons val acc))))))

(assert-equal '(3 22/7 333/106 355/113)
              pi-conv-list
              "pi-simple-convergents")

;; Silent exit 0 on success
(exit 0)
