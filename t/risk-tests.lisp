(in-package #:fx-quant-kit/test)

(describe "risk metrics and sizing"
  (it "computes historical and parametric tail risk"
    (let ((returns #(-0.2d0 -0.1d0 0d0 0.02d0 0.05d0)))
      (expect (historical-var returns 0.8d0 :notional 100d0)
              :to-be-close-to 12d0 10)
      (expect (historical-expected-shortfall returns 0.8d0 :notional 100d0)
              :to-be-close-to 20d0 10)
      (expect (parametric-var 0d0 0.1d0 0.95d0)
              :to-be-close-to 0.1644853627d0 7)
      (expect (parametric-expected-shortfall 0d0 0.1d0 0.95d0)
              :to-be-close-to 0.2062712808d0 7)))

  (it "computes sizing rules"
    (expect (kelly-fraction 0.6d0 2d0) :to-be-close-to 0.4d0 10)
    (expect (volatility-target-position 0.1d0 0.2d0)
            :to-be-close-to 0.5d0 10)
    (expect (volatility-target-position 0.1d0 0d0 :max-leverage 2d0)
            :to-be-close-to 2d0 10))

  (it "computes drawdowns, portfolio variance, and stress loss"
    (let ((wealth #(100d0 120d0 90d0 110d0)))
      (expect-vector-close (drawdown-series wealth)
                           #(0d0 0d0 0.25d0 0.0833333333d0) 8)
      (expect (max-drawdown wealth) :to-be-close-to 0.25d0 10))
    (expect (portfolio-variance #(0.5d0 0.5d0)
                                #2A((0.04d0 0.01d0)
                                    (0.01d0 0.09d0)))
            :to-be-close-to 0.0375d0 10)
    (expect (stress-loss #(100d0 -50d0) #(-0.1d0 0.02d0))
            :to-be-close-to 11d0 10))

  (it "rejects invalid confidence levels"
    (signals invalid-argument (historical-var #(0d0) 0d0))
    (signals invalid-argument (parametric-var 0d0 1d0 1d0))))
