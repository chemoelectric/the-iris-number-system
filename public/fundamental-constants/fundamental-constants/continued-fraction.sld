;;; Copyright (c) 2026 Barry Schwartz
;;;
;;; Permission is hereby granted, free of charge, to any person
;;; obtaining a copy of this software and associated documentation
;;; files (the "Software"), to deal in the Software without
;;; restriction, including without limitation the rights to use,
;;; copy, modify, merge, publish, distribute, sublicense, and/or sell
;;; copies of the Software, and to permit persons to whom the
;;; Software is furnished to do so, subject to the following
;;; conditions:
;;;
;;; The above copyright notice and this permission notice shall be
;;; included in all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
;;; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
;;; OTHER DEALINGS IN THE SOFTWARE.

(define-library (fundamental-constants continued-fraction)

  (import (scheme base)
          (fundamental-constants co-expression))

  (export make-cf
          cf-step
          cf-terms->list
          cf-convergents
          ;; Core generator procedures:
          cf:rational
          cf:golden-ratio
          cf:silver-ratio
          cf:e
          cf:sqrt
          cf:pi-brouncker
          cf:pi-simple
          ;; Gosper homographic transform:
          cf-homographic)

  (begin

    ;; Constructor for continued-fraction co-expressions.
    (define make-cf make-co-expression*)

    ;; Advance a continued fraction by one term.
    ;; Returns two values: partial numerator a_n and partial
    ;; denominator b_n, or eof-objects when exhausted.
    (define (cf-step cf . args)
      (apply cf args))

    ;; Collect up to `limit` terms from a continued fraction
    ;; as a list of pairs ((a0 . b0) (a1 . b1) ...) or values.
    (define (cf-terms->list cf limit)
      (let loop ((count 0)
                 (acc '()))
        (if (>= count limit)
            (reverse acc)
            (call-with-values
                (lambda () (cf-step cf))
              (lambda vals
                (cond
                 ((or (null? vals) (eof-object? (car vals)))
                  (reverse acc))
                 ((null? (cdr vals))
                  (loop (+ count 1)
                        (cons (car vals) acc)))
                 (else
                  (loop (+ count 1)
                        (cons (cons (car vals) (cadr vals)) acc)))))))))

    ;; -------------------------------------------------------------
    ;; Convergents generator:
    ;; Yields successive rational convergents p_n / q_n as exact
    ;; Scheme rationals, using the fundamental recurrence:
    ;;   p_{-2} = 0, p_{-1} = 1
    ;;   q_{-2} = 1, q_{-1} = 0
    ;;   p_n = b_n * p_{n-1} + a_n * p_{n-2}
    ;;   q_n = b_n * q_{n-1} + a_n * q_{n-2}
    ;; -------------------------------------------------------------
    (define (cf-convergents cf)
      (make-co-expression*
       (lambda ()
         (let loop ((p-2 0) (p-1 1)
                    (q-2 1) (q-1 0))
           (call-with-values
               (lambda () (cf-step cf))
             (lambda (a . rest)
               (if (or (eof-object? a) (null? rest) (eof-object? (car rest)))
                   (eof-object)
                   (let* ((b (car rest))
                          (p (+ (* b p-1) (* a p-2)))
                          (q (+ (* b q-1) (* a q-2))))
                     (suspend (/ p q))
                     (loop p-1 p q-1 q)))))))))

    ;; -------------------------------------------------------------
    ;; Exact rational continued fraction: r = num / den.
    ;; Yields simple CF terms: (1, b0), (1, b1), ...
    ;; -------------------------------------------------------------
    (define (cf:rational r)
      (let ((num (numerator r))
            (den (denominator r)))
        (make-co-expression*
         (lambda ()
           (let loop ((n num) (d den))
             (if (zero? d)
                 (values (eof-object) (eof-object))
                 (let ((q (floor-quotient n d))
                       (rem (floor-remainder n d)))
                   (suspend 1 q)
                   (loop d rem))))))))

    ;; -------------------------------------------------------------
    ;; Golden ratio phi = (1 + sqrt(5)) / 2 = [1; 1, 1, 1, ...]
    ;; -------------------------------------------------------------
    (define (cf:golden-ratio)
      (make-co-expression*
       (lambda ()
         (let loop ()
           (suspend 1 1)
           (loop)))))

    ;; -------------------------------------------------------------
    ;; Silver ratio delta_S = 1 + sqrt(2) = [2; 2, 2, 2, ...]
    ;; -------------------------------------------------------------
    (define (cf:silver-ratio)
      (make-co-expression*
       (lambda ()
         (let loop ()
           (suspend 1 2)
           (loop)))))

    ;; -------------------------------------------------------------
    ;; Base of natural logarithms:
    ;; e = [2; 1, 2, 1, 1, 4, 1, 1, 6, 1, 1, 8, ...]
    ;; -------------------------------------------------------------
    (define (cf:e)
      (make-co-expression*
       (lambda ()
         (suspend 1 2)
         (let loop ((k 1))
           (suspend 1 1)
           (suspend 1 (* 2 k))
           (suspend 1 1)
           (loop (+ k 1))))))

    ;; -------------------------------------------------------------
    ;; Periodic simple continued fraction for sqrt(N), where N is
    ;; a positive integer.
    ;; -------------------------------------------------------------
    (define (cf:sqrt n)
      (make-co-expression*
       (lambda ()
         (let-values (((s r) (exact-integer-sqrt n)))
           (suspend 1 s)
           (if (zero? r)
               (values (eof-object) (eof-object))
               (let loop ((m 0)
                          (d 1)
                          (a s))
                 (let* ((m-next (- (* d a) m))
                        (d-next (floor-quotient (- n (* m-next m-next))
                                                d))
                        (a-next (floor-quotient (+ s m-next)
                                                d-next)))
                   (suspend 1 a-next)
                   (loop m-next d-next a-next))))))))

    ;; -------------------------------------------------------------
    ;; Generalized continued fraction for pi (Lord Brouncker):
    ;; pi = 3 + 1^2 / (6 + 3^2 / (6 + 5^2 / (6 + ...)))
    ;; Emits:
    ;;   step 0: (1, 3)
    ;;   step k: ((2k - 1)^2, 6)
    ;; Convergents: 3, 19/6, 47/15, 646/195, ...
    ;; -------------------------------------------------------------
    (define (cf:pi-brouncker)
      (make-co-expression*
       (lambda ()
         (suspend 1 3)
         (let loop ((k 1))
           (let ((odd (- (* 2 k) 1)))
             (suspend (* odd odd) 6)
             (loop (+ k 1)))))))

    ;; -------------------------------------------------------------
    ;; Simple continued fraction for pi:
    ;; [3; 7, 15, 1, 292, 1, 1, 1, 2, 1, 3, 1, 14, 2, 1, 1, ...]
    ;; Convergents: 3, 22/7, 333/106, 355/113, 103993/33102, ...
    ;; -------------------------------------------------------------
    (define (cf:pi-simple)
      (define pi-terms
        '(3 7 15 1 292 1 1 1 2 1 3 1 14 2 1 1 2 2 2 2 1 84 2))
      (make-co-expression*
       (lambda ()
         (let loop ((terms pi-terms))
           (if (null? terms)
               (values (eof-object) (eof-object))
               (begin
                 (suspend 1 (car terms))
                 (loop (cdr terms))))))))

    ;; -------------------------------------------------------------
    ;; Gosper's homographic transform: (a*x + b) / (c*x + d)
    ;; Consumes terms from cf-in and emits terms of the transformed
    ;; continued fraction on demand.
    ;; -------------------------------------------------------------
    (define (cf-homographic a b c d cf-in)
      (make-co-expression*
       (lambda ()
         (let loop ((a a) (b b) (c c) (d d))
           (let ((emit? (and (not (zero? c))
                             (not (zero? d))
                             (= (floor-quotient a c)
                                (floor-quotient b d)))))
             (if emit?
                 (let ((q (floor-quotient a c)))
                   (suspend 1 q)
                   (loop c d (- a (* q c)) (- b (* q d))))
                 (call-with-values
                     (lambda () (cf-step cf-in))
                   (lambda (num . rest)
                     (if (or (eof-object? num) (null? rest) (eof-object? (car rest)))
                         (let flush ((a a) (c c))
                           (if (zero? c)
                               (values (eof-object) (eof-object))
                               (let ((q (floor-quotient a c)))
                                 (suspend 1 q)
                                 (flush c (- a (* q c))))))
                         (let ((den (car rest)))
                           (loop (+ (* a den) b) a
                                 (+ (* c den) d) c)))))))))))

    )) ;; end library
