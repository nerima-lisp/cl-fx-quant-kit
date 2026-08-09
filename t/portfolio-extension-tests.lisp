(in-package #:fx-quant-kit/test)

(describe "portfolio volatility and risk contributions"
  (it "computes volatility and component variance contributions"
    (let* ((weights #(0.5d0 0.5d0))
           (covariance #2A((0.04d0 0.01d0)
                           (0.01d0 0.09d0)))
           (contributions (portfolio-risk-contributions weights covariance)))
      (expect (portfolio-variance weights covariance)
              :to-be-close-to 0.0375d0 10)
      (expect (portfolio-volatility weights covariance)
              :to-be-close-to (sqrt 0.0375d0) 10)
      (expect (aref contributions 0) :to-be-close-to 0.0125d0 10)
      (expect (aref contributions 1) :to-be-close-to 0.025d0 10)
      (expect (+ (aref contributions 0) (aref contributions 1))
              :to-be-close-to 0.0375d0 10)))

  (it "rejects malformed and negative-variance inputs"
    (signals invalid-shape
      (portfolio-volatility #(1d0 1d0)
                            #2A((1d0 0d0 0d0)
                                (0d0 1d0 0d0))))
    (signals invalid-shape
      (portfolio-risk-contributions #(1d0 1d0)
                                    (vector #(1d0 0d0)
                                            #(0d0))))
    (signals numerical-error
      (portfolio-volatility #(1d0) #2A((-1d0))))))
