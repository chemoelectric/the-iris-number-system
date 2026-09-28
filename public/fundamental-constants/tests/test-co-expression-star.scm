;;; test-co-expression-star.scm - Quiet test for make-co-expression* (multi-in, multi-out)
;;; Non-glob alias for test-co-expression*.scm. Exits 0 on success.

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

;; Test 1: Multiple values in yield
(define g1
  (make-co-expression*
   (lambda ()
     (suspend 1 2 3)
     (suspend 4 5)
     (eof-object))))

(let-values (((a b c) (g1)))
  (assert-equal '(1 2 3) (list a b c) "g1-three-values"))

(let-values (((d e) (g1)))
  (assert-equal '(4 5) (list d e) "g1-two-values"))

;; Test 2: Two-way multiple values exchange
(define g2
  (make-co-expression*
   (lambda ()
     (let-values (((x y) (suspend 100 200)))
       (let-values (((z) (suspend (+ x y))))
         (suspend (* z 2))
         (eof-object))))))

(let-values (((a b) (g2)))
  (assert-equal '(100 200) (list a b) "g2-initial-yield"))

(let-values (((c) (g2 10 25)))
  (assert-equal 35 c "g2-received-and-computed"))

(let-values (((d) (g2 7)))
  (assert-equal 14 d "g2-final-yield"))

(assert-equal #t (eof-object? (g2)) "g2-exhausted")

;; Test 3: Multiple inputs, multiple outputs in a loop
(define transformer
  (make-co-expression*
   (lambda ()
     (let loop ()
       (let-values (((u v) (suspend 'ready-u 'ready-v)))
         (suspend (+ u v) (* u v))
         (loop))))))

(let-values (((r1 r2) (transformer)))
  (assert-equal '(ready-u ready-v) (list r1 r2) "transformer-init"))

(let-values (((sum1 prod1) (transformer 3 4)))
  (assert-equal '(7 12) (list sum1 prod1) "transformer-step-1"))

(let-values (((r1 r2) (transformer)))
  (assert-equal '(ready-u ready-v) (list r1 r2) "transformer-ready-again"))

(let-values (((sum2 prod2) (transformer 10 20)))
  (assert-equal '(30 200) (list sum2 prod2) "transformer-step-2"))

;; Test 4: Custom multiple return values yielded upon thunk completion
(define g3
  (make-co-expression*
   (lambda ()
     (suspend 'item1 'item2)
     (values 'done1 'done2))))

(let-values (((a b) (g3)))
  (assert-equal '(item1 item2) (list a b) "g3-yield"))

(let-values (((c d) (g3)))
  (assert-equal '(done1 done2) (list c d) "g3-completion-values"))

(assert-equal #t (eof-object? (g3)) "g3-subsequent-eof-1")
(assert-equal #t (eof-object? (g3)) "g3-subsequent-eof-2")

;; Silent exit 0 on success
(exit 0)
