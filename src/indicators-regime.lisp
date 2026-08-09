(in-package #:fx-quant-kit)

(defun hurst-exponent (values)
  "Estimate the Hurst exponent by log-log regression of rescaled ranges."
  (let* ((vector (%as-double-vector values 'values :minimum-length 20))
         (maximum-lag (floor (length vector) 2))
         (log-lags '())
         (log-ranges '()))
    (loop for lag from 2 to maximum-lag
          for location = (mean (subseq vector 0 lag))
          for deviations = (make-array lag :element-type 'double-float)
          do (loop for index below lag
                   do (setf (aref deviations index)
                            (- (aref vector index) location)))
             (let ((minimum 0d0)
                   (maximum 0d0)
                   (running 0d0)
                   (scale (standard-deviation deviations)))
               (loop for deviation across deviations
                     do (incf running deviation)
                        (setf minimum (min minimum running)
                              maximum (max maximum running)))
               (when (and (> (- maximum minimum) 0d0)
                          (> scale 0d0))
                 (push (log (coerce lag 'double-float)) log-lags)
                 (push (log (/ (- maximum minimum) scale)) log-ranges))))
    (when (< (length log-lags) 2)
      (error 'numerical-error :operation 'hurst-exponent))
    (let* ((x (coerce (nreverse log-lags) 'vector))
           (y (coerce (nreverse log-ranges) 'vector))
           (x-mean (mean x))
           (y-mean (mean y))
           (denominator (loop for index below (length x)
                              sum (expt (- (aref x index) x-mean) 2)
                                into total of-type double-float
                              finally (return total))))
      (when (zerop denominator)
        (error 'numerical-error :operation 'hurst-exponent))
      (/ (loop for index below (length x)
               sum (* (- (aref x index) x-mean)
                      (- (aref y index) y-mean))
                 into total of-type double-float
               finally (return total))
         denominator))))

(defun %garch-parameters (omega alpha beta)
  (let ((long-run (ensure-positive omega 'omega))
        (short-run (ensure-non-negative alpha 'alpha))
        (persistence (ensure-non-negative beta 'beta)))
    (when (>= (+ short-run persistence) 1d0)
      (error 'invalid-argument
             :name 'alpha-plus-beta
             :value (+ short-run persistence)))
    (values long-run short-run persistence)))

(defun garch11-variance (returns &key (omega 1d-6) (alpha 0.1d0) (beta 0.85d0)
                                      initial-variance)
  "Return conditional variances for a GARCH(1,1) process."
  (let ((vector (%as-double-vector returns 'returns :minimum-length 1)))
    (multiple-value-bind (long-run short-run persistence)
        (%garch-parameters omega alpha beta)
      (let* ((unconditional (/ long-run (- 1d0 short-run persistence)))
             (initial (if initial-variance
                          (ensure-positive initial-variance 'initial-variance)
                          unconditional))
             (result (make-array (length vector) :element-type 'double-float)))
        (setf (aref result 0) initial)
        (loop for index from 1 below (length vector)
              do (setf (aref result index)
                       (+ long-run
                          (* short-run (expt (aref vector (1- index)) 2))
                          (* persistence (aref result (1- index))))))
        result))))

(defun garch11-forecast (returns steps &key (omega 1d-6) (alpha 0.1d0)
                                         (beta 0.85d0) initial-variance)
  "Forecast conditional GARCH(1,1) variances for STEPS future observations."
  (unless (and (integerp steps) (>= steps 0))
    (error 'invalid-argument :name 'steps :value steps))
  (multiple-value-bind (long-run short-run persistence)
      (%garch-parameters omega alpha beta)
    (let* ((conditional (garch11-variance returns
                                           :omega long-run
                                           :alpha short-run
                                           :beta persistence
                                           :initial-variance initial-variance))
           (last-variance (aref conditional (1- (length conditional))))
           (unconditional (/ long-run (- 1d0 short-run persistence)))
           (result (make-array steps :element-type 'double-float)))
      (loop for index below steps
            do (setf (aref result index)
                     (+ unconditional
                        (* (expt persistence (1+ index))
                           (- last-variance unconditional)))))
      result)))
