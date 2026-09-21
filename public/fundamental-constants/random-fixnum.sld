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

;;;
;;; A 62-bit linear congruential generator with output mixing.
;;;

(define-library (random-fixnum)

  ;; Return a thunk that generates 62-bit integers of high entropy.
  (export make-random-fixnum)

  ;; A wrapper to make random integers in ranges.
  (export make-random-integer)

  (import (scheme base))
  (import (scheme case-lambda))
  (cond-expand
    ((library (scheme fixnum)) (import (scheme fixnum)))
    ((library (srfi 143)) (import (srfi 143)))
    (loko (import (srfi :143 fixnums)))
    (else (import (srfi srfi-143))))

  (begin
    ;; 62-bit Mixer (safe from 62-bit overflow).
    (define (mix-62 state)
      (let* ((x state)
             ;; x := x xor (x >> 30)
             (x (fxxor x (fxarithmetic-shift-right x 30)))
             ;; x := (x * 0x2545F491) & mask (Safe 31-bit multiplier)
             (x (fxand (fx* x 625341585) #x3FFFFFFFFFFFFFFF))
             ;; x := x xor (x >> 27)
             (x (fxxor x (fxarithmetic-shift-right x 27))))
        x))

    (define (make-random-fixnum initial-seed)
      (let ((state initial-seed))
        (lambda ()
          ;; Transition step (Steele-Vigna 62-bit parameters).
          (let* ((mult (fx* 3037000493 state))
                 (next (fx+ mult 1)))
            (set! state (fxand next #x3FFFFFFFFFFFFFFF))
            ;; Output step: Scramble the state.
            (mix-62 state)))))

    (define (make-random-integer random-fixnum)
      (let* ((two**62 (expt 2 62))
             (randnum
              (lambda (n)
                (unless (and (integer? n) (positive? n))
                  (error "expected a positive integer" n))
                (floor (* (/ (random-fixnum) two**62) n)))))
        (case-lambda
          ((n) ;; n numbers, starting at 0.
           (randnum n))
          ((i n) ;; n numbers, starting at i.
           (+ i (randnum n))))))

    ))
