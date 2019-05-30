(import chicken.io chicken.process-context chicken.tcp)

(let ((args (command-line-arguments)))
  (if (= (length args) 2)
      (let-values (((in out) (tcp-connect "localhost" 4242)))
        (let ((line (string-append "register:" (car args) "\t" (cadr args))))
          (write-line line out)
          (print (read-line in))
          (close-input-port in)
          (close-output-port out)))
      (print "Usage: " (program-name) " USERNAME PASSWORD")))
