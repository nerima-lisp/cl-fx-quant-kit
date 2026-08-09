(in-package #:fx-quant-kit)

(defun %as-double-vector (values name &key (minimum-length 0))
  (unless (typep values 'sequence)
    (error 'invalid-argument :name name :value values))
  (let* ((source (coerce values 'vector))
         (length (length source)))
    (when (< length minimum-length)
      (error 'insufficient-data :required minimum-length :actual length))
    (let ((result (make-array length :element-type 'double-float)))
      (loop for index below length
            do (setf (aref result index)
                     (ensure-finite (aref source index) name)))
      result)))

(defun %copy-vector (values)
  (let* ((source (coerce values 'vector))
         (result (make-array (length source))))
    (replace result source)
    result))

(defun %require-period (period length)
  (unless (and (integerp period) (plusp period))
    (error 'invalid-argument :name 'period :value period))
  (when (> period length)
    (error 'insufficient-data :required period :actual length))
  period)

(defun %ensure-same-length (left right left-name right-name)
  (unless (= (length left) (length right))
    (error 'invalid-shape
           :expected (list left-name (length left))
           :actual (list right-name (length right))))
  left)

(defun %sorted-copy (values)
  (sort (%copy-vector values) #'<))

(defun %compensated-sum (values &optional (transform #'identity))
  "Return a Neumaier-compensated sum of VALUES.

TRANSFORM is applied to each element before it is accumulated.  The helper
keeps the public numerical functions stable when a large location is mixed
with relatively small observations, without exposing an accumulator type to
callers."
  (let ((sum 0d0)
        (correction 0d0))
    (loop for value across values
          for term = (coerce (funcall transform value) 'double-float)
          for next = (+ sum term)
          do (if (>= (abs sum) (abs term))
                 (incf correction (+ (- sum next) term))
                 (incf correction (+ (- term next) sum)))
             (setf sum next)
          finally (return (coerce (+ sum correction) 'double-float)))))

(defun %dot-product (left right)
  (%ensure-same-length left right 'left 'right)
  (let ((sum 0d0)
        (correction 0d0))
    (loop for index below (length left)
          for term = (* (aref left index) (aref right index))
          for next = (+ sum term)
          do (if (>= (abs sum) (abs term))
                 (incf correction (+ (- sum next) term))
                 (incf correction (+ (- term next) sum)))
             (setf sum next)
          finally (return (coerce (+ sum correction) 'double-float)))))

(defun %stable-variance (vector sample-p)
  "Return a variance using the one-pass Welford recurrence."
  (let ((count 0)
        (location 0d0)
        (sum-of-squared-deviations 0d0))
    (loop for value across vector
          do (incf count)
             (let* ((delta (- value location))
                    (updated-location (+ location (/ delta count))))
               (incf sum-of-squared-deviations
                     (* delta (- value updated-location)))
               (setf location updated-location)))
    (coerce (/ (max 0d0 sum-of-squared-deviations)
               (if sample-p (1- count) count))
            'double-float)))

(defun %stable-covariance (left right sample-p)
  "Return covariance using an online centered co-moment recurrence."
  (let ((count 0)
        (left-location 0d0)
        (right-location 0d0)
        (co-moment 0d0))
    (loop for index below (length left)
          for left-value = (aref left index)
          for right-value = (aref right index)
          do (incf count)
             (let* ((left-delta (- left-value left-location))
                    (right-delta (- right-value right-location))
                    (updated-left-location
                      (+ left-location (/ left-delta count)))
                    (updated-right-location
                      (+ right-location (/ right-delta count))))
               (incf co-moment
                     (* left-delta
                        (- right-value updated-right-location)))
               (setf left-location updated-left-location
                     right-location updated-right-location)))
    (coerce (/ co-moment (if sample-p (1- count) count))
            'double-float)))

(defun mean (values)
  "Return the arithmetic mean of a non-empty numeric sequence."
  (let ((vector (%as-double-vector values 'values :minimum-length 1)))
    (coerce (/ (%compensated-sum vector)
               (length vector))
            'double-float)))

(defun weighted-mean (values weights)
  "Return a non-negative-weighted arithmetic mean."
  (let ((vector (%as-double-vector values 'values :minimum-length 1))
        (weight-vector (%as-double-vector weights 'weights :minimum-length 1)))
    (%ensure-same-length vector weight-vector 'values 'weights)
    (loop for weight across weight-vector
          when (< weight 0d0)
            do (error 'invalid-argument :name 'weights :value weight))
    (let ((total-weight (%compensated-sum weight-vector)))
      (when (zerop total-weight)
        (error 'numerical-error :operation 'weighted-mean))
      (coerce (/ (%dot-product vector weight-vector) total-weight)
              'double-float))))

(defun sum-of-squares (values)
  "Return the sum of squared observations, without centering."
  (let ((vector (%as-double-vector values 'values :minimum-length 1)))
    (%compensated-sum vector (lambda (value) (* value value)))))

(defun variance (values &key (sample-p t))
  "Return sample variance by default; use SAMPLE-P NIL for population variance."
  (let ((vector (%as-double-vector values
                                   'values
                                   :minimum-length (if sample-p 2 1))))
    (%stable-variance vector sample-p)))

(defun standard-deviation (values &key (sample-p t))
  (sqrt (variance values :sample-p sample-p)))

(defun covariance (left right &key (sample-p t))
  "Return covariance using the same sample/population convention as VARIANCE."
  (let ((left-vector (%as-double-vector left 'left :minimum-length (if sample-p 2 1)))
        (right-vector (%as-double-vector right 'right :minimum-length (if sample-p 2 1))))
    (%ensure-same-length left-vector right-vector 'left 'right)
    (%stable-covariance left-vector right-vector sample-p)))

(defun correlation (left right)
  "Return Pearson correlation, rejecting constant input sequences."
  (let ((left-vector (%as-double-vector left 'left :minimum-length 2))
        (right-vector (%as-double-vector right 'right :minimum-length 2)))
    (%ensure-same-length left-vector right-vector 'left 'right)
    (let ((left-deviation (standard-deviation left-vector))
          (right-deviation (standard-deviation right-vector)))
      (when (or (zerop left-deviation) (zerop right-deviation))
        (error 'numerical-error :operation 'correlation))
      (coerce (/ (covariance left-vector right-vector)
                 (* left-deviation right-deviation))
              'double-float))))

(defun simple-returns (prices)
  "Return arithmetic returns from a positive price sequence."
  (let* ((vector (%as-double-vector prices 'prices :minimum-length 2))
         (result (make-array (1- (length vector))
                             :element-type 'double-float)))
    (loop for index from 1 below (length vector)
          for previous = (aref vector (1- index))
          for current = (aref vector index)
          do (ensure-positive previous 'prices)
             (ensure-positive current 'prices)
             (setf (aref result (1- index))
                   (- (/ current previous) 1d0)))
    result))

(defun log-returns (prices)
  "Return continuously compounded returns from a positive price sequence."
  (let* ((vector (%as-double-vector prices 'prices :minimum-length 2))
         (result (make-array (1- (length vector))
                             :element-type 'double-float)))
    (loop for index from 1 below (length vector)
          for previous = (aref vector (1- index))
          for current = (aref vector index)
          do (ensure-positive previous 'prices)
             (ensure-positive current 'prices)
             (setf (aref result (1- index))
                   (log (/ current previous))))
    result))

(defun cumulative-return (returns)
  "Return the compounded return of a non-empty return sequence."
  (let ((vector (%as-double-vector returns 'returns :minimum-length 1)))
    (let ((wealth 1d0))
      (loop for value across vector
            for growth = (+ 1d0 value)
            do (when (<= growth 0d0)
                 (error 'invalid-argument :name 'returns :value value))
               (setf wealth (* wealth growth)))
      (1- wealth))))

(defun quantile (values probability)
  "Return a linearly interpolated quantile of VALUES."
  (let* ((vector (%as-double-vector values 'values :minimum-length 1))
         (p (ensure-probability probability 'probability))
         (sorted (%sorted-copy vector))
         (position (* p (1- (length sorted))))
         (lower (floor position))
         (upper (min (1- (length sorted)) (1+ lower)))
         (fraction (- position lower)))
    (coerce (+ (aref sorted lower)
               (* fraction (- (aref sorted upper) (aref sorted lower))))
            'double-float)))

(defun median (values)
  (quantile values 0.5d0))
