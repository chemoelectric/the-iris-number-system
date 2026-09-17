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

(define-library (fundamental-constants co-expression)

  (import (scheme base))

  (export make-co-expression
          suspend)

  (begin

    (define identity* (lambda ψ* (apply values ψ*)))

    (define *suspend*
      (make-parameter identity*))

    (define (suspend . ψ*)
      (apply (*suspend*) ψ*))

    (define (make-co-expression thunk)
      (letrec
          ((resumption-point
            (lambda (κ . ξ*)
              (let ((what-suspend-runs
                     (lambda ψ*
                       (let-values
                           (((κ₁ . ξ₁*)
                             (call/cc
                              (lambda (λ)
                                (set! resumption-point λ)
                                (let-values ((α* (apply κ ψ*)))
                                  (values (append α* ξ*)))))))
                         (set! κ κ₁)
                         (apply values ξ₁*)))))
              (parameterize ((*suspend* what-suspend-runs))
                ;; When thunk terminates, its return value(s) are
                ;; automatically yielded via suspend. In functional
                ;; Scheme, the thunk returns its final value (such as
                ;; (eof-object) to signal normal exhaustion).
                (call-with-values thunk suspend)
                ;; Subsequent invocations after exhaustion yield
                ;; (eof-object) indefinitely:
                (let loop ()
                  (suspend (eof-object))
                  (loop)))))))
        (lambda ξ*
          (call/cc
           (lambda (κ)
             (apply resumption-point (cons κ ξ*)))))))

    )) ;; end library
