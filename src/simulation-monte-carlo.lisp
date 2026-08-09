(in-package #:fx-quant-kit)

(defun monte-carlo-estimate (sampler sample-count
                             &key (rng (make-simulation-rng 1)))
  "Estimate a scalar sampler's mean, standard error, and sample variance.

SAMPLER receives the explicit simulation RNG and must return one finite
numeric sample.  The return values are MEAN, STANDARD-ERROR, and VARIANCE."
  (unless (functionp sampler)
    (error 'invalid-argument :name 'sampler :value sampler))
  (unless (and (integerp sample-count) (>= sample-count 2))
    (error 'invalid-argument :name 'sample-count :value sample-count))
  (%ensure-rng rng)
  (let ((mean 0d0)
        (sum-of-squares 0d0))
    (dotimes (index sample-count)
      (let* ((sample (ensure-finite (funcall sampler rng) 'sample))
             (count (1+ index))
             (delta (- sample mean)))
        (setf mean (+ mean (/ delta count))
              sum-of-squares (+ sum-of-squares (* delta (- sample mean))))))
    (let* ((variance (/ sum-of-squares (1- sample-count)))
           (standard-error (sqrt (/ variance sample-count))))
      (values mean standard-error variance))))
