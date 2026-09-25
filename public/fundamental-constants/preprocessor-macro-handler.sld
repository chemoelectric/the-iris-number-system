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

(define-library (preprocessor-macro-handler)

  (export macro-handler?
          make-macro-handler
          macro-handler-procedure)

  (export get-macro-handler
          set-macro-handler!
          push-macro-handler!
          pop-macro-handler!
          localize-macro-handlers)

  (export remove-macro-handlers!)

  (import (scheme base)
          (define-record-factory)
          (preprocessor-define-lookup))

  (begin

    (define-record-factory <macro-handler>

      (predicate> macro-handler?)

      (constructor>
       make-macro-handler
       (lambda (construct)
         (lambda (obj)
           (cond ((procedure? obj)
                  (construct obj))
                 ((macro-handler? obj)
                  (construct (macro-handler-procedure obj)))
                 (else
                  (error "expected a procedure or macro-handler"
                         obj))))))

      (getter> 1 macro-handler-procedure))

    (define-lookup *macro-handlers*
      get-macro-handler
      set-macro-handler!
      push-macro-handler!
      pop-macro-handler!
      localize-macro-handlers)

    (define (remove-macro-handlers! name)
      (let loop ()
        (when (get-macro-handler name)
          (pop-macro-handler! name))))

    ))

;;;---------------------------------------------------------------------
;;; local variables:
;;; mode: scheme
;;; coding: utf-8
;;; end:
