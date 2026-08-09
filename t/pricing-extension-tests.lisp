(in-package #:fx-quant-kit/test)

(describe "pricing contracts and discounting"
  (it "prices contracts and computes signed intrinsic payoffs"
    (let* ((contract (make-option-contract :call 100d0 1d0))
           (put (make-option-contract :put 100d0 1d0))
           (direct (black-scholes-price 100d0 100d0 1d0 0.2d0 0.05d0))
           (greeks (option-contract-greeks contract 100d0 0.2d0 0.05d0))
           (scaled (option-contract-greeks contract 100d0 0.2d0 0.05d0
                                           :quantity 2d0)))
      (expect (option-contract-payoff contract 110d0)
              :to-be-close-to 10d0 10)
      (expect (option-contract-payoff put 90d0)
              :to-be-close-to 10d0 10)
      (expect (option-contract-payoff contract 110d0 :quantity -2d0)
              :to-be-close-to -20d0 10)
      (expect (option-contract-price contract 100d0 0.2d0 0.05d0)
              :to-be-close-to direct 10)
      (expect (greeks-price greeks) :to-be-close-to direct 10)
      (expect (greeks-price scaled) :to-be-close-to (* 2d0 direct) 10)
      (signals invalid-argument (make-option-contract :straddle 100d0 1d0))
      (signals invalid-argument
        (option-contract-payoff contract 0d0))))

  (it "discounts cash flows and builds forwards"
    (expect (discount-factor 0.05d0 1d0)
            :to-be-close-to 0.9512294245d0 9)
    (expect (present-value 100d0 0.05d0 1d0)
            :to-be-close-to 95.12294245d0 8)
    (expect (forward-price 100d0 0.05d0 1d0)
            :to-be-close-to 105.12710964d0 8)
    (signals invalid-argument (discount-factor 0d0 -1d0))))
