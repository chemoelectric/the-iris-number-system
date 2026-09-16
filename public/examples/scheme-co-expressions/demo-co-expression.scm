(import (scheme base))
(import (scheme write))
(import (co-expression))

(define (co-sequence i0)
  (make-co-expression
   (lambda ()
     (let loop ((i i0))
       (cond
        ((= i 60) (eof-object))
        (else
         (let-values ((y* (suspend i (+ i 1) (+ i 2))))
           (write y*)
           (newline)
           (loop (+ i 10)))))))))

(define s! (co-sequence 0))
(s!) ;; Initialize the co-expression.
(write (let-values ((lst (s! 1 2 3))) lst)) (newline)
(write (let-values ((lst (s! 1 2 3 4 5 6))) lst)) (newline)
(write (let-values ((lst (s! "a" "b" "c"))) lst)) (newline)
(write (let-values ((lst (s! #\a #\b #\c))) lst)) (newline)
(write (let-values ((lst (s! '() '(()) '((()))))) lst)) (newline)
(write (let-values ((lst (s! '() '(()) '((()))))) lst)) (newline)
(write (let-values ((lst (s! '() '(()) '((()))))) lst)) (newline)
(write (let-values ((lst (s! '() '(()) '((()))))) lst)) (newline)

#|
Example output:
❯ gosh -r7 -I . demo-co-expression.scm 
(1 2 3)
(10 11 12)
(1 2 3 4 5 6)
(20 21 22)
("a" "b" "c")
(30 31 32)
(#\a #\b #\c)
(40 41 42)
(() (()) ((())))
(50 51 52)
(() (()) ((())))
(#<eof>)
(#<eof>)
(#<eof>)
|#
