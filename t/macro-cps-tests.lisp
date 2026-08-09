(in-package #:fx-quant-kit/test)

(defun two-values-for-cps (value)
  (values value (* 2d0 value)))

(define-cps-wrapper two-values-for-cps)

(describe
  "macro and CPS contracts"
  (it
    "preserves every value through a generated continuation"
    (let ((called nil)
          (first-value nil)
          (second-value nil))
      (two-values-for-cps/k
       3d0
       (lambda (first second)
         (setf called t
               first-value first
               second-value second)))
      (expect called :to-be t)
      (expect first-value :to-be-close-to 3d0 10)
      (expect second-value :to-be-close-to 6d0 10)))

  (it
    "rejects a missing or non-callable continuation"
    (signals invalid-argument
             (mean/k))
    (signals invalid-argument
             (mean/k #(1d0 2d0) :not-a-function)))

  (it
    "validates value-record syntax before expansion"
    (signals error
             (macroexpand-1
              '(fx-quant-kit:define-value-record invalid-value-record
                 ((slot 0 :type)))))))
