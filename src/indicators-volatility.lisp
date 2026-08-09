(in-package #:fx-quant-kit)

(defun bollinger-bands (values period &key (deviations 2d0))
  "Return SMA-centered bands using population rolling standard deviation."
  (let* ((vector (%as-double-vector values 'values :minimum-length 1))
         (window (%require-period period (length vector)))
         (width (ensure-non-negative deviations 'deviations))
         (middle (sma vector window))
         (upper (make-array (length vector) :initial-element nil))
         (lower (make-array (length vector) :initial-element nil)))
    (loop for index from (1- window) below (length vector)
          for location = (aref middle index)
          for deviation = (sqrt
                           (/ (loop for offset below window
                                    for value = (aref vector (- index offset))
                                    sum (expt (- value location) 2)
                                      into total of-type double-float
                                    finally (return total))
                              window))
          do (setf (aref upper index) (+ location (* width deviation))
                   (aref lower index) (- location (* width deviation))))
    (%make-bollinger-result middle upper lower)))

(defun true-range (bars)
  "Return true ranges from OHLCV bars, using the first bar's high-low range."
  (let* ((vector (coerce bars 'vector))
         (length (length vector)))
    (when (zerop length)
      (error 'insufficient-data :required 1 :actual 0))
    (let ((result (make-array length :element-type 'double-float)))
      (loop for index below length
            do (let* ((bar (aref vector index))
                      (previous-close
                        (and (plusp index)
                             (ohlcv-bar-close (aref vector (1- index))))))
                 (unless (ohlcv-bar-p bar)
                   (error 'invalid-argument :name 'bars :value bar))
                 (setf (aref result index)
                       (if (zerop index)
                           (- (ohlcv-bar-high bar) (ohlcv-bar-low bar))
                           (max (- (ohlcv-bar-high bar) (ohlcv-bar-low bar))
                                (abs (- (ohlcv-bar-high bar) previous-close))
                                (abs (- (ohlcv-bar-low bar) previous-close)))))))
      result)))

(defun atr (bars period)
  "Return Wilder ATR values with NIL during warm-up."
  (wilder-average (true-range bars) period))

(defun realized-volatility (returns &key (annualization-factor 252d0))
  "Return annualized realized volatility from arithmetic or log returns."
  (let ((vector (%as-double-vector returns 'returns :minimum-length 1))
        (factor (ensure-positive annualization-factor 'annualization-factor)))
    (sqrt (* factor
             (/ (loop for value across vector
                      sum (* value value) into total of-type double-float
                      finally (return total))
                (length vector))))))
