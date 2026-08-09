(in-package #:fx-quant-kit/test)

(describe "Monte Carlo estimation"
  (it "returns exact moments for a constant sampler"
    (multiple-value-bind (mean standard-error variance)
        (monte-carlo-estimate
         (lambda (rng)
           (declare (ignore rng))
           3d0)
         8)
      (expect mean :to-be-close-to 3d0 10)
      (expect standard-error :to-be-close-to 0d0 10)
      (expect variance :to-be-close-to 0d0 10)))

  (it "is reproducible with an explicit RNG"
    (flet ((sample (rng) (rng-normal rng)))
      (multiple-value-bind (mean-left error-left variance-left)
          (monte-carlo-estimate #'sample 32
                                :rng (make-simulation-rng 77))
        (multiple-value-bind (mean-right error-right variance-right)
            (monte-carlo-estimate #'sample 32
                                  :rng (make-simulation-rng 77))
          (expect mean-left :to-be-close-to mean-right 15)
          (expect error-left :to-be-close-to error-right 15)
          (expect variance-left :to-be-close-to variance-right 15)))))

  (it "rejects invalid samplers, sample counts, and RNGs"
    (signals invalid-argument (monte-carlo-estimate nil 2))
    (signals invalid-argument
      (monte-carlo-estimate (lambda (rng) (declare (ignore rng)) 1d0) 1))
    (signals invalid-argument
      (monte-carlo-estimate (lambda (rng) (declare (ignore rng)) 1d0)
                            2 :rng nil))))
