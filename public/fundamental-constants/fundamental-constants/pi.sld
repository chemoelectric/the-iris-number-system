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

(define-library (fundamental-constants pi)

  (import (scheme base)
          (fundamental-constants co-expression)
          (fundamental-constants continued-fraction))

  (export
   ;; Term lists (OEIS A001203 and A013679)
   pi-terms
   π-terms
   pi^2/6-terms
   pi-sq/6-terms
   π²/6-terms

   ;; Core pi continued fractions (ASCII and Unicode NFC)
   cf:pi
   cf:π
   cf:pi-simple
   cf:π-simple
   cf:pi-brouncker

   ;; Trigonometric fraction continued fractions: pi/2, pi/3, pi/4, pi/6
   cf:pi/2
   cf:π/2
   cf:pi/2-stern
   cf:π/2-stern

   cf:pi/3
   cf:π/3

   cf:pi/4
   cf:π/4
   cf:pi/4-euler
   cf:π/4-euler

   cf:pi/6
   cf:π/6

   ;; Reciprocal and inverse fraction continued fractions: 1/pi, 2/pi, 3/pi, 4/pi, 6/pi
   ;; Note: Standard Scheme identifiers cannot start with a digit.
   ;; Names starting with "cf:" are valid; alternate word names (one/pi, two/pi, etc.)
   ;; are also provided to ensure universal Scheme portability.
   cf:1/pi
   cf:one/pi
   cf:inv-pi
   cf:1/π
   cf:one/π
   cf:inv-π

   cf:2/pi
   cf:two/pi
   cf:2/π
   cf:two/π

   cf:3/pi
   cf:three/pi
   cf:3/π
   cf:three/π

   cf:4/pi
   cf:four/pi
   cf:four/pi-brouncker
   cf:4/pi-brouncker
   cf:4/π
   cf:four/π
   cf:four/π-brouncker
   cf:4/π-brouncker

   cf:6/pi
   cf:six/pi
   cf:6/π
   cf:six/π

   ;; Basel problem constant pi^2/6 = zeta(2) and coprime probability 6/pi^2 = 1/zeta(2)
   cf:pi^2/6
   cf:pi-sq/6
   cf:π²/6
   cf:π^2/6

   cf:6/pi^2
   cf:six/pi^2
   cf:six-over-pi-sq
   cf:6/π²
   cf:six/π²
   cf:six-over-π²
   )

  (begin

    ;; -------------------------------------------------------------
    ;; Exact Simple Continued Fraction Terms for pi (OEIS A001203)
    ;; -------------------------------------------------------------
    (define pi-terms
      '(3 7 15 1 292 1 1 1 2 1 3 1 14 2 1 1 2 2 2 2 1 84 2
        1 1 15 3 13 1 4 2 6 6 99 1 2 2 6 3 5 1 1 6 8 1 7 1
        2 3 7 1 2 1 1 12 1 1 1 3 1 1 8 1 1 2 1 6 1 1 5 2 2
        3 1 2 4 4 16 1 161 45 1 22 1 2 2 1 4 1 2 24 1 2 1
        3 1 2 1 1 10 2 5 4 1 2 2 8 1 5 2 2 26 1 4 1 1 8 2 42 2))

    (define π-terms pi-terms)

    ;; Simple continued fraction generator for pi.
    (define (cf:pi)
      (make-co-expression*
       (lambda ()
         (let loop ((terms pi-terms))
           (if (null? terms)
               (values (eof-object) (eof-object))
               (begin
                 (suspend 1 (car terms))
                 (loop (cdr terms))))))))

    (define cf:π cf:pi)
    (define cf:pi-simple cf:pi)
    (define cf:π-simple cf:pi)

    ;; -------------------------------------------------------------
    ;; Fractions Common in Trigonometry: pi/2, pi/3, pi/4, pi/6
    ;; Derived via Gosper homographic transform: (1*pi + 0)/(0*pi + k)
    ;; -------------------------------------------------------------
    (define (cf:pi/2)
      (cf-homographic 1 0 0 2 (cf:pi)))
    (define cf:π/2 cf:pi/2)

    (define (cf:pi/3)
      (cf-homographic 1 0 0 3 (cf:pi)))
    (define cf:π/3 cf:pi/3)

    (define (cf:pi/4)
      (cf-homographic 1 0 0 4 (cf:pi)))
    (define cf:π/4 cf:pi/4)

    (define (cf:pi/6)
      (cf-homographic 1 0 0 6 (cf:pi)))
    (define cf:π/6 cf:pi/6)

    ;; -------------------------------------------------------------
    ;; Inverses: 1/pi, 2/pi, 3/pi, 4/pi, 6/pi
    ;; Derived via Gosper homographic transform: (0*pi + k)/(1*pi + 0)
    ;; -------------------------------------------------------------
    (define (cf:1/pi)
      (cf-homographic 0 1 1 0 (cf:pi)))
    (define cf:one/pi cf:1/pi)
    (define cf:inv-pi cf:1/pi)
    (define cf:1/π cf:1/pi)
    (define cf:one/π cf:1/pi)
    (define cf:inv-π cf:1/pi)

    (define (cf:2/pi)
      (cf-homographic 0 2 1 0 (cf:pi)))
    (define cf:two/pi cf:2/pi)
    (define cf:2/π cf:2/pi)
    (define cf:two/π cf:2/pi)

    (define (cf:3/pi)
      (cf-homographic 0 3 1 0 (cf:pi)))
    (define cf:three/pi cf:3/pi)
    (define cf:3/π cf:3/pi)
    (define cf:three/π cf:3/pi)

    (define (cf:4/pi)
      (cf-homographic 0 4 1 0 (cf:pi)))
    (define cf:four/pi cf:4/pi)
    (define cf:4/π cf:4/pi)
    (define cf:four/π cf:4/pi)

    (define (cf:6/pi)
      (cf-homographic 0 6 1 0 (cf:pi)))
    (define cf:six/pi cf:6/pi)
    (define cf:6/π cf:6/pi)
    (define cf:six/π cf:6/pi)

    ;; -------------------------------------------------------------
    ;; Basel Problem Constant: pi^2/6 = zeta(2) (OEIS A013679)
    ;; -------------------------------------------------------------
    (define pi^2/6-terms
      '(1 1 1 1 4 2 4 7 1 4 2 3 4 10 1 2 1 1 1 15 1 3 6 1 1 2 1 1 1 2
        2 3 1 3 1 1 5 1 2 2 1 1 6 27 20 3 97 105 1 1 1 1 1 45 2 8 19 1
        4 1 1 3 1 2 1 1 1 5 1 1 2 3 6 1 1 1 2 1 5 1 1 2 9 5 3 2 1 1 1
        15 44 1 2 1 1 1 1 3 1 2 1 1 2 1 6 1 11 1 2 1 13 7 2 6 58 10 2 5 1 1))

    (define pi-sq/6-terms pi^2/6-terms)
    (define π²/6-terms pi^2/6-terms)

    (define (cf:pi^2/6)
      (make-co-expression*
       (lambda ()
         (let loop ((terms pi^2/6-terms))
           (if (null? terms)
               (values (eof-object) (eof-object))
               (begin
                 (suspend 1 (car terms))
                 (loop (cdr terms))))))))

    (define cf:pi-sq/6 cf:pi^2/6)
    (define cf:π²/6 cf:pi^2/6)
    (define cf:π^2/6 cf:pi^2/6)

    ;; -------------------------------------------------------------
    ;; Coprime Probability: 6/pi^2 = 1/zeta(2) (OEIS A059956)
    ;; Inversion of pi^2/6 via homographic transform (0*x + 1)/(1*x + 0)
    ;; -------------------------------------------------------------
    (define (cf:6/pi^2)
      (cf-homographic 0 1 1 0 (cf:pi^2/6)))

    (define cf:six/pi^2 cf:6/pi^2)
    (define cf:six-over-pi-sq cf:6/pi^2)
    (define cf:6/π² cf:6/pi^2)
    (define cf:six/π² cf:6/pi^2)
    (define cf:six-over-π² cf:6/pi^2)

    ;; -------------------------------------------------------------
    ;; Generalized Continued Fractions (Infinite Generators)
    ;; -------------------------------------------------------------

    ;; Euler's generalized continued fraction for pi/4:
    ;; pi/4 = 1 / (1 + 1^2 / (3 + 2^2 / (5 + 3^2 / (7 + ...))))
    (define (cf:pi/4-euler)
      (make-co-expression*
       (lambda ()
         (suspend 1 0)
         (suspend 1 1)
         (let loop ((k 1))
           (let ((k-sq (* k k))
                 (den (+ (* 2 k) 1)))
             (suspend k-sq den)
             (loop (+ k 1)))))))

    (define cf:π/4-euler cf:pi/4-euler)

    ;; Lord Brouncker's generalized continued fraction for 4/pi:
    ;; 4/pi = 1 + 1^2 / (2 + 3^2 / (2 + 5^2 / (2 + ...)))
    (define (cf:four/pi-brouncker)
      (make-co-expression*
       (lambda ()
         (suspend 1 1)
         (let loop ((k 1))
           (let* ((odd (- (* 2 k) 1))
                  (odd-sq (* odd odd)))
             (suspend odd-sq 2)
             (loop (+ k 1)))))))

    (define cf:4/pi-brouncker cf:four/pi-brouncker)
    (define cf:four/π-brouncker cf:four/pi-brouncker)
    (define cf:4/π-brouncker cf:four/pi-brouncker)

    ;; Stern's generalized continued fraction for pi/2:
    ;; pi/2 = 1 + 1 / (1 + (1*2)/(1 + (2*3)/(1 + (3*4)/(1 + ...))))
    (define (cf:pi/2-stern)
      (make-co-expression*
       (lambda ()
         (suspend 1 1)
         (suspend 1 1)
         (let loop ((k 1))
           (let ((num (* k (+ k 1))))
             (suspend num 1)
             (loop (+ k 1)))))))

    (define cf:π/2-stern cf:pi/2-stern)

    )) ;; end library
