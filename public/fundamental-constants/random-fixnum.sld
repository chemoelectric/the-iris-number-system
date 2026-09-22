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

;;;---------------------------------------------------------------------
;;;
;;; A fixnum linear congruential generator with output mixing.
;;;
;;;---------------------------------------------------------------------

(define-library (random-fixnum)

  ;; Return a thunk that generates fixnums of high entropy.
  (export make-random-fixnum)

  ;; A wrapper to make random integers in ranges.
  (export make-random-integer)

  (import (scheme base))
  (import (scheme case-lambda))
  (import (scheme file))
  (cond-expand
    ((library (scheme fixnum)) (import (scheme fixnum)))
    ((library (srfi 143)) (import (srfi 143)))
    ;;;(loko (import (srfi :143 fixnums))) Loko is not supported.
    (else (import (srfi srfi-143))))

  (begin

    ;;------------------------------------------------------------------
    ;;
    ;; Get an initial seed.
    ;;

    ;; Reads a specific number of bytes and converts them to an
    ;; integer (by big-endian interpretation). Returns #f on a failed
    ;; attempt.
    (define (read-urandom-number byte-count)
      (call-with-port (open-binary-input-file "/dev/urandom")
        (lambda (port)
          (let ((bv (read-bytevector byte-count port)))
            (if (or (eof-object? bv)
                    (< (bytevector-length bv) byte-count))
              #f ;; Failed to get a result.
              (let loop ((i 0) (result 0))
                (if (= i byte-count)
                  result
                  (loop (+ i 1)
                        (+ (* result 256)
                           (bytevector-u8-ref bv i))))))))))

    (define fallback-initial-seed #x1439f46a0bd7)

    ;;
    ;; /dev/urandom integer in 0 .. n-1, or a fallback value.
    ;;
    (define (urandom-integer n)
      (let loop ((bytes-needed 1))
        (if (< (expt 256 bytes-needed) n)
          (loop (+ bytes-needed 1))
          (let ((urnd (read-urandom-number bytes-needed)))
            (if urnd
              (floor-remainder urnd n)
              fallback-initial-seed)))))

    ;;------------------------------------------------------------------

    ;; Truly safe 63-bit Mixer (No bignum allocation).
    ;; State and mask occupy exactly 63 bits: #x7FFFFFFFFFFFFFFF
    (define (mix-63 state)
      (let* ((x state)
             ;; Initial avalanche shift.
             (x (fxxor x (fxarithmetic-shift-right x 32)))
             
             ;; Split x into two chunks to fit within
             ;; multiplication thresholds.
             (low (fxand x #x7FFFFFFF))             ;; Low 31 bits
             (high (fxarithmetic-shift-right x 31)) ;; High 32 bits
             
             ;; Multiply both safely by a 31-bit multiplier
             ;; (1450549843). Max product fits safely inside a 63-bit
             ;; signed fixnum.
             (prod-low (fx* low 1450549843))
             (prod-high (fx* high 1450549843))
             
             ;; Mask prod-high to 32 bits BEFORE shifting left, to
             ;; guarantee the shift stays within the 63-bit hardware
             ;; threshold.
             (prod-high-masked (fxand prod-high #xFFFFFFFF))
             
             ;; Combine and apply the final 63-bit mask.
             (x (fxxor prod-low (fxarithmetic-shift-left
                                 prod-high-masked 31)))
             (x (fxand x #x7FFFFFFFFFFFFFFF))
             
             ;; Final avalanche shift.
             (x (fxxor x (fxarithmetic-shift-right x 29))))
        x))

    (define (make-random-fixnum-63 initial-seed)
      ;; Ensure the initial seed is masked to 63 bits
      (let ((state (fxand initial-seed #x7FFFFFFFFFFFFFFF)))
        (lambda ()
          ;; Split the 63-bit state to prevent LCG multiplication overflow
          (let* ((state-low (fxand state #x7FFFFFFF)) ;; Low 31 bits
                 (state-high (fxarithmetic-shift-right
                              state 31)) ;; High 32 bits
                 
                 ;; Multiply chunks by a spectrally tested 31-bit
                 ;; LCG multiplier 1323257245 (0x4EE4DEF5) satisfies
                 ;; Vigna's LCG spectral constraints.
                 (prod-low (fx* state-low 1323257245))
                 (prod-high (fx* state-high 1323257245))
                 
                 ;; Mask the high product to 32 bits BEFORE
                 ;; shifting left.
                 (prod-high-masked (fxand prod-high #xFFFFFFFF))
                 (shifted-high
                  (fxarithmetic-shift-left prod-high-masked 31))
                 
                 ;; Combine the pieces and add the LCG increment (+1).
                 ;;
                 ;; Intermediate steps are masked to stay strictly
                 ;; within 63 bits.
                 (next (fxand (fx+ prod-low shifted-high)
                              #x7FFFFFFFFFFFFFFF))
                 (next (fxand (fx+ next 1) #x7FFFFFFFFFFFFFFF)))
            
            (set! state next)
            ;; Output step: Scramble the clean 63-bit state.
            (mix-63 state)))))

    ;;------------------------------------------------------------------

    ;; Truly safe 62-bit Mixer (No bignum allocation).
    ;; State and mask occupy exactly 62 bits: #x3FFFFFFFFFFFFFFF
    (define (mix-62 state)
      (let* ((x state)
             ;; Initial avalanche shift.
             (x (fxxor x (fxarithmetic-shift-right x 31)))
             
             ;; Split x into two symmetric 31-bit chunks.
             (low (fxand x #x7FFFFFFF))             ;; Low 31 bits
             (high (fxarithmetic-shift-right x 31)) ;; High 31 bits
             
             ;; Multiply both safely by a 31-bit multiplier
             ;; (1450549843). Max product is exactly 62 bits, fitting
             ;; inside a 62-bit signed fixnum.
             (prod-low (fx* low 1450549843))
             (prod-high (fx* high 1450549843))
             
             ;; Mask prod-high to 31 bits BEFORE shifting left, to
             ;; guarantee the shift stays within the 62-bit hardware
             ;; threshold.
             (prod-high-masked (fxand prod-high #x7FFFFFFF))
             
             ;; Combine and apply the final 62-bit mask.
             (x (fxxor prod-low (fxarithmetic-shift-left
                                 prod-high-masked 31)))
             (x (fxand x #x3FFFFFFFFFFFFFFF))
             
             ;; Final avalanche shift.
             (x (fxxor x (fxarithmetic-shift-right x 28))))
        x))

    (define (make-random-fixnum-62 initial-seed)
      ;; Ensure the initial seed is masked to 62 bits
      (let ((state (fxand initial-seed #x3FFFFFFFFFFFFFFF)))
        (lambda ()
          ;; Split the 62-bit state into symmetric 31-bit chunks
          (let* ((state-low (fxand state #x7FFFFFFF)) ;; Low 31 bits
                 (state-high (fxarithmetic-shift-right
                              state 31)) ;; High 31 bits
                 
                 ;; Multiply chunks by a spectrally tested 31-bit
                 ;; LCG multiplier 1323257245 (0x4EE4DEF5) satisfies
                 ;; Vigna's LCG spectral constraints.
                 (prod-low (fx* state-low 1323257245))
                 (prod-high (fx* state-high 1323257245))
                 
                 ;; Mask the high product to 31 bits BEFORE
                 ;; shifting left.
                 (prod-high-masked (fxand prod-high #x7FFFFFFF))
                 (shifted-high (fxarithmetic-shift-left
                                prod-high-masked 31))
                 
                 ;; Combine the pieces and add the LCG increment
                 ;;    (+1).
                 ;;
                 ;; Intermediate steps are masked to stay strictly
                 ;; within 62 bits.
                 (next (fxand (fx+ prod-low shifted-high)
                              #x3FFFFFFFFFFFFFFF))
                 (next (fxand (fx+ next 1) #x3FFFFFFFFFFFFFFF)))
            
            (set! state next)
            ;; Output step: Scramble the clean 62-bit state.
            (mix-62 state)))))

    ;;------------------------------------------------------------------

    ;; 61-bit Mixer (safe from 61-bit overflow).
    ;; State and mask occupy exactly 61 bits: #x1FFFFFFFFFFFFFFF
    (define (mix-61 state)
      (let* ((x state)
             ;; Initial avalanche shift.
             (x (fxxor x (fxarithmetic-shift-right x 30)))
             
             ;; Split x into two chunks to fit within
             ;; multiplication thresholds.
             (low (fxand x #x3FFFFFFF))             ;; Low 30 bits
             (high (fxarithmetic-shift-right x 30)) ;; High 31 bits
             
             ;; Multiply both safely by a 30-bit multiplier Max
             ;; product is ~60 bits, which is safe inside a 61-bit
             ;; fixnum.
             (prod-low (fx* low 913728083))
             (prod-high (fx* high 913728083))
             
             ;; Mask prod-high to 31 bits BEFORE shifting left, to
             ;; guarantee the shift stays within the 61-bit hardware
             ;; threshold.
             (prod-high-masked (fxand prod-high #x7FFFFFFF))
             
             ;; Combine and apply the final 61-bit mask
             (x (fxxor prod-low (fxarithmetic-shift-left
                                 prod-high-masked 30)))
             (x (fxand x #x1FFFFFFFFFFFFFFF))
             
             ;; Final avalanche shift.
             (x (fxxor x (fxarithmetic-shift-right x 27))))
        x))

    (define (make-random-fixnum-61 initial-seed)
      (let ((state (fxand initial-seed #x1FFFFFFFFFFFFFFF)))
        (lambda ()
          ;; Split the 61-bit state to prevent LCG multiplication
          ;; overflow.
          (let* ((state-low (fxand state #x3FFFFFFF)) ;; Low 30 bits
                 (state-high (fxarithmetic-shift-right
                              state 30)) ;; High 31 bits
                 
                 ;; Multiply chunks by the 30-bit LCG multiplier
                 ;; (1015182917) Individual products are max ~60 bits
                 ;; (safe under 61 bits).
                 (prod-low (fx* state-low 1015182917))
                 (prod-high (fx* state-high 1015182917))
                 
                 ;; Mask the high product to 31 bits BEFORE shifting
                 ;; left.
                 (prod-high-masked (fxand prod-high #x7FFFFFFF))
                 (shifted-high (fxarithmetic-shift-left
                                prod-high-masked 30))
                 
                 ;; Combine the pieces and add the LCG increment (+1).
                 ;;
                 ;; We mask intermediate additions to stay within 61
                 ;; bits.
                 (next (fxand (fx+ prod-low shifted-high)
                              #x1FFFFFFFFFFFFFFF))
                 (next (fxand (fx+ next 1) #x1FFFFFFFFFFFFFFF)))
            
            (set! state next)
            ;; Output step: Scramble the clean 61-bit state.
            (mix-61 state)))))

    ;;------------------------------------------------------------------

    (define make-random-fixnum-aux
      (case fx-greatest
        ((#x7FFFFFFFFFFFFFFF) make-random-fixnum-63)
        ((#x3FFFFFFFFFFFFFFF) make-random-fixnum-62)
        ((#x1FFFFFFFFFFFFFFF) make-random-fixnum-61)
        (else (error "This implementation requires fixnum size \
                      61, 62, or 63."))))

    (define make-random-fixnum
      (case-lambda
        ((initial-seed)
         (make-random-fixnum-aux initial-seed))
        (()
         (make-random-fixnum-aux (urandom-integer (+ 1 fx-greatest))))))

    (define (make-random-integer random-fixnum)
      (let* ((divisor (+ fx-greatest 1))
             (randnum
              (lambda (n)
                (unless (and (integer? n) (positive? n))
                  (error "expected a positive integer" n))
                (floor (* (/ (random-fixnum) divisor) n)))))
        (case-lambda
          ((n) ;; n numbers, starting at 0.
           (randnum n))
          ((i n) ;; n numbers, starting at i.
           (+ i (randnum n))))))

    ))

;;;---------------------------------------------------------------------
;;; local variables:
;;; mode: scheme
;;; coding: utf-8
;;; end:
