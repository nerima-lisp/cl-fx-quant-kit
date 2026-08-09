(in-package #:fx-quant-kit)

(defun portfolio-volatility (weights covariance-matrix)
  "Return the square root of portfolio variance."
  (let ((variance (portfolio-variance weights covariance-matrix)))
    (unless (>= variance 0d0)
      (error 'numerical-error :operation 'portfolio-volatility))
    (sqrt variance)))

(defun portfolio-risk-contributions (weights covariance-matrix)
  "Return component variance contributions w_i (Σw)_i.

The result is a simple double-float vector whose sum equals portfolio
variance, including signed contributions for hedged portfolios."
  (let* ((weight-vector (%as-double-vector weights 'weights :minimum-length 1))
         (dimension (length weight-vector))
         (matrix (%ensure-covariance-matrix covariance-matrix dimension))
         (result (make-array dimension :element-type 'double-float)))
    (loop for row below dimension
          for marginal = 0d0
          do (loop for column below dimension
                   do (incf marginal
                            (* (ensure-finite (aref matrix row column)
                                               'covariance-matrix)
                               (aref weight-vector column))))
             (setf (aref result row)
                   (* (aref weight-vector row) marginal)))
    result))
