
(define ehdlr (exit-handler))
(printf "the exit handler is ~s\n" ehdlr)

(namespace-variable-value 'quiet-load #f
  (lambda ()
    (namespace-set-variable-value! 'quiet-load
      (let ([argv (current-command-line-arguments)])
        (if (positive? (vector-length argv)) (vector->list argv) "all.rktl")))))

(define timeout-thread #f)


(printf "the exit handler is ~s; eq? ~a\n" (exit-handler) (eq? (exit-handler) ehdlr))

(namespace-variable-value 'real-output-port #f
  (lambda ()
    (let ([outp (current-output-port)]
          [errp (current-error-port)]
          [exit (exit-handler)]
          [errh (uncaught-exception-handler)]
          [esch (error-escape-handler)]
          [cust (current-custodian)]
          [orig-thread (current-thread)])
      (namespace-set-variable-value! 'real-output-port outp)
      (namespace-set-variable-value! 'real-error-port  errp)
      (namespace-set-variable-value! 'last-error #f)
      ;; we're loading this for the first time:
      ;; make real errors show by remembering the exn
      ;; value, and then printing it on abort.
      (uncaught-exception-handler (lambda (e) 
                                    (when (eq? (current-thread) orig-thread)
                                      (set! last-error e))
                                    (errh e)))
      ;; -- set up a timeout
      (set! timeout-thread
            (thread
             (lambda ()
               (sleep 90)
               (fprintf errp "the exit handler is ~s; eq? ~a\n" (exit-handler) (eq? (exit-handler) ehdlr))
               (fprintf errp "\n\n~aTIMEOUT -- ABORTING!\n" Section-prefix)
               (thread
                (lambda ()
                  (fprintf errp "\n\nstarting a backup timeout thread\n\n")
                  (sleep 20)
                  (fprintf errp "\n\nbackup thread slept for 20s; go for custodian-shutdown-all\n\n")
                  (custodian-shutdown-all cust)))
               (sleep 1)
               (fprintf errp "the real exit i am calling is: ~s, eq? ~a\n" exit (eq? exit ehdlr))
               (exit 3)
               (fprintf errp "(exit 3) huh?\n")
               ;; in case the above didn't work for some reason
               (sleep 60)
               (fprintf errp "(sleep 60) done; go for (custodian-shutdown-all cust)\n")
               (custodian-shutdown-all cust)))))))

(let ([p (make-output-port
          'quiet always-evt (lambda (str s e nonblock? breakable?) (- e s))
          void)])
  (call-with-continuation-prompt
   (lambda ()
     (parameterize ([current-output-port p] [current-error-port p])
       (for ([quiet-load (in-list (if (list? quiet-load)
                                      quiet-load
                                      (list quiet-load)))])
         (load-relative quiet-load)))
     (kill-thread timeout-thread))
   (default-continuation-prompt-tag)
   (lambda (thunk)
     (when last-error
       (fprintf real-error-port "~aERROR: ~a\n"
                Section-prefix
                (if (exn? last-error) (exn-message last-error) last-error))
       (exit 2))))
  (report-errs #t))
