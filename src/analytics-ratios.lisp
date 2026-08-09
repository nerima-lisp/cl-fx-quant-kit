(in-package #:fx-quant-kit)

(defun %excess-return-vector (values rate name)
  (let* ((vector (%as-double-vector values name :minimum-length 1))
         (result (make-array (length vector)
                             :element-type 'double-float)))
    (loop for index below (length vector)
          do (setf (aref result index)
                   (- (aref vector index) rate)))
    result))

(defun %ensure-periods-per-year (periods-per-year)
  (ensure-positive periods-per-year 'periods-per-year))

(defun sharpe-ratio (returns &key (risk-free-rate 0d0)
                                 (periods-per-year 1d0))
  "Return the annualized arithmetic Sharpe ratio.

RETURNS and RISK-FREE-RATE are expressed per observation.  The denominator is
sample standard deviation and PERIODS-PER-YEAR annualizes the ratio."
  (let* ((rate (ensure-finite risk-free-rate 'risk-free-rate))
         (periods (%ensure-periods-per-year periods-per-year))
         (excess (%excess-return-vector returns rate 'returns))
         (deviation (%require-non-constant
                     (standard-deviation excess)
                     'sharpe-ratio)))
    (coerce (/ (* (mean excess) (sqrt periods)) deviation)
            'double-float)))

(defun sortino-ratio (returns &key (target-return 0d0)
                                  (periods-per-year 1d0))
  "Return an annualized target-based Sortino ratio.

Downside deviation is the population root mean square of shortfalls below
TARGET-RETURN.  The numerator uses the arithmetic mean return minus the same
target return."
  (let* ((target (ensure-finite target-return 'target-return))
         (periods (%ensure-periods-per-year periods-per-year))
         (vector (%as-double-vector returns 'returns :minimum-length 1))
         (downside (make-array (length vector)
                               :element-type 'double-float)))
    (loop for index below (length vector)
          for shortfall = (max 0d0 (- target (aref vector index)))
          do (setf (aref downside index) (* shortfall shortfall)))
    (let ((deviation (sqrt (/ (%compensated-sum downside)
                              (length downside)))))
      (%require-non-constant deviation 'sortino-ratio)
      (coerce (/ (* (- (mean vector) target) (sqrt periods))
                 deviation)
              'double-float))))

(defun beta (returns benchmark &key (sample-p t))
  "Return the covariance beta of RETURNS against BENCHMARK."
  (let ((return-vector (%as-double-vector returns
                                           'returns
                                           :minimum-length (if sample-p 2 1)))
        (benchmark-vector (%as-double-vector benchmark
                                               'benchmark
                                               :minimum-length (if sample-p 2 1))))
    (%ensure-same-length return-vector benchmark-vector 'returns 'benchmark)
    (let ((benchmark-variance (%require-non-constant
                               (%stable-variance benchmark-vector sample-p)
                               'beta)))
      (coerce (/ (%stable-covariance return-vector benchmark-vector sample-p)
                 benchmark-variance)
              'double-float))))

(defun %active-returns (returns benchmark)
  (let ((return-vector (%as-double-vector returns 'returns :minimum-length 2))
        (benchmark-vector (%as-double-vector benchmark
                                               'benchmark
                                               :minimum-length 2)))
    (%ensure-same-length return-vector benchmark-vector 'returns 'benchmark)
    (let ((active (make-array (length return-vector)
                              :element-type 'double-float)))
      (loop for index below (length active)
            do (setf (aref active index)
                     (- (aref return-vector index)
                        (aref benchmark-vector index))))
      active)))

(defun tracking-error (returns benchmark &key (periods-per-year 1d0))
  "Return annualized sample tracking error for two return series."
  (let* ((periods (%ensure-periods-per-year periods-per-year))
         (active (%active-returns returns benchmark)))
    (coerce (* (standard-deviation active) (sqrt periods))
            'double-float)))

(defun information-ratio (returns benchmark &key (periods-per-year 1d0))
  "Return the annualized information ratio of RETURNS versus BENCHMARK."
  (let* ((periods (%ensure-periods-per-year periods-per-year))
         (active (%active-returns returns benchmark))
         (deviation (%require-non-constant
                     (standard-deviation active)
                     'information-ratio)))
    (coerce (/ (* (mean active) (sqrt periods)) deviation)
            'double-float)))
