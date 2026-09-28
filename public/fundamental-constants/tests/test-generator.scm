;;; test-generator.scm - Quiet test for make-generator (0-in, 1-out)
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

;; Test 1: Simple sequential generator ending with eof-object
(define g1
  (make-generator
   (lambda ()
     (suspend 10)
     (suspend 20)
     (suspend 30)
     (eof-object))))

(assert-equal 10 (g1) "g1-first")
(assert-equal 20 (g1) "g1-second")
(assert-equal 30 (g1) "g1-third")
(assert-equal #t (eof-object? (g1)) "g1-eof-1")
(assert-equal #t (eof-object? (g1)) "g1-eof-2")
(assert-equal #t (eof-object? (g1)) "g1-eof-3")

;; Test 2: Custom return value yielded upon thunk completion
(define g2
  (make-generator
   (lambda ()
     (suspend 'alpha)
     (suspend 'beta)
     'completed)))

(assert-equal 'alpha (g2) "g2-first")
(assert-equal 'beta (g2) "g2-second")
(assert-equal 'completed (g2) "g2-completion-value")
(assert-equal #t (eof-object? (g2)) "g2-subsequent-eof-1")
(assert-equal #t (eof-object? (g2)) "g2-subsequent-eof-2")

;; Test 3: Infinite generator (Fibonacci sequence)
(define fib-gen
  (make-generator
   (lambda ()
     (let loop ((a 0) (b 1))
       (suspend a)
       (loop b (+ a b))))))

(define fib-first-8
  (let loop ((k 0) (acc '()))
    (if (= k 8)
        (reverse acc)
        (loop (+ k 1) (cons (fib-gen) acc)))))

(assert-equal '(0 1 1 2 3 5 8 13) fib-first-8 "fib-infinite-generator")

;; Test 4: Multiple independent generator instances running simultaneously
(define gen-a (make-generator (lambda () (suspend 1) (suspend 2) 'done-a)))
(define gen-b (make-generator (lambda () (suspend 100) (suspend 200) 'done-b)))

(assert-equal 1 (gen-a) "interleave-a1")
(assert-equal 100 (gen-b) "interleave-b1")
(assert-equal 2 (gen-a) "interleave-a2")
(assert-equal 200 (gen-b) "interleave-b2")
(assert-equal 'done-a (gen-a) "interleave-a-done")
(assert-equal 'done-b (gen-b) "interleave-b-done")
(assert-equal #t (eof-object? (gen-a)) "interleave-a-eof")
(assert-equal #t (eof-object? (gen-b)) "interleave-b-eof")

;; Silent exit 0 on success
(exit 0)
