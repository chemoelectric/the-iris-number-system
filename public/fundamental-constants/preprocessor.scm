#!/usr/bin/env -S csi -w -s

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
        (scheme case-lambda)
        (scheme file)
        (scheme read)
        (scheme write)
        (scheme process-context)
        (scheme eval))
(cond-expand
  ((library (scheme list)) (import (scheme list)))
  ((library (srfi 1)) (import (srfi 1)))
  (else (import (srfi srfi-1))))
(cond-expand
  ((library (scheme charset)) (import (scheme charset)))
  ((library (srfi 14)) (import (srfi 14)))
  (else (import (srfi srfi-14))))
(cond-expand
  ((library (scheme fixnum)) (import (scheme fixnum)))
  ((library (srfi 143)) (import (srfi 143)))
  (else (import (srfi srfi-143))))
(cond-expand
  (chicken
   (include "snobol-match.sld")
   (include "snobol-char-set.sld")
   (include "random-fixnum.sld")
   (include "preprocessor-variables.sld"))
  (else))
(import (snobol-match)
        (snobol-char-set)
        (random-fixnum)
        (preprocessor-variables))

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
      ((library (scheme list)) (quote (scheme list)))
      ((library (srfi 1)) (quote (srfi 1)))
      (loko (quote (except (srfi :1 lists)
                           member map for-each
                           assoc list-copy make-list)))
      (else (quote (srfi srfi-1))))
    (cond-expand
      ((library (scheme charset)) (quote (scheme charset)))
      ((library (srfi 14)) (quote (srfi 14)))
      (loko (quote (srfi :14 char-sets)))
      (else (quote (srfi srfi-14))))
    (cond-expand
      ((library (scheme fixnum)) (quote (scheme fixnum)))
      ((library (srfi 143)) (quote (srfi 143)))
      (loko (quote (srfi :143 fixnums)))
      (else (quote (srfi srfi-143))))
    '(snobol-match)
    '(snobol-char-set)
    '(random-fixnum)
    '(preprocessor-variables))))

(define-syntax unspecified-value
  (syntax-rules ()
    ((¶)
     (if #f #f))))

(define random-fixnum
  (make-random-fixnum))

(define random-integer
  (make-random-integer random-fixnum))

(define (vector-shuffle! vec)
  ;;
  ;; Fisher-Yates shuffle.
  ;;
  (let loop ((i (- (vector-length vec) 1)))
    (when (positive? i)
      (let* ((j (random-integer (+ i 1))) ;; 0 <= j <= i
             (tmp (vector-ref vec i)))
        (vector-set! vec i (vector-ref vec j))
        (vector-set! vec j tmp)
        (loop (- i 1))))))

(define (eval-string str env)
  (eval (read (open-input-string str)) env))

(define (evaluate str)
  (eval-string (string-append "(values " str " )")
               (*environment*)))

(define (serialize obj)
  (let ((port (open-output-string)))
    (write obj port)
    (get-output-string port)))

(define (stringize x)
  (cond ((string? x) x)
        ((symbol? x) (symbol->string x))
        ((number? x) (number->string x))
        ((char? x) (string x))
        (else (serialize x))))

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

(define read-to-string
  (case-lambda
    (()
     (read-to-string (current-input-port)))
    ((port)
     (let ((n 4096))
       (let loop ((lst '()))
         (let ((s (read-string n port)))
           (if (eof-object? s)
             (let loop2 ((s "")
                         (p lst))
               (if (null? p)
                 s
                 (loop2 (string-append (car p) s) (cdr p))))
             (loop (cons s lst)))))))))

;;;---------------------------------------------------------------------

(define *quick-pattern*
  (make-parameter
   (p:assign-local (p:break "(;#") 'snippet)))

(define char-set:macro-name
  (char-set-difference char-set:graphic
                       (string->char-set "()[]{};|'`,@\"\\")))

(define *macro-pattern*
  (make-parameter
   (p:assign-local
    (p:seq (p:lit "(")
           (p:maybe-many (p:span-char-set char-set:whitespace))
           (p:lit "@")
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

(define *form-comment-pattern*
  (make-parameter
   (p:assign-local (p:seq
                    (p:lit "#;")
                    (p:maybe-many
                     (p:span-char-set char-set:whitespace))
                    (p:lit "(")
                    (p:bal)
                    (p:lit ")"))
                   'comment)))

;;;---------------------------------------------------------------------

(define-syntax define-lookup
  (syntax-rules ()
    ((¶ *things*
        getter setter!
        pusher! popper!
        localizer)
     (begin
       (define *things* (make-parameter (list (list '()))))
       (define (getter name)
         (let ((p (*things*)))
           (let ((association (assoc name (caar p))))
             (if association
               (cdr association)
               #f))))
       (define (setter! name value)
         (popper! name)
         (pusher! name value))
       (define (pusher! name value)
         (let ((p (*things*)))
           ;;
           ;; This is not a “true” association list, but rather a
           ;; stack.
           ;;
           (let ((lst (caar p))
                 (association (cons name value)))
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
         (syntax-rules --- ()
           ((ß body ---)
            (parameterize
                ((*things*
                  (list (map (lambda (p) (cons (car p) (cdr p)))
                             (caar (*things*))))))
              (begin
                body ---
                (unspecified-value)
                )))))))))

(define-lookup *macro-handlers*
  get-macro-handler
  set-macro-handler!
  push-macro-handler!
  pop-macro-handler!
  localize-macro-handlers)

;;;---------------------------------------------------------------------

(define (process-text text output-port)

  (define t (string-copy text))

  (define (shorten-t! n)
    (set! t (string-copy t n)))

  (define (remove-t-prefix! prefix)
    (set! t (remove-prefix prefix t)))

  (define (reinsert! str)
    (set! t (string-append str t)))

  (define (output-to-port obj)
    (display obj output-port))

  ;;----------------------------------------------------
  ;; (@ eval FORM ...)
  ;; (@ hide FORM ...)
  ;; (@ dnl FORM ...)
  ;;
  ;; Evaluate FORM ... as Scheme. The “eval” version expands the
  ;; results, whereas “hide” does not. The “dnl” version not only
  ;; hides the results, it deletes text up through the next newline.
  ;;

  (define (eval-handler macro-call macro-name macro-body)
    (let-values ((form-lst (evaluate macro-body)))
      (for-each (lambda (form)
                  (output-to-port (serialize form)))
                form-lst)))

  (define (hide-handler macro-call macro-name macro-body)
    (let-values ((form-lst (evaluate macro-body)))
      (unspecified-value)))

  (define dnl-handler
    (let ((pattern (p:seq (p:alt (p:seq (p:break "\n") (p:lit "\n"))
                                 (p:lit "\n"))
                          (p:cursor 'cursor))))
      (lambda (macro-call macro-name macro-body)
        (let-values ((form-lst (evaluate macro-body)))
          (let ((match-result (snobol-match pattern t)))
            (when match-result
              (let ((n (string->number (getvar 'cursor match-result))))
                (shorten-t! n))))))))

  ;;----------------------------------------------------
  ;; (@ when PREDICATE FORM ...)
  ;; (@ unless PREDICATE FORM ...)
  ;;
  ;; For “when”, re-insert the evaluated results of FORM ... if
  ;; PREDICATE evaluates as true in Scheme. For “unless”, reverse the
  ;; sense of the PREDICATE.
  ;;

  (define-syntax when-or-unless-handler
    (syntax-rules ()
      ((¶ when-or-unless macro-body)
       (let-values ((form-lst (evaluate macro-body)))
         (unless (<= 1 (length form-lst))
           (error "expected PREDICATE FORM ..." form-lst))
         (let-values (((pred forms) (car+cdr form-lst)))
           (let ((str ""))
             (when-or-unless
              pred
              (do ((p (reverse forms) (cdr p)))
                  ((null? p))
                (set! str (string-append (car p) str))))
             (reinsert! str)))))))

  (define (when-handler macro-call macro-name macro-body)
    (when-or-unless-handler when macro-body))

  (define (unless-handler macro-call macro-name macro-body)
    (when-or-unless-handler unless macro-body))

  ;;----------------------------------------------------
  ;; (@ if FORM ...)
  ;; (@ while FORM ...)
  ;;
  ;; Nondeterministic branching and looping. (These let you write
  ;; deterministic branching and looping by putting the logic in the
  ;; Scheme code.)
  ;;
  ;; True branches are converted to strings if possible, and
  ;; re-inserted.
  ;;

  (define-syntax if-or-while-handler
    (syntax-rules ()
      ((¶ macro-body proc)
       (let-values ((forms (evaluate macro-body)))
         (let ((n (length forms)))
           (if (zero? n)
             ""
             (let ((v (make-vector n)))
               (do ((i 0 (+ i 1))
                    (p forms (cdr p)))
                   ((= i n))
                 (vector-set! v i (first p)))
               (vector-shuffle! v) ;; Enforce non-determinism.
               (proc forms v n))))))))


  (define (if-handler macro-call macro-name macro-body)
    (if-or-while-handler
     macro-body
     (lambda (forms v n)
       (let loop ((i (- n 1)))
         (cond ((= i -1)
                (error "no case is satisfied" forms))
               ((vector-ref v i) =>
                (lambda (x)
                  (reinsert! (stringize x))))
               (else
                (loop (- i 1))))))))

  (define (while-handler macro-call macro-name macro-body)
    (if-or-while-handler
     macro-body
     (lambda (forms v n)
       (let loop ((i (- n 1)))
         (cond ((= i -1)
                (unspecified-value))
               ((vector-ref v i) =>
                ;; Reinsert both the expansion and the (@ while ...)
                (lambda (x)
                  (reinsert!
                   (string-append
                    (stringize x)
                    "(@ " macro-name " " macro-body ")"))))
               (else
                (loop (- i 1))))))))

  ;;----------------------------------------------------
  ;; (@ include-raw FORM ...)
  ;;
  ;; Non-recursive include of the files specified by FORM ...
  ;;

  (define (include-raw-handler macro-call macro-name macro-body)
    (let-values ((filenames (evaluate macro-body)))
      (do ((f filenames (cdr f)))
          ((null? f))
        (with-input-from-file (car f)
          (lambda ()
            (output-to-port (read-to-string)))))))

  ;;----------------------------------------------------
  ;; (@ include FORM ...)
  ;;
  ;; Recursive include of the files specified by FORM ...
  ;;

  (define (include-handler macro-call macro-name macro-body)
    (let-values ((filenames (evaluate macro-body)))
      (do ((f (reverse filenames) (cdr f)))
          ((null? f))
        (with-input-from-file (car f)
          (lambda ()
            (reinsert! (read-to-string)))))))

  ;;----------------------------------------------------
  ;; (@ define MACRO-NAME MACRO-BODY)
  ;; (@ pushdef MACRO-NAME MACRO-BODY)
  ;;
  ;; Define a macro with the name given by the form MACRO-NAME and
  ;; definition by the form MACRO-BODY, which (in the current
  ;; implementation) must evaluate to a string. When a macro call is
  ;; made, MACRO-BODY is inserted and then evaluated recursively.
  ;;
  ;; The “define” version pops any top definition of the macro,
  ;; whereas “pushdef” does not.
  ;;

  (define-syntax define-macro
    (syntax-rules ()
      ((¶ set-or-push-macro-handler! macro-body)
       (let-values (((name body) (evaluate macro-body)))
         (unless (string? name)
           (error "macro name must be a be a string" name))
         (set-or-push-macro-handler!
          name
          (lambda (mac-call mac-name mac-body)
            (let-values ((vals (evaluate mac-body)))
              (let ((n (length vals)))
                (reinsert! (string-append "(@ popdef \"0\")"))
                (do ((i 1 (+ i 1)))
                    ((= i (+ n 1)))
                  (reinsert! (string-append
                              "(@ popdef \""
                              (number->string i) "\")")))
                (reinsert! body)
                (reinsert! (string-append
                            "(@ pushdef \"0\" "
                            (serialize name) ")"))
                (do ((i 1 (+ i 1))
                     (p vals (cdr p)))
                    ((= i (+ n 1)))
                  (reinsert! (string-append
                              "(@ pushdef \""
                              (number->string i) "\" "
                              (serialize (car p)) ")")))
                ))))))))

  (define (definition-handler macro-call macro-name macro-body)
    (define-macro set-macro-handler! macro-body))

  (define (pushdef-handler macro-call macro-name macro-body)
    (define-macro push-macro-handler! macro-body))

  ;;----------------------------------------------------
  ;; (@ popdef MACRO-NAME ...)
  ;;
  ;; Pop definitions.
  ;;

  (define (popdef-handler macro-call macro-name macro-body)
    (let-values ((names (evaluate macro-body)))
      (do ((nm names (cdr nm)))
          ((null? nm))
        (unless (string? (car nm))
          (error "macro name must be a string" (car nm)))
        (pop-macro-handler! (car nm)))))

  ;;----------------------------------------------------

  (define (handle-quick-result match-result)
    (let ((snippet (getvar 'snippet match-result)))
      (remove-t-prefix! snippet)
      (output-to-port snippet)))

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
      (output-to-port comment)))

  (define (handle-form-comment match-result)
    (let ((comment (getvar 'comment match-result)))
      (remove-t-prefix! comment)
      (output-to-port comment)))

  (set-macro-handler! "dnl" dnl-handler)
  (set-macro-handler! "eval" eval-handler)
  (set-macro-handler! "hide" hide-handler)
  (set-macro-handler! "when" when-handler)
  (set-macro-handler! "unless" unless-handler)
  (set-macro-handler! "if" if-handler)
  (set-macro-handler! "while" while-handler)
  (set-macro-handler! "include-raw" include-raw-handler)
  (set-macro-handler! "include" include-handler)
  (set-macro-handler! "define" definition-handler)
  (set-macro-handler! "pushdef" pushdef-handler)
  (set-macro-handler! "popdef" popdef-handler)

  (let loop ()
    (cond ((= 0 (string-length t))
           (unspecified-value))
          ((snobol-match (*quick-pattern*) t) =>
           (lambda (match-result)
             (handle-quick-result match-result)
             (loop)))
          ((snobol-match (*macro-pattern*) t) =>
           (lambda (match-result)
             (handle-macro-call match-result)
             (loop)))
          ((snobol-match (*form-comment-pattern*) t) =>
           (lambda (match-result)
             (handle-form-comment match-result)
             (loop)))
          ((snobol-match (*line-comment-pattern*) t) =>
           (lambda (match-result)
             (handle-line-comment match-result)
             (loop)))
          (else
           (output-to-port (string-copy t 0 1))
           (set! t (string-copy t 1))
           (loop)))))

(define (run-the-program input-file output-file)
  (let ((use-stdin? (string=? input-file "-"))
        (use-stdout? (string=? output-file "-")))
    (let ((input-port (if use-stdin?
                        (current-input-port)
                        (open-input-file input-file)))
          (output-port (if use-stdout?
                         (current-output-port)
                         (open-output-file output-file))))
      (let ((text (read-to-string input-port)))
        (process-text text output-port))
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

(guard (exc (else (exception-handler exc)))
  (let ((args (command-line)))
    (case (length args)
      ((1) (run-the-program "-" "-"))
      ((2) (run-the-program (second args) "-"))
      ((3) (run-the-program (second args) (third args)))
      (else (usage-handler args)))) )

;;;---------------------------------------------------------------------
;;; local variables:
;;; mode: scheme
;;; coding: utf-8
;;; end:
