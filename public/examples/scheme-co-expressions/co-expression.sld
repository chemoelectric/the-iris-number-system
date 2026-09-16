(define-library (co-expression)

  (import (scheme base))

  (export make-co-expression
          suspend)

  (begin

    (define identity* (lambda ψ* (apply values ψ*)))

    (define *suspend*
      (make-parameter (vector identity*)))

    (define (set-*suspend*! x)
      (vector-set! (*suspend*) 0 x))

    (define (ref-*suspend*)
      (vector-ref (*suspend*) 0))

    (define (suspend . ψ*)
      (apply (ref-*suspend*) ψ*))

    (define (make-co-expression thunk)
      (parameterize ((*suspend* (vector identity*)))
        (letrec
            ((resumption-point
              (lambda (κ . ξ*)
                (set-*suspend*!
                 (lambda ψ*
                   (let-values
                       (((κ₁ . ξ₁*)
                         (call/cc
                          (lambda (λ)
                            (set! resumption-point λ)
                            (let-values ((α* (apply κ ψ*)))
                              (values (append α* ξ*)))))))
                     (set! κ κ₁)
                     (apply values ξ₁*))))
                (call-with-values thunk suspend)
                (let loop ()
                  (suspend (eof-object))
                  (loop)))))
          (lambda ξ*
            (call/cc
             (lambda (κ)
               (apply resumption-point (cons κ ξ*))))))))

    )) ;; end library
