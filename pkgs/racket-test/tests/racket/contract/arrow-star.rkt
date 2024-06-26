#lang racket/base

(require "test-util.rkt")
(parameterize ([current-contract-namespace
                (make-basic-contract-namespace)])
  
  (test/no-error '(->* (integer?) () (values integer?)))
  (test/no-error '(->* (integer?) () #:rest integer? integer?))
  (test/no-error '(->* (integer?) () #:rest integer? any))
  (test/no-error '(->* ((flat-contract integer?)) () (flat-contract integer?)))
  (test/no-error '(->* ((flat-contract integer?)) () #:rest (flat-contract integer?) 
                       (flat-contract integer?)))
  (test/no-error '(->* ((flat-contract integer?)) () #:rest (flat-contract integer?)
                       (values (flat-contract integer?) (flat-contract boolean?))))
  (test/no-error '(->* ((flat-contract integer?)) () #:rest (flat-contract integer?) any))
  (test/no-error '(->* ((flat-contract integer?)) () #:pre #t (flat-contract integer?) #:post #t))
  (test/no-error '(->* (any/c) () #:pre/desc #t (flat-contract integer?) #:post/desc #t))
  
  (test/spec-passed
   'contract-arrow-star0a
   '(contract (->* (integer?) () integer?)
              (lambda (x) x)
              'pos
              'neg))
  
  (test/neg-blame
   'contract-arrow-star0b
   '((contract (->* (integer?) () integer?)
               (lambda (x) x)
               'pos
               'neg)
     #f))
  
  (test/pos-blame
   'contract-arrow-star0c
   '((contract (->* (integer?) () integer?)
               (lambda (x) #f)
               'pos
               'neg)
     1))
  
  (test/spec-passed
   'contract-arrow-star1
   '(let-values ([(a b) ((contract (->* (integer?) () (values integer? integer?))
                                   (lambda (x) (values x x))
                                   'pos
                                   'neg)
                         2)])
      1))
  
  (test/neg-blame
   'contract-arrow-star2
   '((contract (->* (integer?) () (values integer? integer?))
               (lambda (x) (values x x))
               'pos
               'neg)
     #f))
  
  (test/pos-blame
   'contract-arrow-star3
   '((contract (->* (integer?) () (values integer? integer?))
               (lambda (x) (values 1 #t))
               'pos
               'neg)
     1))
  
  (test/pos-blame
   'contract-arrow-star4
   '((contract (->* (integer?) () (values integer? integer?))
               (lambda (x) (values #t 1))
               'pos
               'neg)
     1))
  
  
  (test/spec-passed
   'contract-arrow-star5
   '(let-values ([(a b) ((contract (->* (integer?) ()
                                        #:rest (listof integer?)
                                        (values integer? integer?))
                                   (lambda (x . y) (values x x))
                                   'pos
                                   'neg)
                         2)])
      1))
  
  (test/neg-blame
   'contract-arrow-star6
   '((contract (->* (integer?) () #:rest (listof integer?) (values integer? integer?))
               (lambda (x . y) (values x x))
               'pos
               'neg)
     #f))
  
  (test/pos-blame
   'contract-arrow-star7
   '((contract (->* (integer?) () #:rest (listof integer?) (values integer? integer?))
               (lambda (x . y) (values 1 #t))
               'pos
               'neg)
     1))
  
  (test/pos-blame
   'contract-arrow-star8
   '((contract (->* (integer?) () #:rest (listof integer?) (values integer? integer?))
               (lambda (x) (values #t 1))
               'pos
               'neg)
     1))
  
  (test/spec-passed
   'contract-arrow-star9
   '((contract (->* (integer?) () #:rest (listof integer?) integer?)
               (lambda (x . y) 1)
               'pos
               'neg)
     1 2))
  
  (test/neg-blame
   'contract-arrow-star10
   '((contract (->* (integer?) () #:rest (listof integer?) integer?)
               (lambda (x . y) 1)
               'pos
               'neg)
     1 2 'bad))
  
  (test/spec-passed
   'contract-arrow-star11
   '(let-values ([(a b) ((contract (->* (integer?) ()
                                        #:rest (listof integer?)
                                        any)
                                   (lambda (x . y) (values x x))
                                   'pos
                                   'neg)
                         2)])
      1))
  
  (test/pos-blame
   'contract-arrow-star11b
   '(let-values ([(a b) ((contract (->* (integer?) ()
                                        #:rest (listof integer?)
                                        any)
                                   (lambda (x) (values x x))
                                   'pos
                                   'neg)
                         2)])
      1))
  
  (test/neg-blame
   'contract-arrow-star12
   '((contract (->* (integer?) () #:rest (listof integer?) any)
               (lambda (x . y) (values x x))
               'pos
               'neg)
     #f))
  
  (test/spec-passed
   'contract-arrow-star13
   '((contract (->* (integer?) () #:rest (listof integer?) any)
               (lambda (x . y) 1)
               'pos
               'neg)
     1 2))
  
  (test/neg-blame
   'contract-arrow-star14
   '((contract (->* (integer?) () #:rest (listof integer?) any)
               (lambda (x . y) 1)
               'pos
               'neg)
     1 2 'bad))
  
  (test/spec-passed
   'contract-arrow-star15
   '(let-values ([(a b) ((contract (->* (integer?) () any)
                                   (lambda (x) (values x x))
                                   'pos
                                   'neg)
                         2)])
      1))
  
  (test/spec-passed
   'contract-arrow-star16
   '((contract (->* (integer?) () any)
               (lambda (x) x)
               'pos
               'neg)
     2))
  
  (test/neg-blame
   'contract-arrow-star17
   '((contract (->* (integer?) () any)
               (lambda (x) (values x x))
               'pos
               'neg)
     #f))
  
  (test/spec-passed/result
   'contract-arrow-star18
   '((contract (->* (integer?) #:rest list? any)
               (lambda (x . y) y)
               'pos
               'neg)
     1 2 3)
   '(2 3))
  
  (test/pos-blame
   'contract-arrow-star-arity-check1
   '(contract (->* (integer?) () #:rest (listof integer?) (values integer? integer?))
              (lambda (x) (values 1 #t))
              'pos
              'neg))
  
  (test/pos-blame
   'contract-arrow-star-arity-check2
   '(contract (->* (integer?) () #:rest (listof integer?) (values integer? integer?))
              (lambda (x y) (values 1 #t))
              'pos
              'neg))
  
  (test/pos-blame
   'contract-arrow-star-arity-check3
   '(contract (->* (integer?) () #:rest (listof integer?) (values integer? integer?))
              (case-lambda [(x y) #f] [(x y . z) #t])
              'pos
              'neg))
  
  (test/spec-passed
   'contract-arrow-star-arity-check4
   '(contract (->* (integer?) () #:rest (listof integer?) (values integer? integer?))
              (case-lambda [(x y) #f] [(x y . z) #t] [(x) #f])
              'pos
              'neg))
  
  (test/pos-blame
   'contract-arrow-star-keyword1
   '(contract (->* (integer?) () #:rest (listof integer?) (values integer?))
              (λ (x #:y y . args) x)
              'pos
              'neg))
  
  (test/pos-blame
   'contract-arrow-star-keyword2
   '(contract (->* (integer?) () #:rest (listof integer?) any)
              (λ (x #:y y . args) x)
              'pos
              'neg))
  
  (test/spec-passed
   'contract-arrow-star-keyword3
   '(contract (->* (integer? #:y integer?) () #:rest (listof integer?) (values integer? integer?))
              (λ (x #:y y . args) x)
              'pos
              'neg))
  
  (test/spec-passed
   'contract-arrow-star-keyword4
   '(contract (->* (integer? #:y integer?) () #:rest (listof integer?) any)
              (λ (x #:y y . args) x)
              'pos
              'neg))
  
  (test/neg-blame
   'contract-arrow-star-keyword5
   '((contract (->* (integer? #:y integer?) () #:rest (listof integer?) (values integer? integer?))
               (λ (x #:y y . args) x)
               'pos
               'neg)
     1 #:y #t))
  
  (test/neg-blame
   'contract-arrow-star-keyword6
   '((contract (->* (integer? #:y integer?) () #:rest (listof integer?) any)
               (λ (x #:y y . args) x)
               'pos
               'neg)
     1 #:y #t))
  
  (test/neg-blame
   'contract-arrow-star-keyword7
   '((contract (->* (integer? #:y integer?) () #:rest (listof integer?) (values integer? integer?))
               (λ (x #:y y . args) x)
               'pos
               'neg)
     #t #:y 1))
  
  (test/neg-blame
   'contract-arrow-star-keyword8
   '((contract (->* (integer? #:y integer?) () #:rest (listof integer?) any)
               (λ (x #:y y . args) x)
               'pos
               'neg)
     #t #:y 1))
  
  (test/spec-passed
   'contract-arrow-star-keyword9
   '((contract (->* (integer? #:y integer?) () #:rest (listof integer?) (values integer? integer?))
               (λ (x #:y y . args) (values x x))
               'pos
               'neg)
     2 #:y 1))
  
  (test/spec-passed
   'contract-arrow-star-keyword10
   '((contract (->* (integer? #:y integer?) () #:rest (listof integer?) any)
               (λ (x #:y y . args) (values x x))
               'pos
               'neg)
     2 #:y 1))
  
  (test #t
        'arrow-star-right-keyword-complaint1
        (with-handlers ((exn:fail?
                         (λ (x)
                           (regexp-match? #rx"#:c keyword" (exn-message x)))))
          (contract-eval '(contract (->* (#:i integer? #:b boolean?) (#:c char? #:r regexp?) any)
                                    (λ (#:i i #:b b #:r [r #rx"x"]) 1)
                                    'pos
                                    'neg))))
  
  (test #t
        'arrow-star-right-keyword-complaint2
        (with-handlers ((exn:fail?
                         (λ (x)
                           (regexp-match? #rx"#:b keyword" (exn-message x)))))
          (contract-eval '(contract (->* (#:i integer? #:b boolean?) (#:c char? #:r regexp?) any)
                                    (λ (#:i i #:r [r #rx"x"] #:c [c #\c]) 1)
                                    'pos
                                    'neg))))
  
  (test/spec-passed
   'contract-arrow-star-optional1
   '(contract (->* (#:x boolean?) (#:y string? #:z char? integer?) any)
              (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                (list x s c i))
              'pos 'neg))
  
  (test/pos-blame
   'contract-arrow-star-optional2
   '(contract (->* (#:x boolean?) (#:y string? #:z char? integer?) any)
              (λ (#:x x #:z [c #\c] [i 5])
                (list x s c i))
              'pos 'neg))
  
  (test/spec-passed
   'contract-arrow-star-optional3
   '(contract (->* (#:x boolean?) (#:z char? integer?) any)
              (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                (list x s c i))
              'pos 'neg))
  
  (test/pos-blame
   'contract-arrow-star-optional4
   '(contract (->* (#:x boolean?) (#:y string? #:z char? integer?) any)
              (λ (#:x x #:y [s "s"] #:z [c #\c])
                (list x s c i))
              'pos 'neg))
  
  (test/spec-passed/result
   'contract-arrow-star-optional5
   '((contract (->* (#:x boolean?) (#:y string? #:z char? integer?) any)
               (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                 (list x s c i))
               'pos 'neg)
     #:x #t #:y "" #:z #\d 6)
   '(#t "" #\d 6))
  
  (test/spec-passed/result
   'contract-arrow-star-optional6
   '((contract (->* (#:x boolean?) (#:y string? #:z char? integer?) any)
               (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                 (list x s c i))
               'pos 'neg)
     #:x #t)
   '(#t "s" #\c 5))
  
  (test/neg-blame
   'contract-arrow-star-optional7
   '((contract (->* (#:x boolean?) (#:y string? #:z char? integer?) any)
               (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                 (list x s c i))
               'pos 'neg)
     #:x #t #:y 'x #:z #\d 6))
  
  (test/neg-blame
   'contract-arrow-star-optional8
   '((contract (->* (#:x boolean?) (#:y string? #:z char? integer?) any)
               (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                 (list x s c i))
               'pos 'neg)
     #:x #t #:y "" #:z 'x 6))
  
  (test/neg-blame
   'contract-arrow-star-optional9
   '((contract (->* (#:x boolean?) (#:y string? #:z char? integer?) any)
               (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                 (list x s c i))
               'pos 'neg)
     #:x #t #:y "" #:z #\d 'x))
  
  (test/pos-blame
   'contract-arrow-star-optional10
   '(contract (->* (#:x boolean?) (#:y string?) any)
              (λ (#:x [x #f] #:y s)
                (list x s c i))
              'pos 'neg))
  
  (test/spec-passed
   'contract-arrow-star-optional11
   '(contract (->* (#:x boolean?) (#:y string? #:z char? integer?) 
                   (list/c boolean? string? char? integer?))
              (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                (list x s c i))
              'pos 'neg))
  
  (test/pos-blame
   'contract-arrow-star-optional12
   '(contract (->* (#:x boolean?) (#:y string? #:z char? integer?)
                   (list/c boolean? string? char? integer?))
              (λ (#:x x #:z [c #\c] [i 5])
                (list x s c i))
              'pos 'neg))
  
  (test/spec-passed
   'contract-arrow-star-optional13
   '(contract (->* (#:x boolean?) (#:z char? integer?) (list/c boolean? string? char? integer?))
              (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                (list x s c i))
              'pos 'neg))
  
  (test/pos-blame
   'contract-arrow-star-optional14
   '(contract (->* (#:x boolean?) (#:y string? #:z char? integer?)
                   (list/c boolean? string? char? integer?))
              (λ (#:x x #:y [s "s"] #:z [c #\c])
                (list x s c i))
              'pos 'neg))
  
  (test/spec-passed/result
   'contract-arrow-star-optional15
   '((contract (->* (#:x boolean?) (#:y string? #:z char? integer?) 
                    (list/c boolean? string? char? integer?))
               (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                 (list x s c i))
               'pos 'neg)
     #:x #t #:y "" #:z #\d 6)
   '(#t "" #\d 6))
  
  (test/spec-passed/result
   'contract-arrow-star-optional16
   '((contract (->* (#:x boolean?) (#:y string? #:z char? integer?) 
                    (list/c boolean? string? char? integer?))
               (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                 (list x s c i))
               'pos 'neg)
     #:x #t)
   '(#t "s" #\c 5))
  
  (test/neg-blame
   'contract-arrow-star-optional17
   '((contract (->* (#:x boolean?) (#:y string? #:z char? integer?) 
                    (list/c boolean? string? char? integer?))
               (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                 (list x s c i))
               'pos 'neg)
     #:x #t #:y 'x #:z #\d 6))
  
  (test/neg-blame
   'contract-arrow-star-optional18
   '((contract (->* (#:x boolean?) (#:y string? #:z char? integer?) 
                    (list/c boolean? string? char? integer?))
               (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                 (list x s c i))
               'pos 'neg)
     #:x #t #:y "" #:z 'x 6))
  
  (test/neg-blame
   'contract-arrow-star-optional19
   '((contract (->* (#:x boolean?) (#:y string? #:z char? integer?)
                    (list/c boolean? string? char? integer?))
               (λ (#:x x #:y [s "s"] #:z [c #\c] [i 5])
                 (list x s c i))
               'pos 'neg)
     #:x #t #:y "" #:z #\d 'x))
  
  (test/pos-blame
   'contract-arrow-star-optional20
   '(contract (->* (#:x boolean?) (#:y string?) (list/c boolean? string? char? integer?))
              (λ (#:x [x #f] #:y s)
                (list x s c i))
              'pos 'neg))
  
  (test/spec-passed
   'contract-arrow-star-optional21
   '((contract (->* () () (values))
               (λ () (values))
               'pos 'neg)))
  
  (test/spec-passed
   'contract-arrow-star-optional22
   '((contract (->* () () (values integer? char?))
               (λ () (values 1 #\c))
               'pos 'neg)))
  
  (test/pos-blame
   'contract-arrow-star-optional23
   '((contract (->* () () (values integer? char?))
               (λ () (values 1 2))
               'pos 'neg)))
  
  (test/spec-passed
   'contract-arrow-star-optional24
   '(let ()
      (define (statement? s)
        (and (string? s)
             (> (string-length s) 3)))
      (define statement/c (flat-contract statement?))
      
      (define new-statement
        (make-keyword-procedure
         (λ (kws kw-args . statement)
           (format "kws=~s  kw-args=~s  statement=~s" kws kw-args statement))))
      
      (contract (->* (statement/c) (#:s string?) statement/c)
                new-statement
                'pos 'neg)))
  
  (test/spec-passed/result
   'contract-arrow-star-optional25
   '((contract 
      (->* (#:user string?)
           (#:database (or/c string? #f)
                       #:password (or/c string? (list/c 'hash string?) #f)
                       #:port (or/c exact-positive-integer? #f))
           any/c)
      (λ (#:user user
                 #:database [db #f]
                 #:password [password #f]
                 #:port [port #f])
        (list user db password port))
      'pos 'neg)
     #:database "db" #:password "password" #:user "user")
   (list "user" "db" "password" #f))

  (test/spec-passed/result
   'contract-arrow-star-optional25b
   '((contract 
      (->* (#:user string?)
           (#:database (first-or/c string? #f)
                       #:password (first-or/c string? (list/c 'hash string?) #f)
                       #:port (first-or/c exact-positive-integer? #f))
           any/c)
      (λ (#:user user
                 #:database [db #f]
                 #:password [password #f]
                 #:port [port #f])
        (list user db password port))
      'pos 'neg)
     #:database "db" #:password "password" #:user "user")
   (list "user" "db" "password" #f))
  
  (test/spec-passed
   'contract-arrow-star-keyword-ordering
   '((contract (->* (integer? #:x boolean?) (string? #:y char?) any)
               (λ (x #:x b [s ""] #:y [c #\c])
                 (list x b s c))
               'pos
               'neg)
     1 "zz" #:x #f #:y #\d))
  
  
  (test/spec-passed
   '->*-pre/post-1
   '((contract (->* () () integer? #:post #t)
               (λ () 1)
               'pos
               'neg)))
  
  (test/pos-blame
   '->*-pre/post-2
   '((contract (->* () () integer? #:post #t)
               (λ () 'not-an-int)
               'pos
               'neg)))
  
  (test/spec-passed
   '->*-pre/post-3
   '((contract (->* () () (values integer? boolean?) #:post #t)
               (λ () (values 1 #t))
               'pos
               'neg)))
  
  (test/pos-blame
   '->*-pre/post-4
   '((contract (->* () () (values integer? boolean?) #:post #t)
               (λ () (values 1 'not-a-boolean))
               'pos
               'neg)))
  
  (test/neg-blame
   '->*-pre/post-5
   '((contract (->* () () #:pre #f integer? #:post #t)
               (λ () 1)
               'pos
               'neg)))
  
  (test/pos-blame
   '->*-pre/post-6
   '((contract (->* () () #:pre #t integer? #:post #f)
               (λ () 1)
               'pos
               'neg)))
  
  (test/neg-blame
   '->*-pre/post-7
   '((contract (->* () () #:pre #f integer? #:post #f)
               (λ () 1)
               'pos
               'neg)))
  
  (test/neg-blame
   '->*pre/post-8
   '((contract (->* () () #:pre/desc #f integer? #:post/desc #f)
               (λ () 1)
               'pos
               'neg)))
  
  (test/neg-blame
   '->*pre/post-9
   '((contract (->* () () #:pre/desc "" integer? #:post/desc #f)
               (λ () 1)
               'pos
               'neg)))
  
  (test/neg-blame
   '->*pre/post-10
   '((contract (->* () () #:pre/desc '("qqq") integer? #:post/desc #f)
               (λ () 1)
               'pos
               'neg)))
  
  (test/pos-blame
   '->*pre/post-11
   '((contract (->* () () #:pre/desc #t integer? #:post/desc #f)
               (λ () 1)
               'pos
               'neg)))
  
  (test/pos-blame
   '->*pre/post-12
   '((contract (->* () () #:pre/desc #t integer? #:post/desc "")
               (λ () 1)
               'pos
               'neg)))
  
  (test/pos-blame
   '->*pre/post-13
   '((contract (->* () () #:pre/desc #t integer? #:post/desc '("qqc"))
               (λ () 1)
               'pos
               'neg)))
  
  (test/pos-blame
   '->*pre/post-14
   '((contract (->* () () #:pre/desc #t integer? #:post/desc '("qqc"))
               (λ () 1)
               'pos
               'neg)))
  
  (test/neg-blame
   '->*pre/post-15
   '((contract (->* (integer?) #:pre/desc '("something" "not so great" "happened") any)
               (λ (x) 1)
               'pos 'neg)
     1))
  
  (contract-error-test
   '->*pre/post-16
   '((contract (->* () () #:pre/desc '("something wonderful") integer? #:post/desc '("qqc"))
                (λ () 1)
                'pos
                'neg))
   (λ (x)
     (and (exn:fail:contract? x)
          (regexp-match #rx"\n *something wonderful\n"
                        (exn-message x)))))
  
  (contract-error-test
   '->*pre/post-17
   '((contract (->* () () integer? #:post/desc "something horrible")
               (λ () 1)
               'pos
               'neg))
   (λ (x)
     (and (exn:fail:contract? x)
          (regexp-match #rx"\n *something horrible\n"
                        (exn-message x)))))

  (test/neg-blame
   '->*pre/post-18
   '((contract (->* (any/c) #:pre/desc #f any)
               (lambda (x) x)
               'pos 'neg)
     2))

  (test/neg-blame
   '->*pre/post-19
   '(let ()
      (struct posn (x y))
      ((contract (->* (any/c) #:pre/desc #f boolean?)
                 posn?
                 'pos 'neg)
     2)))
  
  (test/neg-blame
   '->*-pre/post-20
   '((contract (->* () #:rest list? #:pre #f integer?)
               (λ args 1)
               'pos
               'neg)))

  (test/neg-blame
   '->*-pre/post-21
   '((contract (->* () #:rest (list/c integer?) #:pre #t integer?)
               (λ args 1)
               'pos
               'neg)
     ""))

  (test/spec-passed
   '->*-pre/post-22
   '((contract (->* () #:rest (list/c integer?) #:pre #t integer?)
               (λ args 1)
               'pos
               'neg)
     2))

  (test/spec-passed
   '->*-opt-optional1
   '((contract (->* () integer?) (lambda () 1) 'pos 'neg)))
  
  (test/spec-passed
   '->*-opt-optional2
   '((contract (->* () (values boolean? integer?)) (lambda () (values #t 1)) 'pos 'neg)))
  
  (test/spec-passed
   '->*-opt-optional3
   '((contract (->* () #:rest any/c integer?) (lambda x 1) 'pos 'neg)))
  
  (test/spec-passed
   '->*-opt-optional4
   '((contract (->* () #:pre #t integer?) (lambda x 1) 'pos 'neg)))
  
  (test/spec-passed
   '->*-opt-optional5
   '((contract (->* () integer? #:post #t) (lambda x 1) 'pos 'neg)))

  (test/pos-blame
   '->*-opt-vs-mand1
   '(contract (->* (integer?) (symbol? boolean?) number?)
              (lambda (x y [z #t])
                x)
              'pos
              'neg))
  (test/pos-blame
   '->*-opt-vs-mand2
   '(contract (->* () (symbol? boolean?) symbol?)
              (lambda (y [z #t])
                y)
              'pos
              'neg))

  (contract-syntax-error-test
   '->*-too-much-stuff
   #'(->* () #:rest (listof procedure?) () any)
   #rx"expected the #:rest keyword to be followed only by the range")
  )
