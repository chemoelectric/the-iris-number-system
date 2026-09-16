;;; test-co-expression.scm - Quiet test for co-expression.sld
;;; Compatible with autotest / test harnesses. Exits 0 on success.

(import (scheme base)
        (scheme process-context)
        (scheme write)
        (fundamental-constants co-expression))

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

;; Test 1: Simple generator sequence
(define g1
  (make-co-expression
   (lambda ()
     (suspend 10)
     (suspend 20)
     (suspend 30))))

(assert-equal 10 (g1) "g1-first")
(assert-equal 20 (g1) "g1-second")
(assert-equal 30 (g1) "g1-third")
(assert-equal #t (eof-object? (g1)) "g1-eof-1")
(assert-equal #t (eof-object? (g1)) "g1-eof-2")

;; Test 2: Multiple values in yield
(define g2
  (make-co-expression
   (lambda ()
     (suspend 1 2 3)
     (suspend 4 5))))

(let-values (((a b c) (g2)))
  (assert-equal '(1 2 3) (list a b c) "g2-three-values"))

(let-values (((d e) (g2)))
  (assert-equal '(4 5) (list d e) "g2-two-values"))

;; Test 3: Two-way multiple values exchange
(define g3
  (make-co-expression
   (lambda ()
     (let-values (((x y) (suspend 100 200)))
       (let-values (((z) (suspend (+ x y))))
         (suspend (* z 2)))))))

(let-values (((a b) (g3)))
  (assert-equal '(100 200) (list a b) "g3-initial-yield"))

(let-values (((c) (g3 10 25)))
  (assert-equal 35 c "g3-received-and-computed"))

(let-values (((d) (g3 7)))
  (assert-equal 14 d "g3-final-yield"))

(assert-equal #t (eof-object? (g3)) "g3-exhausted")

;; Silent exit 0 on success
(exit 0)
