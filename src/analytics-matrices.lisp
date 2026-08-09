(in-package #:fx-quant-kit)

(defun %as-series (series name &key (minimum-length 1))
  (unless (typep series 'sequence)
    (error 'invalid-argument :name name :value series))
  (let* ((source (coerce series 'vector))
         (count (length source)))
    (when (zerop count)
      (error 'insufficient-data :required 1 :actual 0))
    (let ((result (make-array count)))
      (loop for index below count
            do (setf (aref result index)
                     (%as-double-vector (aref source index)
                                        name
                                        :minimum-length minimum-length)))
      (let ((observations (length (aref result 0))))
        (loop for index from 1 below count
              for actual = (length (aref result index))
              unless (= actual observations)
                do (error 'invalid-shape
                          :expected (list name 'same-length observations)
                          :actual (list name index actual))))
      result)))

(defun covariance-matrix (series &key (sample-p t))
  "Return a symmetric covariance matrix for asset SERIES.

SERIES is a sequence of observation sequences, one sequence per asset."
  (let* ((vectors (%as-series series
                               'series
                               :minimum-length (if sample-p 2 1)))
         (count (length vectors))
         (matrix (make-array (list count count)
                             :element-type 'double-float)))
    (loop for row below count
          do (loop for column from row below count
                   for value = (%stable-covariance
                                (aref vectors row)
                                (aref vectors column)
                                sample-p)
                   do (setf (aref matrix row column) value
                            (aref matrix column row) value)))
    matrix))

(defun correlation-matrix (series)
  "Return a symmetric Pearson correlation matrix for asset SERIES."
  (let* ((vectors (%as-series series 'series :minimum-length 2))
         (count (length vectors))
         (deviations (make-array count :element-type 'double-float))
         (matrix (make-array (list count count)
                             :element-type 'double-float)))
    (loop for index below count
          for deviation = (sqrt (%stable-variance (aref vectors index) t))
          do (when (zerop deviation)
               (error 'numerical-error
                      :operation 'correlation-matrix))
             (setf (aref deviations index) deviation))
    (loop for row below count
          do (loop for column from row below count
                   do (let ((value (/ (%stable-covariance
                                       (aref vectors row)
                                       (aref vectors column)
                                       t)
                                       (* (aref deviations row)
                                          (aref deviations column)))))
                        (setf (aref matrix row column) value
                              (aref matrix column row) value))))
    matrix))
