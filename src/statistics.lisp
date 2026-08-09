(in-package #:fx-quant-kit)

(defconstant +normal-cdf-sqrt-two-pi+
  (sqrt (* 2d0 pi)))

(defparameter +normal-cdf-quadrature-nodes+
  ;; Positive abscissas for the 16-point Gauss--Legendre rule on [-1, 1].
  #(0.095012509837637440185d0
    0.281603550779258913230d0
    0.458016777657227386342d0
    0.617876244402643748447d0
    0.755404408355003033895d0
    0.865631202387831743880d0
    0.944575023073232576078d0
    0.989400934991649932596d0))

(defparameter +normal-cdf-quadrature-weights+
  ;; Weights corresponding to the positive abscissas above.
  #(0.189450610455068496285d0
    0.182603415044923588867d0
    0.169156519395002538189d0
    0.149595988816576732081d0
    0.124628971255533872052d0
    0.095158511682492781810d0
    0.062253523938647892863d0
    0.027152459411754094852d0))

(defun normal-pdf (x &key (mean 0d0) (standard-deviation 1d0))
  "Return the probability density of a normal distribution."
  (let* ((location (ensure-finite mean 'mean))
         (deviation (ensure-positive standard-deviation 'standard-deviation))
         (observation (ensure-finite x 'x))
         (standardized (/ (- observation location) deviation)))
    (/ (exp (* -0.5d0 standardized standardized))
       (* deviation +normal-cdf-sqrt-two-pi+))))

(defun %standard-normal-cdf (standardized)
  "Return the standard normal CDF using deterministic Gaussian quadrature.

The integral of the standard normal density is smooth on the finite interval
used here, so the fixed rule gives substantially more precision than the
usual short rational approximation without introducing a numerical library
or mutable state."
  (let ((absolute (abs standardized)))
    (cond
      ((zerop absolute) 0.5d0)
      ((>= absolute 8d0)
       (if (plusp standardized) 1d0 0d0))
      (t
       (let ((half-range (/ absolute 2d0))
             (sum 0d0))
         (loop for index below (length +normal-cdf-quadrature-nodes+)
               for node = (aref +normal-cdf-quadrature-nodes+ index)
               for weight = (aref +normal-cdf-quadrature-weights+ index)
               for lower = (* half-range (- 1d0 node))
               for upper = (* half-range (+ 1d0 node))
               do (incf sum
                        (* weight
                           (+ (exp (* -0.5d0 lower lower))
                              (exp (* -0.5d0 upper upper))))))
         (let ((area (/ (* half-range sum)
                        +normal-cdf-sqrt-two-pi+)))
           (if (plusp standardized)
               (+ 0.5d0 area)
               (- 0.5d0 area))))))))

(defun normal-cdf (x &key (mean 0d0) (standard-deviation 1d0))
  "Return the cumulative probability of a normal distribution."
  (let* ((location (ensure-finite mean 'mean))
         (deviation (ensure-positive standard-deviation 'standard-deviation))
         (observation (ensure-finite x 'x))
         (standardized (/ (- observation location) deviation)))
    (%standard-normal-cdf standardized)))

(defun inverse-normal-cdf (probability &key (mean 0d0) (standard-deviation 1d0))
  "Return the inverse normal CDF using a bounded deterministic bisection."
  (let ((p (ensure-probability probability 'probability))
        (location (ensure-finite mean 'mean))
        (deviation (ensure-positive standard-deviation 'standard-deviation)))
    (when (or (zerop p) (= p 1d0))
      (error 'invalid-argument :name 'probability :value probability))
    (let ((lower -9d0)
          (upper 9d0))
      (loop repeat 120
            do
        (let* ((middle (/ (+ lower upper) 2d0))
               (value (normal-cdf middle)))
          (if (< value p)
              (setf lower middle)
              (setf upper middle))))
      (+ location (* deviation (/ (+ lower upper) 2d0))))))
