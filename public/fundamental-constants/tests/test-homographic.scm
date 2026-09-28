;;; test-homographic.scm - Quiet test for Gosper's homographic transform
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

;; Test 1: Identity transform: y = (1*x + 0) / (0*x + 1) = x
(define id-cf
  (cf-homographic 1 0 0 1 (cf:rational 22/7)))
(define id-terms (cf-terms->list id-cf 10))
(assert-equal '((1 . 3) (1 . 7)) id-terms "identity-homographic")

;; Test 2: Scale by 2: y = (2*x + 0) / (0*x + 1) = 2*x
;; For x = 22/7, 2*x = 44/7 = [6; 3, 2]
(define scale-cf
  (cf-homographic 2 0 0 1 (cf:rational 22/7)))
(define scale-terms (cf-terms->list scale-cf 10))
(assert-equal '((1 . 6) (1 . 3) (1 . 2))
              scale-terms
              "scale-2-homographic")

;; Test 3: Shift by 1: y = (1*x + 1) / (0*x + 1) = x + 1
;; For phi = [1; 1, 1, ...], phi + 1 = phi^2 = [2; 1, 1, 1, ...]
(define phi+1-cf
  (cf-homographic 1 1 0 1 (cf:golden-ratio)))
(define phi+1-terms (cf-terms->list phi+1-cf 5))
(assert-equal '((1 . 2) (1 . 1) (1 . 1) (1 . 1) (1 . 1))
              phi+1-terms
              "phi-plus-1-homographic")

;; Silent exit 0 on success
(exit 0)
