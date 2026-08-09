(in-package #:fx-quant-kit)

(defun ensure-real (value name)
  "Require VALUE to be a real number and return it unchanged."
  (unless (realp value)
    (error 'invalid-argument :name name :value value))
  value)

(defun ensure-finite (value name)
  "Coerce a real VALUE to double-float after rejecting non-finite values."
  (ensure-real value name)
  (let ((number (handler-case (coerce value 'double-float)
                  (error ()
                    (error 'invalid-argument :name name :value value)))))
    (when (or (/= number number)
              (> (abs number) most-positive-double-float))
      (error 'invalid-argument :name name :value value))
    number))

(defun ensure-positive (value name)
  "Require VALUE to be finite and strictly positive."
  (let ((number (ensure-finite value name)))
    (unless (> number 0d0)
      (error 'invalid-argument :name name :value value))
    number))

(defun ensure-non-negative (value name)
  "Require VALUE to be finite and non-negative."
  (let ((number (ensure-finite value name)))
    (unless (>= number 0d0)
      (error 'invalid-argument :name name :value value))
    number))

(defun ensure-probability (value name)
  "Require VALUE to be a finite probability in the closed unit interval."
  (let ((number (ensure-finite value name)))
    (unless (and (>= number 0d0) (<= number 1d0))
      (error 'invalid-argument :name name :value value))
    number))

(defun approx= (left right &key (absolute-tolerance 1d-10)
                             (relative-tolerance 1d-8))
  "Return true when two real numbers are equal within either tolerance."
  (let ((a (ensure-finite left 'left))
        (b (ensure-finite right 'right))
        (absolute (ensure-non-negative absolute-tolerance
                                        'absolute-tolerance))
        (relative (ensure-non-negative relative-tolerance
                                        'relative-tolerance)))
    (<= (abs (- a b))
        (max absolute (* relative (max 1d0 (abs a) (abs b)))))))
