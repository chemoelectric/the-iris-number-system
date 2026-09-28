;;; test-co-expression.scm - Quiet test for make-co-expression (1-in, 1-out)
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

;; Test 1: 1-in, 1-out ping-pong exchange
(define co1
  (make-co-expression
   (lambda ()
     (let ((x (suspend 'ready)))
       (let ((y (suspend (* x 2))))
         (let ((z (suspend (+ y 100))))
           'finished))))))

(assert-equal 'ready (co1 #f) "co1-init")
(assert-equal 20 (co1 10) "co1-received-10-yielded-20")
(assert-equal 145 (co1 45) "co1-received-45-yielded-145")
(assert-equal 'finished (co1 'done) "co1-completion-value")
(assert-equal #t (eof-object? (co1 #f)) "co1-eof-1")
(assert-equal #t (eof-object? (co1 #f)) "co1-eof-2")

;; Test 2: Running accumulator co-expression
(define running-sum
  (make-co-expression
   (lambda ()
     (let loop ((total 0))
       (let ((delta (suspend total)))
         (if (eof-object? delta)
             (eof-object)
             (loop (+ total delta))))))))

(assert-equal 0 (running-sum #f) "sum-init")
(assert-equal 10 (running-sum 10) "sum-plus-10")
(assert-equal 35 (running-sum 25) "sum-plus-25")
(assert-equal 30 (running-sum -5) "sum-minus-5")
(assert-equal 100 (running-sum 70) "sum-plus-70")
(assert-equal #t (eof-object? (running-sum (eof-object))) "sum-eof")

;; Test 3: Two independent 1-in, 1-out co-expressions running concurrently
(define doubler
  (make-co-expression
   (lambda ()
     (let loop ()
       (let ((x (suspend 'doubler-ready)))
         (suspend (* x 2))
         (loop))))))

(define tripler
  (make-co-expression
   (lambda ()
     (let loop ()
       (let ((x (suspend 'tripler-ready)))
         (suspend (* x 3))
         (loop))))))

(assert-equal 'doubler-ready (doubler #f) "doubler-init")
(assert-equal 'tripler-ready (tripler #f) "tripler-init")

(assert-equal 14 (doubler 7) "doubler-7")
(assert-equal 21 (tripler 7) "tripler-7")
(assert-equal 'doubler-ready (doubler #f) "doubler-step-back")
(assert-equal 'tripler-ready (tripler #f) "tripler-step-back")
(assert-equal 100 (doubler 50) "doubler-50")
(assert-equal 150 (tripler 50) "tripler-50")

;; Silent exit 0 on success
(exit 0)
