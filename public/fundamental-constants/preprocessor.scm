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
  (eval-string (string-append "(values " str ")")
               (*environment*)))

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

;;
;; (@@@ define MACRO-NAME FORM)
;;
;;;(define (handle-define arg*)
;;;  (unless (= 2 (length arg*))
;;;    (error "(@@@ define MACRO-NAME FORM) takes two arguments, not: "
;;;           arg*))
;;;  (let ((macro-name (first arg*))
;;;        (form (second arg*)))
;;;    (macro-set! macro-name form)))

;;
;; (@@@ ifdef MACRO-NAME T-FORM F-FORM)
;;
'FIXME

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
           (p:span-char-set char-set:whitespace)
           (p:assign-local
            (p:many (p:seq (p:bal)
                           (p:maybe-many
                            (p:span-char-set char-set:whitespace))))
            'macro-body)
           (p:lit ")"))
    'macro-call)))

(define *line-comment-pattern*
  (make-parameter
   (p:assign-local (p:seq
                    (p:lit ";")
                    (p:maybe-many (p:notany "\n"))
                    (p:lit "\n"))
                   'comment)))

;;;---------------------------------------------------------------------

(define (process-text text)
  (define t (string-copy text))

  (define (remove-t-prefix! prefix)
    (set! t (remove-prefix prefix t)))

  (define *macros* (make-parameter (list (list '()))))

  (define (get-macro-handler name)
    (let ((p (*macros*)))
      (let ((association (assoc name (caar p))))
        (if association
          (cdr association)
          #f))))

  (define (set-macro-handler! name handler)
    (let ((p (*macros*)))
      (let ((lst (alist-delete! name (caar p)))
            (association (cons name handler)))
        (set-car! (car p) (cons association lst)))))

  ;;
  ;; (@@@ include-raw FORM)
  ;;
  ;; Non-recursive include of the file specified by the FORM.
  ;;
  (define (include-raw-handler macro-call macro-name macro-body)
    (let-values (((filename) (evaluate macro-body)))
      (with-input-from-file filename
        (lambda () (read-string #f)))))
  (set-macro-handler! "include-raw" include-raw-handler)

  ;;
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
