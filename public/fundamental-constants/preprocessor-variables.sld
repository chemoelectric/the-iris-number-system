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

(define-library (preprocessor-variables)

  (export v@ v!) ;; get and set, respectively.
  (export a@)

  (import (scheme base)
          (scheme case-lambda))
  (cond-expand
    ((library (scheme list)) (import (scheme list)))
    ((library (srfi 1)) (import (srfi 1)))
    (loko (import (srfi :1 lists)))
    (else (import (srfi srfi-1))))

  (import (scheme write));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (begin

    (define *preprocessor-variables*
      (make-parameter (vector (list))))

    (define (canonicalize-var procname var)
      (cond
        ((symbol? var) var)
        ((string? var) (string->symbol var))
        (else (error (string-append
                      "(" procname ") expected symbol or string")
                     var))))

    (define (v@ var)
      (let ((var (canonicalize-var "v@" var))
            (vec (*preprocessor-variables*)))
        (let ((pair (assq var (vector-ref vec 0))))
          (and pair (cdr pair)))))

    (define (v! var value)
      (let ((var (canonicalize-var "v!" var))
            (vec (*preprocessor-variables*)))
        (let ((pair (assq var (vector-ref vec 0))))
          (if pair
            (set-cdr! pair value)
            (vector-set! vec 0 (cons (cons var value)
                                     (vector-ref vec 0)))))))

    (define a@
      (let ((value #f))
        (case-lambda
          (() value)
          ((v) (set! value v)))))

    ))
