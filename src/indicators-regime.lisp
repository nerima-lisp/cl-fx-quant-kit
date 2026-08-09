(in-package #:fx-quant-kit)

(defun hurst-exponent (values)
  "Estimate the Hurst exponent by log-log regression of rescaled ranges."
  (let* ((vector (%as-double-vector values 'values :minimum-length 20))
         (maximum-lag (floor (length vector) 2))
         (log-lags (make-array (1- maximum-lag)
                               :element-type 'double-float))
         (log-ranges (make-array (1- maximum-lag)
                                 :element-type 'double-float))
         (count 0)
         (prefix-sum (aref vector 0))
         (prefix-correction 0d0))
    (loop for lag from 2 to maximum-lag
          for value = (aref vector (1- lag))
          for next-sum = (+ prefix-sum value)
          do (if (>= (abs prefix-sum) (abs value))
                 (incf prefix-correction (+ (- prefix-sum next-sum) value))
                 (incf prefix-correction (+ (- value next-sum) prefix-sum)))
             (setf prefix-sum next-sum)
             (let* ((location (/ (+ prefix-sum prefix-correction) lag))
                    (minimum 0d0)
                    (maximum 0d0)
                    (running 0d0)
                    (deviation-count 0)
                    (deviation-location 0d0)
                    (sum-of-squared-deviations 0d0))
               (loop for index below lag
                     for deviation =
                       (ensure-finite (- (aref vector index) location)
                                      'values)
                     do (incf running deviation)
                        (setf minimum (min minimum running)
                              maximum (max maximum running))
                        (incf deviation-count)
                        (let* ((delta (- deviation deviation-location))
                               (updated-location
                                 (+ deviation-location
                                    (/ delta deviation-count))))
                          (incf sum-of-squared-deviations
                                (* delta (- deviation updated-location)))
                          (setf deviation-location updated-location)))
               (let ((scale
                       (sqrt (/ (max 0d0 sum-of-squared-deviations)
                                (1- deviation-count))))
                     (range (- maximum minimum)))
                 (when (and (> range 0d0)
                            (> scale 0d0))
                   (setf (aref log-lags count)
                         (log (coerce lag 'double-float))
                         (aref log-ranges count)
                         (log (/ range scale)))
                   (incf count)))))
    (when (< count 2)
      (error 'numerical-error :operation 'hurst-exponent))
    (let* ((x-mean (/ (%compensated-sum log-lags) count))
           (y-mean (/ (%compensated-sum log-ranges) count))
           (denominator
             (loop for index below count
                   for difference = (- (aref log-lags index) x-mean)
                   sum (* difference difference)
                     into total of-type double-float
                   finally (return total))))
      (when (zerop denominator)
        (error 'numerical-error :operation 'hurst-exponent))
      (/ (loop for index below count
               sum (* (- (aref log-lags index) x-mean)
                      (- (aref log-ranges index) y-mean))
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
