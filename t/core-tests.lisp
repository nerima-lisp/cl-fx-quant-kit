(in-package #:fx-quant-kit/test)

(describe "core statistics"
  (it "computes descriptive statistics"
    (let ((values #(1d0 2d0 3d0 4d0)))
      (expect (mean values) :to-be-close-to 2.5d0 10)
      (expect (weighted-mean values #(1d0 1d0 2d0 2d0))
              :to-be-close-to 2.8333333333d0 10)
      (expect (sum-of-squares values) :to-be-close-to 30d0 10)
      (expect (variance values) :to-be-close-to 1.6666666667d0 8)
      (expect (variance values :sample-p nil) :to-be-close-to 1.25d0 10)
      (expect (standard-deviation values) :to-be-close-to 1.2909944487d0 8)))

  (it "computes covariance and correlation"
    (expect (covariance #(1d0 2d0 3d0) #(2d0 4d0 8d0))
            :to-be-close-to 3d0 10)
    (expect (correlation #(1d0 2d0 3d0) #(2d0 4d0 8d0))
            :to-be-close-to 0.9819805061d0 8))

  (it "computes return transforms"
    (expect-vector-close (simple-returns #(100d0 110d0 99d0))
                         #(0.1d0 -0.1d0) 10)
    (expect-vector-close (log-returns #(100d0 110d0 99d0))
                         #(0.0953101798d0 -0.1053605157d0) 8)
    (expect (cumulative-return #(0.1d0 -0.1d0))
            :to-be-close-to -0.01d0 10))

  (it "computes quantiles and medians"
    (expect (quantile #(4d0 1d0 3d0 2d0) 0.25d0)
            :to-be-close-to 1.75d0 10)
    (expect (median #(4d0 1d0 3d0 2d0)) :to-be-close-to 2.5d0 10)
    (expect (quantile #(4d0 1d0 3d0 2d0) 0d0) :to-be 1d0)
    (expect (quantile #(4d0 1d0 3d0 2d0) 1d0) :to-be 4d0))

  (it "rejects empty data"
    (signals insufficient-data (mean #()))
    (signals invalid-argument (quantile #(1d0 2d0) 1.1d0))))
