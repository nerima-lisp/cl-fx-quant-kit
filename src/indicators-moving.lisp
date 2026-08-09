(in-package #:fx-quant-kit)

(defun %moving-average (values period smoothing)
  (let* ((vector (%as-double-vector values 'values :minimum-length period))
         (length (length vector))
         (result (make-array length :initial-element nil))
         (initial (loop for index below period
                        sum (aref vector index) into total of-type double-float
                        finally (return total))))
    (setf (aref result (1- period)) (/ initial period))
    (loop for index from period below length
          for previous = (aref result (1- index))
          do (setf (aref result index)
                   (+ previous
                      (* smoothing (- (aref vector index) previous)))))
    result))

(defun sma (values period)
  "Return a simple moving average with NIL during the warm-up window."
  (let* ((vector (%as-double-vector values 'values :minimum-length 1))
         (window (%require-period period (length vector)))
         (result (make-array (length vector) :initial-element nil))
         (rolling 0d0))
    (loop for index below (length vector)
          do (incf rolling (aref vector index))
             (when (>= index window)
               (decf rolling (aref vector (- index window))))
             (when (>= index (1- window))
               (setf (aref result index) (/ rolling window))))
    result))

(defun ema (values period)
  "Return an EMA seeded by the SMA of the first PERIOD observations."
  (%moving-average values period (/ 2d0 (1+ period))))

(defun wilder-average (values period)
  "Return Wilder's smoothed moving average with an SMA seed."
  (%moving-average values period (/ 1d0 period)))

(defun rsi (prices period)
  "Return Wilder RSI values in [0, 100], with NIL during warm-up."
  (let* ((vector (%as-double-vector prices 'prices :minimum-length 2))
         (window (%require-period period (1- (length vector))))
         (result (make-array (length vector) :initial-element nil))
         (gains (make-array window :element-type 'double-float))
         (losses (make-array window :element-type 'double-float)))
    (loop for index from 1 to window
          for change = (- (aref vector index) (aref vector (1- index)))
          do (setf (aref gains (1- index)) (max 0d0 change)
                   (aref losses (1- index)) (max 0d0 (- change))))
    (let ((average-gain (mean gains))
          (average-loss (mean losses)))
      (labels ((value ()
                 (cond ((and (zerop average-gain) (zerop average-loss)) 50d0)
                       ((zerop average-loss) 100d0)
                       (t (- 100d0 (/ 100d0
                                        (+ 1d0 (/ average-gain average-loss))))))))
        (setf (aref result window) (value))
        (loop for index from (1+ window) below (length vector)
              for change = (- (aref vector index) (aref vector (1- index)))
              for gain = (max 0d0 change)
              for loss = (max 0d0 (- change))
              do (setf average-gain
                       (+ (* (/ (1- period) period) average-gain)
                          (* (/ 1d0 period) gain))
                       average-loss
                       (+ (* (/ (1- period) period) average-loss)
                          (* (/ 1d0 period) loss))
                       (aref result index) (value)))))
    result))
