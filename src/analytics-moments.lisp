(in-package #:fx-quant-kit)

(defun %central-moment (vector order)
  (let ((location (mean vector)))
    (/ (%compensated-sum vector
                         (lambda (value)
                           (expt (- value location) order)))
       (length vector))))

(defun %require-non-constant (variance operation)
  (when (zerop variance)
    (error 'numerical-error :operation operation))
  variance)

(defun skewness (values &key (bias-corrected-p nil))
  "Return the standardized third central moment of VALUES.

By default this is the population moment.  BIAS-CORRECTED-P applies the
finite-sample correction commonly called the adjusted Fisher-Pearson
coefficient and requires at least three observations."
  (let* ((minimum-length (if bias-corrected-p 3 2))
         (vector (%as-double-vector values
                                    'values
                                    :minimum-length minimum-length))
         (second-moment (%require-non-constant
                         (%central-moment vector 2)
                         'skewness))
         (raw (/ (%central-moment vector 3)
                 (expt second-moment 1.5d0))))
    (if bias-corrected-p
        (let ((length (length vector)))
          (coerce (* (sqrt (/ (* length (1- length))
                              (expt (- length 2) 2)))
                     raw)
                  'double-float))
        (coerce raw 'double-float))))

(defun excess-kurtosis (values &key (bias-corrected-p nil))
  "Return excess kurtosis, with an optional finite-sample correction.

The uncorrected result is the fourth standardized central moment minus three.
BIAS-CORRECTED-P returns the unbiased excess-kurtosis estimator and requires
at least four observations."
  (let* ((minimum-length (if bias-corrected-p 4 2))
         (vector (%as-double-vector values
                                    'values
                                    :minimum-length minimum-length))
         (second-moment (%require-non-constant
                         (%central-moment vector 2)
                         'excess-kurtosis))
         (raw (- (/ (%central-moment vector 4)
                    (expt second-moment 2))
                   3d0)))
    (if bias-corrected-p
        (let ((length (length vector)))
          (coerce (* (/ (1- length)
                        (* (- length 2) (- length 3)))
                     (+ (* (1+ length) raw) 6d0))
                  'double-float))
        (coerce raw 'double-float))))
