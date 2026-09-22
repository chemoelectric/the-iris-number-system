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
;;;
;;; An implementation of variables for the preprocessor.
;;;
;;; This implementation has to be in a library, so it can be imported
;;; into an (eval) environment.
;;;
;;;
;;;---------------------------------------------------------------------

(define-library (preprocessor-variables)

  (export :=)

  (export $a)
  (export $b)
  (export $c)
  (export $d)
  (export $e)
  (export $f)
  (export $g)
  (export $h)
  (export $i)
  (export $j)
  (export $k)
  (export $l)
  (export $m)
  (export $n)
  (export $o)
  (export $p)
  (export $q)
  (export $r)
  (export $s)
  (export $t)
  (export $u)
  (export $v)
  (export $w)
  (export $x)
  (export $y)
  (export $z)

  (export $A)
  (export $B)
  (export $C)
  (export $D)
  (export $E)
  (export $F)
  (export $G)
  (export $H)
  (export $I)
  (export $J)
  (export $K)
  (export $L)
  (export $M)
  (export $N)
  (export $O)
  (export $P)
  (export $Q)
  (export $R)
  (export $S)
  (export $T)
  (export $U)
  (export $V)
  (export $W)
  (export $X)
  (export $Y)
  (export $Z)

  (import (scheme base)
          (scheme case-lambda))

  (begin

    (define := '#(unique-object))

    (define-syntax define-prepvar
      (syntax-rules ()
        ((¶ name)
         (define name
           ;; The storage has to be mutable while leaving the
           ;; environment immutable.
           (let ((p (list #f)))
             (case-lambda
               (() (car p))
               ((symb value)
                (unless (eq? symb :=)
                  (error "expected the unique object :=" symb))
                (set-car! p value))))))))

    (define-prepvar $a)
    (define-prepvar $b)
    (define-prepvar $c)
    (define-prepvar $d)
    (define-prepvar $e)
    (define-prepvar $f)
    (define-prepvar $g)
    (define-prepvar $h)
    (define-prepvar $i)
    (define-prepvar $j)
    (define-prepvar $k)
    (define-prepvar $l)
    (define-prepvar $m)
    (define-prepvar $n)
    (define-prepvar $o)
    (define-prepvar $p)
    (define-prepvar $q)
    (define-prepvar $r)
    (define-prepvar $s)
    (define-prepvar $t)
    (define-prepvar $u)
    (define-prepvar $v)
    (define-prepvar $w)
    (define-prepvar $x)
    (define-prepvar $y)
    (define-prepvar $z)

    (define-prepvar $A)
    (define-prepvar $B)
    (define-prepvar $C)
    (define-prepvar $D)
    (define-prepvar $E)
    (define-prepvar $F)
    (define-prepvar $G)
    (define-prepvar $H)
    (define-prepvar $I)
    (define-prepvar $J)
    (define-prepvar $K)
    (define-prepvar $L)
    (define-prepvar $M)
    (define-prepvar $N)
    (define-prepvar $O)
    (define-prepvar $P)
    (define-prepvar $Q)
    (define-prepvar $R)
    (define-prepvar $S)
    (define-prepvar $T)
    (define-prepvar $U)
    (define-prepvar $V)
    (define-prepvar $W)
    (define-prepvar $X)
    (define-prepvar $Y)
    (define-prepvar $Z)

    ))

;;;---------------------------------------------------------------------
;;; local variables:
;;; mode: scheme
;;; coding: utf-8
;;; end:
