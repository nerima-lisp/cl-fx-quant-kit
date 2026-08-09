(in-package #:fx-quant-kit)

(defun %ensure-confidence (confidence)
  (let ((value (ensure-probability confidence 'confidence)))
    (unless (and (> value 0d0) (< value 1d0))
      (error 'invalid-argument :name 'confidence :value confidence))
    value))

(defun historical-var (returns confidence &key (notional 1d0))
  "Return positive historical VaR from the lower return tail.

RETURNS are arithmetic or log returns. CONFIDENCE is the tail confidence,
for example 0.99. NOTIONAL scales the result into account-currency units."
  (let* ((sample (%as-double-vector returns 'returns :minimum-length 1))
         (level (%ensure-confidence confidence))
         (scale (ensure-positive notional 'notional))
         (threshold (quantile sample (- 1d0 level))))
    (* scale (max 0d0 (- threshold)))))

(defun historical-expected-shortfall (returns confidence &key (notional 1d0))
  "Return positive historical expected shortfall at CONFIDENCE.

The empirical lower tail is defined by the interpolated VaR threshold. If no
observation is strictly below that threshold, the threshold itself is used."
  (let* ((sample (%as-double-vector returns 'returns :minimum-length 1))
         (level (%ensure-confidence confidence))
         (scale (ensure-positive notional 'notional))
         (threshold (quantile sample (- 1d0 level)))
         (tail-count 0)
         (tail-sum 0d0)
         (tail-correction 0d0))
    (loop for value across sample
          when (<= value threshold)
            do (incf tail-count)
               (let ((next (+ tail-sum value)))
                 (if (>= (abs tail-sum) (abs value))
                     (incf tail-correction
                           (+ (- tail-sum next) value))
                     (incf tail-correction
                           (+ (- value next) tail-sum)))
                 (setf tail-sum next)))
    (* scale
       (max 0d0
            (- (if (plusp tail-count)
                   (/ (+ tail-sum tail-correction) tail-count)
                   threshold))))))

(defun parametric-var (mean-return volatility confidence &key (notional 1d0))
  "Return positive normal-parametric VaR from return parameters."
  (let* ((location (ensure-finite mean-return 'mean-return))
         (deviation (ensure-non-negative volatility 'volatility))
         (level (%ensure-confidence confidence))
         (scale (ensure-positive notional 'notional))
         (quantile-value (+ location
                            (* deviation
                               (inverse-normal-cdf (- 1d0 level))))))
    (* scale (max 0d0 (- quantile-value)))))

(defun parametric-expected-shortfall (mean-return volatility confidence
                                      &key (notional 1d0))
  "Return positive normal-parametric expected shortfall."
  (let* ((location (ensure-finite mean-return 'mean-return))
         (deviation (ensure-non-negative volatility 'volatility))
         (level (%ensure-confidence confidence))
         (scale (ensure-positive notional 'notional))
         (tail-probability (- 1d0 level))
         (z (inverse-normal-cdf tail-probability))
         (tail-mean (- location
                       (* deviation
                          (/ (normal-pdf z) tail-probability)))))
    (* scale (max 0d0 (- tail-mean)))))

(defun kelly-fraction (win-probability win-loss-ratio)
  "Return the full Kelly fraction for a binary payoff.

WIN-LOSS-RATIO is the positive profit per unit loss. The result is not
clipped, allowing callers to inspect negative edge or apply their own cap."
  (let ((probability (ensure-probability win-probability 'win-probability))
        (ratio (ensure-positive win-loss-ratio 'win-loss-ratio)))
    (- probability (/ (- 1d0 probability) ratio))))

(defun volatility-target-position (target-volatility current-volatility
                                   &key (max-leverage 1d0))
  "Return a leverage multiplier targeting a desired volatility."
  (let ((target (ensure-positive target-volatility 'target-volatility))
        (current (ensure-non-negative current-volatility 'current-volatility))
        (cap (ensure-positive max-leverage 'max-leverage)))
    (min cap (if (zerop current) cap (/ target current)))))

(defun drawdown-series (wealth)
  "Return non-negative percentage drawdowns from an equity/wealth series."
  (let* ((values (%as-double-vector wealth 'wealth :minimum-length 1))
         (result (make-array (length values) :element-type 'double-float))
         (peak 0d0))
    (loop for index below (length values)
          for value = (aref values index)
          do (ensure-positive value 'wealth)
             (setf peak (max peak value)
                   (aref result index) (- 1d0 (/ value peak))))
    result))

(defun max-drawdown (wealth)
  "Return the maximum percentage drawdown of a wealth series."
  (let ((values (%as-double-vector wealth 'wealth :minimum-length 1))
        (peak 0d0)
        (maximum 0d0))
    (loop for value across values
          do (ensure-positive value 'wealth)
             (setf peak (max peak value)
                   maximum (max maximum (- 1d0 (/ value peak)))))
    maximum))

(defun %ensure-covariance-matrix (matrix dimension)
  (unless (and (arrayp matrix)
               (= (array-rank matrix) 2)
               (= (array-dimension matrix 0) dimension)
               (= (array-dimension matrix 1) dimension))
    (error 'invalid-shape
           :expected (list dimension dimension)
           :actual (if (arrayp matrix)
                       (array-dimensions matrix)
                       matrix)))
  matrix)

(defun portfolio-variance (weights covariance-matrix)
  "Return w'Σw for a vector of weights and a square covariance matrix."
  (let* ((weight-vector (%as-double-vector weights 'weights :minimum-length 1))
         (dimension (length weight-vector))
         (matrix (%ensure-covariance-matrix covariance-matrix dimension)))
    (let ((result 0d0))
      (loop for row below dimension
            do (loop for column below dimension
                     do (incf result
                              (* (aref weight-vector row)
                                 (ensure-finite (aref matrix row column)
                                                'covariance-matrix)
                                 (aref weight-vector column)))))
      result)))

(defun stress-loss (positions shocks)
  "Return the positive loss from an aligned position/shock scenario."
  (let* ((exposures (%as-double-vector positions 'positions :minimum-length 1))
         (moves (%as-double-vector shocks 'shocks :minimum-length 1)))
    (%ensure-same-length exposures moves 'positions 'shocks)
    (max 0d0 (- (%dot-product exposures moves)))))
