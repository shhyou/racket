#lang racket/base

(require syntax/stx
         "util.rkt")
(require (for-template "../keywords.rkt"))
  
(provide check-tagged
         check-tagged-:-clause
         check-tagged-id
         check-tagged-spec-syntax
         check-spec-syntax
         check-unit-syntax
         check-unit-body-syntax
         check-link-line-syntax
         check-compound-syntax
         check-def-syntax)

;; check-tagged : (syntax-object -> X) -> syntax-object -> (cons (or symbol #f) X)
(define (check-tagged check)
  (λ (o)
    (let loop ([o o])
      (syntax-case o (bind-at tag)
        ((bind-at bind o)
         (loop #'o))
        ((tag . s)
         (syntax-case #'s ()
           ((sym spec) 
            (begin
              (unless (symbol? (syntax-e #'sym))
                (raise-stx-err "tag must be a symbol" #'sym))
              (cons (syntax-e #'sym) (check #'spec))))
           (_ (raise-stx-err "expected (tag <identifier> <syntax>)" #'s))))
        (_ 
         (cons #f (check o)))))))

;; check-tagged-:-clause : syntax-object -> (cons identifier identifier)
;; ensures that clause matches (a : b) or (a : (tag t b))
(define (check-tagged-:-clause clause)
  (checked-syntax->list clause)
  (syntax-case* clause (:) (lambda (x y) (eq? (syntax-e x) (syntax-e y)))
    ((a : b)
     (identifier? #'a)
     (let ([p ((check-tagged check-id) #'b)])
       (cons (car p) (cons #'a (cdr p)))))
    (_ (raise-stx-err
        "expected syntax matching (<identifier> : <identifier>) or (<identifier> : (tag <identifier> <identifier>))"
        clause))))

(define check-tagged-id (check-tagged check-id))

;; check-spec-syntax : syntax-object boolean (syntax-object -> boolean) -> prim-spec?
;; ensures that s matches spec, returns the core prim-spec (which is usually an identifier)
;; tag-spec ::= spec
;;            | (tag symbol spec)
;; spec ::= prim-spec
;;        | (prefix identifier spec)
;;        | (rename spec (identifier identifier) ...)
;;        | (only spec identifier ...)                 only if import? is true
;;        | (except spec identifier ...)               only if import? is true
(define (check-tagged-spec-syntax s import? prim-spec?)
  ((check-tagged (λ (s) (check-spec-syntax s import? prim-spec?))) s))

(define (check-spec-syntax s import? prim-spec?)
  (cond
   [(prim-spec? s) s]
   [else
    (let ((ie (if import? 'import 'export)))
      (unless (stx-pair? s)
        (raise-stx-err (format "bad ~a spec" ie) s))
      (checked-syntax->list s)
      (syntax-case s (prefix rename bind-at)
        ((bind-at any spec)
         (check-spec-syntax #'spec import? prim-spec?))
        ((key . x)
         (or (free-identifier=? #'key #'only)
             (free-identifier=? #'key #'except))
         (begin
           (unless import?
             (raise-stx-err 
              "bad export-spec keyword"
              #'key))
           (syntax-case #'x ()
             (()
              (raise-stx-err (format "missing ~a-spec argument" ie)
                             s))
             ((s y ...)
              (begin
                (for-each check-id (syntax->list #'(y ...)))
                (check-spec-syntax #'s import? prim-spec?))))))
        ((prefix)
         (raise-stx-err (format "missing prefix identifier and ~a spec" ie)
                        s))
        ((prefix x)
         (begin
           (check-id #'x)
           (raise-stx-err (format "missing ~a spec" ie) s)))
        ((prefix x y)
         (begin
           (check-id #'x)
           (check-spec-syntax #'y import? prim-spec?)))
        ((prefix . _)
         (raise-stx-err "too many arguments" s))
        ((rename)
         (raise-stx-err (format "missing ~a spec" ie) s))
        ((rename sub-s clause ...)
         (begin
           (for-each
            (lambda (c)
              (syntax-case c ()
                ((a b) 
                 (begin
                   (check-id #'a)
                   (check-id #'b)))
                ((a . b)
                 (begin
                   (checked-syntax->list c)
                   (raise-stx-err "bad rename clause" c)))
                (_
                 (raise-stx-err "bad rename clause" c))))
            (syntax->list #'(clause ...)))
           (check-spec-syntax #'sub-s import? prim-spec?)))
        ((k . x)
         (raise-stx-err (format "bad ~a-spec keyword" ie) #'k))))]))

;; check-unit-syntax : syntax-object -> syntax-object
;; ensures that stx matches ((import i ...) (export e ...) b ...)
;; or ((import i ...) (export e ...) (init-depend id ...) b ...)
;; and returns syntax that matches the latter
(define (check-unit-syntax stx)
  (syntax-case stx (import export init-depend)
    (((import . isig) (export . esig) (init-depend . id) . body)
     (begin
       (checked-syntax->list (stx-car stx))
       (checked-syntax->list (stx-car (stx-cdr stx)))
       (checked-syntax->list (stx-car (stx-cdr (stx-cdr stx))))
       (checked-syntax->list #'body)
       stx))
    (((import . isig) (export . esig) . body)
     (begin
       (checked-syntax->list (stx-car stx))
       (checked-syntax->list (stx-car (stx-cdr stx)))
       (checked-syntax->list #'body)
       (syntax/loc stx
         ((import . isig) (export . esig) (init-depend) . body))))
    (()
     (raise-stx-err "missing import and export clauses"))
    (((import . isig))
     (raise-stx-err "missing export clause"))
    (((import . isig) e . rest)
     (raise-stx-err "export clause must start with keyword \"export\"" #'e))
    ((i . rest)
     (raise-stx-err "import clause must start with keyword \"import\"" #'i))))


;; check-unit-body-syntax : syntax-object -> syntax-object
;; ensures that stx matches (exp (import i ...) (export e ...))
;; or (exp (import i ...) (export e ...) (init-depend id ...))
;; and returns syntax that matches the latter
(define (check-unit-body-syntax stx)
  (checked-syntax->list stx)
  (syntax-case stx (import export init-depend)
    ((exp (import . isig) (export . esig) (init-depend . id))
     (begin
       (checked-syntax->list (stx-car (stx-cdr stx)))
       (checked-syntax->list (stx-car (stx-cdr (stx-cdr stx))))
       (checked-syntax->list (stx-car (stx-cdr (stx-cdr (stx-cdr stx)))))
       stx))
    ((exp (import . isig) (export . esig))
     (begin
       (checked-syntax->list (stx-car (stx-cdr stx)))
       (checked-syntax->list (stx-car (stx-cdr (stx-cdr stx))))
       (syntax/loc stx
         (exp (import . isig) (export . esig) (init-depend)))))
    (()
     (raise-stx-err "missing expression, import and export clauses"))
    ((exp)
     (raise-stx-err "missing import and export clauses"))
    ((exp (import . isig))
     (raise-stx-err "missing export clause"))
    ((exp i e id extra . rest)
     (raise-stx-err "too many clauses" stx))
    ((exp (import . isig) (export . esig) id)
     (raise-stx-err "init-depend clause must start with keyword \"init-depend\"" #'id))
    ((exp (import . isig) e . rest)
     (raise-stx-err "export clause must start with keyword \"export\"" #'e))
    ((exp i . rest)
     (raise-stx-err "import clause must start with keyword \"import\"" #'i))))




;; check-link-line-syntax : syntax-object -> 
;; ensures that l matches ((x ...) u y ...)
(define (check-link-line-syntax l)
  (unless (stx-pair? l)
    (raise-stx-err "bad linking line" l))
  (checked-syntax->list l)
  (syntax-case l ()
    (((x ...) u y ...) (void))
    (((x ...))
     (raise-stx-err "missing unit expression" l))
    ((x . y)
     (begin
       (unless (stx-pair? #'x)
         (raise-stx-err "bad export list" #'x))
       (checked-syntax->list #'x)))))

;; check-compound-syntax : syntax-object -> syntax-object
;; ensures that clauses has exactly one clause matching each of
;; (import i ...), (export e ...), and (link i ...), in any order.
;; returns #'((i ...) (e ...) (l ...))
(define (check-compound-syntax c)
  (define clauses (checked-syntax->list c))
  (define im #f)
  (define ex #f)
  (define li #f)
  (for-each
   (lambda (clause)
     (syntax-case clause (import export link)
       ((import i ...)
        (begin
          (when im
            (raise-stx-err "multiple import clauses" clause))
          (set! im (syntax->list #'(i ...)))))
       ((export e ...)
        (begin
          (when ex
            (raise-stx-err "multiple export clauses" clause))
          (set! ex (syntax->list #'(e ...)))))
       ((link l ...)
        (begin
          (when li
            (raise-stx-err "duplicate link clauses" clause))
          (set! li (syntax->list #'(l ...)))))
       ((x . y)
        (begin
          (checked-syntax->list clause)
          (raise-stx-err "bad compound-unit clause keyword" #'x)))
       (_
        (raise-stx-err "expected import, export, or link clause" clause))))
   clauses)
  (unless im
    (raise-stx-err "missing import clause"))
  (unless ex
    (raise-stx-err "missing export clause"))
  (unless li
    (raise-stx-err "missing link clause" ))
  #`(#,im #,ex #,li))

;; check-def-syntax : syntax-object ->
;; d must be a syntax-pair
;; ensures that d matches (_ (x ...) e)
(define (check-def-syntax d)
  (unless (syntax->list d)
    (raise-syntax-error
     #f
     "bad syntax (illegal use of `.')"
     d))
  (syntax-case d ()
    ((_ params expr)
     (let ((l (syntax->list #'params)))
       (unless l
         (raise-syntax-error
          #f
          "bad variable list"
          d #'params))
       (for-each
        (lambda (x)
          (unless (identifier? x)
            (raise-syntax-error
             #f
             "not an identifier"
             d x)))
        l)))
    (_
     (raise-syntax-error
      #f
      (format "bad syntax (has ~a parts after keyword)"
              (sub1 (length (syntax->list d))))
      d))))
