(in-package #:fx-quant-kit)

(defun macd (values &key (fast-period 12) (slow-period 26) (signal-period 9))
  "Return aligned MACD line, signal, and histogram vectors."
  (unless (< fast-period slow-period)
    (error 'invalid-argument :name 'fast-period :value fast-period))
  (let* ((vector (%as-double-vector values 'values :minimum-length slow-period))
         (length (length vector))
         (fast (ema vector fast-period))
         (slow (ema vector slow-period))
         (line (make-array length :initial-element nil))
         (valid-count (- length (1- slow-period)))
         (valid-line (make-array valid-count :element-type 'double-float)))
    (loop for index from (1- slow-period) below length
          for valid-index from 0
          do (setf (aref line index)
                   (- (aref fast index) (aref slow index))
                   (aref valid-line valid-index) (aref line index)))
    (let* ((valid-signal (ema valid-line signal-period))
           (signal (make-array length :initial-element nil))
           (histogram (make-array length :initial-element nil)))
      (loop for index from (1- slow-period) below length
            for valid-index from 0
            when (aref valid-signal valid-index)
              do (setf (aref signal index) (aref valid-signal valid-index)
                       (aref histogram index)
                       (- (aref line index) (aref signal index))))
      (%make-macd-result line signal histogram))))
