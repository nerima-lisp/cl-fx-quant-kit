(require :asdf)

(defparameter *benchmark-root*
  (truename
   (merge-pathnames
    "../"
    (uiop:pathname-directory-pathname *load-truename*))))

(asdf:initialize-source-registry
 `(:source-registry (:directory ,(namestring cl-user::*benchmark-root*))
                    :inherit-configuration))
(asdf:load-system "fx-quant-kit")

(in-package #:fx-quant-kit)

(defparameter *benchmark-runs* 3)

(defun %benchmark-series (length phase)
  (let ((result (make-array length :element-type 'double-float)))
    (dotimes (index length result)
      (let ((position (coerce index 'double-float)))
        (setf (aref result index)
              (+ 100d0
                 (* 0.001d0 position)
                 (* 0.25d0 (sin (+ phase (* 0.017d0 position))))
                 (* 0.05d0 (cos (+ (* 0.031d0 position) phase)))))))))

(defun %benchmark-matrix (assets observations)
  (let ((result (make-array assets)))
    (dotimes (asset assets result)
      (setf (aref result asset)
            (%benchmark-series observations (* 0.11d0 asset))))))

(defun %digest-vector (vector)
  (+ (aref vector 0) (aref vector (1- (length vector)))))

(defun %digest-matrix (matrix)
  (+ (aref matrix 0 0)
     (aref matrix (1- (array-dimension matrix 0))
                  (1- (array-dimension matrix 1)))))

(defun %digest-paths (paths)
  (+ (aref (aref paths 0) 0)
     (aref (aref paths (1- (length paths)))
           (1- (length (aref paths (1- (length paths))))))))

(defun %measure (name thunk digest)
  (let ((warmup (funcall thunk)))
    (funcall digest warmup)
    (let* ((start-time (get-internal-real-time))
           (start-bytes (sb-ext:get-bytes-consed))
           (value warmup))
      (dotimes (run (1- *benchmark-runs*))
        (declare (ignore run))
        (setf value (funcall thunk)))
      (let* ((elapsed (- (get-internal-real-time) start-time))
             (bytes (- (sb-ext:get-bytes-consed) start-bytes))
             (elapsed-ms (* 1000d0
                            (/ (coerce elapsed 'double-float)
                               internal-time-units-per-second))))
        (format t "~&~A runs=~D elapsed-ms=~,3F per-run-ms=~,3F bytes-per-run=~D digest=~,17G~%"
                name
                *benchmark-runs*
                elapsed-ms
                (/ elapsed-ms (max 1 (1- *benchmark-runs*)))
                (round (/ bytes (max 1 (1- *benchmark-runs*))))
                (coerce (funcall digest value) 'double-float))))))

(format t "benchmark-source=~A~%" cl-user::*benchmark-root*)

(let ((matrix (%benchmark-matrix 32 4000))
      (series (%benchmark-series 50000 0.37d0))
      (hurst-series (%benchmark-series 2000 0.73d0)))
  (%measure "correlation-matrix"
            (lambda () (correlation-matrix matrix))
            #'%digest-matrix)
  (%measure "bollinger-bands"
            (lambda () (bollinger-bands series 64))
            (lambda (result)
              (+ (or (aref (bollinger-result-upper result) 49999) 0d0)
                 (or (aref (bollinger-result-lower result) 49999) 0d0))))
  (%measure "hurst-exponent"
            (lambda () (hurst-exponent hurst-series))
            #'identity)
  (%measure "simulate-geometric-brownian-motion"
            (lambda ()
              (simulate-geometric-brownian-motion
               100d0 0.04d0 0.2d0 (/ 1d0 252d0) 256 500
               :rng (make-simulation-rng 17)))
            #'%digest-paths))
