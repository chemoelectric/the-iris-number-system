#!/usr/bin/env -S csi -s

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

(import (scheme base)
        (scheme file)
        (scheme read)
        (scheme write)
        (scheme process-context)
        (scheme eval))
(cond-expand
  ((library (scheme list)) (import (scheme list)))
  ((library (srfi 1)) (import (srfi 1)))
  (loko (import (srfi :1 lists)))
  (else (import (srfi srfi-1))))
(cond-expand
  ((library (scheme charset)) (import (scheme charset)))
  ((library (srfi 14)) (import (srfi 14)))
  (loko (import (srfi :14 char-sets)))
  (else (import (srfi srfi-14))))

(include "snobol-match.sld")
(include "snobol-char-set.sld")
(import (snobol-match)
        (snobol-char-set))

;;;---------------------------------------------------------------------

(define *environment*
  (make-parameter
   (environment
    '(scheme base)
    '(scheme char)
    '(scheme case-lambda)
    '(scheme file)
    '(scheme read)
    '(scheme write)
    '(scheme inexact)
    '(scheme complex)
    (cond-expand
      ((library (scheme list)) '(scheme list))
      ((library (srfi 1)) '(srfi 1))
      (loko '(srfi :1 lists))
      (else '(srfi srfi-1)))
    (cond-expand
      ((library (scheme charset)) '(scheme charset))
      ((library (srfi 14)) '(srfi 14))
      (loko '(srfi :14 char-sets))
      (else '(srfi srfi-14)))
    '(snobol-match)
    '(snobol-char-set))))

(define (eval-string str env)
  (eval (read (open-input-string str)) env))

(define (evaluate str)
  (eval-string (string-append "(values " str " )")
               (*environment*)))

(define (serialize-to-string obj)
  (let ((port (open-output-string)))
    (write obj port)
    (get-output-string port)))

(define (getvar key match-result)
  (and match-result
       (let ((p (assoc key (cdr match-result))))
         (and p (cdr p)))))

(define (remove-prefix prefix str)
  (let ((m (string-length prefix))
        (n (string-length str)))
    (if (<= n m)
      ""
      (string-copy str m))))

;;;---------------------------------------------------------------------

(define *quick-pattern*
  (make-parameter
   (p:assign-local (p:break "(;") 'snippet)))

(define char-set:macro-name
  (char-set-difference char-set:graphic
                       (string->char-set "()[]{};|'`,@\"\\")))

(define *macro-pattern*
  (make-parameter
   (p:assign-local
    (p:seq (p:lit "(")
           (p:maybe-many (p:span-char-set char-set:whitespace))
           (p:lit "@@@")
           (p:span-char-set char-set:whitespace)
           (p:assign-local (p:span-char-set char-set:macro-name)
                           'macro-name)
           (p:maybe-many (p:span-char-set char-set:whitespace))
           (p:assign-local
            (p:maybe-many
             (p:seq (p:bal)
                    (p:maybe-many
                     (p:span-char-set char-set:whitespace))))
            'macro-body)
           (p:lit ")"))
    'macro-call)))

(define *line-comment-pattern*
  (make-parameter
   (p:assign-local (p:seq
                    (p:lit ";")
                    (p:break "\n")
                    (p:lit "\n"))
                   'comment)))

;;;---------------------------------------------------------------------

(define-syntax define-lookup
  (syntax-rules ()
    ((¶ *things*
        getter setter! popper!
        localizer)
     (begin
       (define *things* (make-parameter (list (list '()))))
       (define (getter name)
         (let ((p (*things*)))
           (let ((association (assoc name (caar p))))
             (if association
               (cdr association)
               #f))))
       (define (setter! name handler)
         (let ((p (*things*)))
           ;;
           ;; This is not a “true” association list, but rather a
           ;; stack.
           ;;
           (let (;;(lst (alist-delete! name (caar p)))
                 (lst (caar p))
                 (association (cons name handler)))
             (set-car! (car p) (cons association lst)))))
       (define (popper! name)
         (let ((p (*things*)))
           ;;
           ;; Pop the first instance of name.
           ;;
           (let-values (((a b) (break! (lambda (p)
                                         (equal? name (car p)))
                                       (caar p))))
             (let ((b (if (pair? b) (cdr b) b)))
               (set-car! (car p) (append a b))))))
       (define-syntax localizer
         (syntax-rules ooo ()
           ((ß body ooo)
            (parameterize
                ((*things*
                  (list (map (lambda (p) (cons (car p) (cdr p)))
                             (caar (*things*))))))
              (begin
                (if #f #f)
                body ooo)))))))))

(define-lookup *macros*
  get-macro-handler
  set-macro-handler!
  pop-macro!
  localize-macros)

;;;---------------------------------------------------------------------

(define (process-text text)
  (define t (string-copy text))

  (define (remove-t-prefix! prefix)
    (set! t (remove-prefix prefix t)))

  ;;----------------------------------------------------
  ;; (@@@ dnl)
  ;;
  ;; Delete up through the next newline.
  ;;

  (define dnl-handler
    (let ((pattern (p:seq (p:alt (p:seq (p:break "\n") (p:lit "\n"))
                                 (p:lit "\n"))
                          (p:cursor 'cursor))))
      (lambda (macro-call macro-name macro-body)
        (let ((match-result (snobol-match pattern t)))
          (when match-result
            (let ((n (string->number (getvar 'cursor match-result))))
              (set! t (string-copy t n))))
          ""))))
  (set-macro-handler! "dnl" dnl-handler)

  ;;----------------------------------------------------
  ;; (@@@ include-raw FORM)
  ;;
  ;; Non-recursive include of the file specified by the FORM.
  ;;
  (define (include-raw-handler macro-call macro-name macro-body)
    (let-values (((filename) (evaluate macro-body)))
      (with-input-from-file filename
        (lambda () (read-string #f)))))
  (set-macro-handler! "include-raw" include-raw-handler)

  ;;----------------------------------------------------
  ;; (@@@ include FORM)
  ;;
  ;; Recursive include of the file specified by the FORM.
  ;;
  (define (include-handler macro-call macro-name macro-body)
    (let-values (((filename) (evaluate macro-body)))
      (with-input-from-file filename
        (lambda ()
          (set! t (string-append (read-string #f) t))
          ""))))
  (set-macro-handler! "include" include-handler)

  ;;----------------------------------------------------
  ;; (@@@ define MACRO-NAME MACRO-BODY)
  ;;
  ;; Define a macro with the name given by the form MACRO-NAME and
  ;; definition by the form MACRO-BODY, which (in the current
  ;; implementation) must evaluate to a string. When a macro call is
  ;; made, MACRO-BODY is inserted and then evaluated recursively
  ;;
  (define (definition-handler macro-call macro-name macro-body)
    (let-values (((name body) (evaluate macro-body)))
      (unless (string? name)
        (error "macro name must be a be a string" name))
      (unless (string? body)
        (error "macro body must be a be a string" body))
      (set-macro-handler!
       name
       (lambda (mac-call mac-name mac-body)
         (let-values ((vals (evaluate mac-body)))
           (let ((n (length vals)))
             (do ((i 1 (+ i 1)))
                 ((= i (+ n 1)))
               (set! t (string-append
                        "(@@@ popdef \"" (number->string i) "\")"
                        t)))
             (set! t (string-append body t))
             (do ((i 1 (+ i 1))
                  (p vals (cdr p)))
                 ((= i (+ n 1)))
               (set! t (string-append
                        "(@@@ define \"" (number->string i) "\" "
                        (serialize-to-string (car p)) ")"
                        t)))))
         ""))
      ""))
  (set-macro-handler! "define" definition-handler)

  ;;----------------------------------------------------
  ;; (@@@ popdef MACRO-NAME)
  ;;
  ;; Pop a definition.
  ;;

  (define (popdef-handler macro-call macro-name macro-body)
    (let-values (((name) (evaluate macro-body)))
      (unless (string? name)
        (error "macro name must be a be a string" name))
      (pop-macro! name)
      ""))
  (set-macro-handler! "popdef" popdef-handler)

  ;;----------------------------------------------------

  (define (handle-quick-result match-result)
    (let ((snippet (getvar 'snippet match-result)))
      (remove-t-prefix! snippet)
      snippet))

  (define (handle-macro-call match-result)
    (let ((macro-call (getvar 'macro-call match-result))
          (macro-name (getvar 'macro-name match-result))
          (macro-body (getvar 'macro-body match-result)))
      (remove-t-prefix! macro-call)
      (let ((macro-handler (get-macro-handler macro-name)))
        (if (not macro-handler)
          macro-call
          (macro-handler macro-call macro-name macro-body)))))

  (define (handle-line-comment match-result)
    (let ((comment (getvar 'comment match-result)))
      (remove-t-prefix! comment)
      comment))

  (let loop ((s '()))
    (cond ((and (pair? s) (string=? (car s) ""))
           (loop (cdr s)))
          ((= 0 (string-length t))
           (reverse! s))
          ((snobol-match (*quick-pattern*) t) =>
           (lambda (match-result)
             (let ((quick-result
                    (handle-quick-result match-result)))
               (loop (cons quick-result s)))))
          ((snobol-match (*macro-pattern*) t) =>
           (lambda (match-result)
             (let ((macro-call-result
                    (handle-macro-call match-result)))
               (loop (cons macro-call-result s)))))
          ((snobol-match (*line-comment-pattern*) t) =>
           (lambda (match-result)
             (let ((line-comment
                    (handle-line-comment match-result)))
               (loop (cons line-comment s)))))
          (else
           (let ((c (string-copy t 0 1)))
             (set! t (string-copy t 1))
             (loop (cons c s)))) )))

(define (run-the-program input-file output-file)
  (let ((use-stdin? (string=? input-file "-"))
        (use-stdout? (string=? output-file "-")))
    (let ((input-port (if use-stdin?
                        (current-input-port)
                        (open-input-file input-file)))
          (output-port (if use-stdout?
                         (current-output-port)
                         (open-output-file output-file))))
      (let* ((text (read-string #f input-port))
             (lst (process-text text)))
        (for-each (lambda (s) (display s output-port))
                  lst))
      (unless use-stdin?
        (close-input-port input-port))
      (unless use-stdout?
        (close-output-port output-port)))))

;;;---------------------------------------------------------------------

(define (exception-handler err)
  (let ((port (current-error-port)))
    (display "Error: " port)
    (cond ((error-object? err)
           (display (error-object-message err) port)
           (let ((irritants (error-object-irritants err)))
             (unless (null? irritants)
               (display ": " port)
               (write irritants port))))
          ((string? err)
           (display err port))
          (else
           (write err port)))
    (newline port)
    (exit 2)))

(define (usage-handler args)
  (let ((port (current-output-port)))
    (display "Usage: " port)
    (display (first args) port)
    (display " [INFILE|-] [OUTFILE|-]" port)
    (newline port)
    (exit 1)))

;;(guard (exc (else (exception-handler exc)))
(let ((args (command-line)))
  (case (length args)
    ((1) (run-the-program "-" "-"))
    ((2) (run-the-program (second args) "-"))
    ((3) (run-the-program (second args) (third args)))
    (else (usage-handler args))))
;;)

;;;---------------------------------------------------------------------
