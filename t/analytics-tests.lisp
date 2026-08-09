(in-package #:fx-quant-kit/test)

(describe "portfolio analytics"
  (it "computes standardized shape statistics"
    (expect (skewness #(1d0 2d0 3d0)) :to-be-close-to 0d0 12)
    (expect (skewness #(1d0 2d0 3d0) :bias-corrected-p t)
            :to-be-close-to 0d0 12)
    (expect (excess-kurtosis #(1d0 2d0 3d0 4d0))
            :to-be-close-to -1.36d0 10)
    (expect (excess-kurtosis #(1d0 2d0 3d0 4d0) :bias-corrected-p t)
            :to-be-close-to -1.2d0 10))

  (it "computes annualized ratios and beta"
    (expect (sharpe-ratio #(0.01d0 0.02d0 0.03d0)
                          :periods-per-year 4d0)
            :to-be-close-to 4d0 10)
    (expect (sortino-ratio #(0.01d0 0.02d0 0.03d0)
                           :target-return 0.015d0
                           :periods-per-year 4d0)
            :to-be-close-to 3.4641016151d0 8)
    (expect (beta #(0.01d0 0.02d0 0.03d0)
                  #(0.005d0 0.01d0 0.015d0))
            :to-be-close-to 2d0 10)
    (expect (tracking-error #(0.011d0 0.021d0 0.029d0)
                             #(0.01d0 0.02d0 0.03d0)
                             :periods-per-year 4d0)
            :to-be-close-to 0.0023094011d0 7)
    (expect (information-ratio #(0.011d0 0.021d0 0.029d0)
                               #(0.01d0 0.02d0 0.03d0)
                               :periods-per-year 4d0)
            :to-be-close-to 0.5773502692d0 7))

  (it "computes covariance and correlation matrices"
    (let ((series #(#(1d0 2d0 3d0)
                    #(2d0 4d0 6d0))))
      (let ((covariance (covariance-matrix series))
            (correlation (correlation-matrix series)))
        (expect (array-dimension covariance 0) :to-be 2)
        (expect (array-dimension covariance 1) :to-be 2)
        (expect (aref covariance 0 0) :to-be-close-to 1d0 10)
        (expect (aref covariance 0 1) :to-be-close-to 2d0 10)
        (expect (aref covariance 1 1) :to-be-close-to 4d0 10)
        (expect (aref correlation 0 0) :to-be-close-to 1d0 10)
        (expect (aref correlation 0 1) :to-be-close-to 1d0 10)
        (expect (aref correlation 1 1) :to-be-close-to 1d0 10))))

  (it "rejects degenerate analytics inputs"
    (signals numerical-error
             (skewness #(1d0 1d0 1d0)))
    (signals numerical-error
             (sharpe-ratio #(0.01d0 0.01d0)))
    (signals numerical-error
             (information-ratio #(0.01d0 0.02d0)
                                #(0.01d0 0.02d0)))
    (signals invalid-shape
             (covariance-matrix #(#(1d0 2d0) #(1d0 2d0 3d0))))
    (signals numerical-error
             (correlation-matrix #(#(1d0 1d0) #(1d0 2d0)))))

  (it "retains numerical stability for large locations"
    (expect (variance #(1000000000000d0
                        1000000000001d0
                        1000000000002d0))
            :to-be-close-to 1d0 8)
    (expect (covariance #(1000000000000d0
                          1000000000001d0
                          1000000000002d0)
                        #(2000000000000d0
                          2000000000002d0
                          2000000000004d0))
            :to-be-close-to 2d0 8))

  (it "exposes analytics through the continuation interface"
    (with-cps-result (value sharpe-ratio/k
                            #(0.01d0 0.02d0 0.03d0)
                            :periods-per-year 4d0)
      (expect value :to-be-close-to 4d0 10))
    (with-cps-result (matrix covariance-matrix/k
                            #(#(1d0 2d0) #(2d0 4d0)))
      (expect (aref matrix 0 1) :to-be-close-to 1d0 10))))
