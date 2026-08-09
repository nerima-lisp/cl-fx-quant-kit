(in-package #:fx-quant-kit/test)

(describe "probability distributions"
  (it "evaluates the standard normal distribution"
    (expect (normal-pdf 0d0) :to-be-close-to 0.3989422804d0 8)
    (expect (normal-cdf 0d0) :to-be-close-to 0.5d0 7)
    (expect (normal-cdf 1.9599639845d0) :to-be-close-to 0.975d0 6))

  (it "inverts the normal CDF"
    (let ((quantile-value (inverse-normal-cdf 0.975d0)))
      (expect quantile-value :to-be-close-to 1.9599639845d0 5)
      (expect (normal-cdf quantile-value) :to-be-close-to 0.975d0 8)))

  (it "rejects invalid distribution arguments"
    (signals invalid-argument
      (normal-pdf 0d0 :standard-deviation -1d0))
    (signals invalid-argument (inverse-normal-cdf 0d0))
    (signals invalid-argument (inverse-normal-cdf 1d0))))
