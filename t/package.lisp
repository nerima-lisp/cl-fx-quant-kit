(defpackage #:fx-quant-kit/test
  (:use #:cl #:fx-quant-kit)
  (:shadowing-import-from #:cl-weave #:describe)
  (:import-from #:cl-weave
                #:expect
                #:it
                #:signals
                #:run-all)
  (:export #:run-tests))

(in-package #:fx-quant-kit/test)

(defun expect-sequence-close (actual expected &optional (digits 8))
  "Assert element-wise numerical closeness for any proper sequence."
  (expect (length actual) :to-be (length expected))
  (loop for index below (length expected)
        do (expect (elt actual index)
                   :to-be-close-to (elt expected index)
                   digits)))

(defun expect-vector-close (actual expected &optional (digits 8))
  "Assert element-wise numerical closeness for vectors."
  (expect-sequence-close actual expected digits))

(defmacro with-cps-result ((result function &rest arguments) &body body)
  "Run a callback-last wrapper and assert that its continuation was called."
  `(cl-weave:with-continuation-result (,result capture calledp)
     (funcall #',function ,@arguments #'capture)
     (expect calledp :to-be t)
     ,@body))

(defmacro with-deterministic-weave (&body body)
  "Run property-based tests with a reproducible seed and trial budget."
  `(let ((cl-weave:*property-seed* 20260808)
         (cl-weave:*property-test-count* 32))
     ,@body))

(defun run-tests (&key coverage
                       coverage-output
                       coverage-report-directory
                       coverage-include-pathnames
                       coverage-exclude-pathnames
                       coverage-minimum-expression
                       coverage-minimum-branch)
  (let ((passed
          (with-deterministic-weave
            (run-all :reporter :spec
                     :timeout-ms 10000
                     :pass-with-no-tests nil
                     :coverage coverage
                     :coverage-output coverage-output
                     :coverage-report-directory coverage-report-directory
                     :coverage-include-pathnames coverage-include-pathnames
                     :coverage-exclude-pathnames coverage-exclude-pathnames
                     :coverage-minimum-expression coverage-minimum-expression
                     :coverage-minimum-branch coverage-minimum-branch))))
    (unless passed
      (error "fx-quant-kit tests failed"))
    t))
