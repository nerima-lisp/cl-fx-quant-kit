(require :asdf)

(let ((root (uiop:pathname-directory-pathname
             (or *load-truename* *load-pathname* (uiop:getcwd)))))
  (asdf:initialize-source-registry
   `(:source-registry (:directory ,root) :inherit-configuration))
  (handler-case
      (progn
        (asdf:test-system "fx-quant-kit")
        (format t "~&Loaded and tested fx-quant-kit source from ~A~%" root))
    (error (condition)
      (format *error-output* "~&fx-quant-kit tests failed: ~A~%" condition)
      (finish-output *error-output*)
      (uiop:quit 1))))

(uiop:quit 0)
