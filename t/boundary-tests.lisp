(in-package #:fx-quant-kit/test)

(describe "boundary contracts"
  (it "covers statistical optional modes and invalid domains"
    (let ((values #(1d0 2d0 4d0)))
      (expect (numberp (skewness values :bias-corrected-p t)) :to-be t)
      (expect (numberp (excess-kurtosis #(1d0 2d0 4d0 8d0)
                                        :bias-corrected-p t))
              :to-be t)
      (expect (variance #(1d0) :sample-p nil) :to-be-close-to 0d0 12)
      (expect (weighted-mean #(1d0 2d0) #(1d0 3d0))
              :to-be-close-to 1.75d0 12)
      (signals insufficient-data (variance #(1d0)))
      (signals invalid-shape
        (weighted-mean #(1d0 2d0) #(1d0)))
      (signals invalid-argument
        (weighted-mean #(1d0 2d0) #(-1d0 1d0)))
      (signals invalid-argument (simple-returns #(1d0 0d0)))
      (signals invalid-argument (cumulative-return #(-1d0)))
      (signals numerical-error
        (sortino-ratio #(1d0 2d0) :target-return 0d0))
      (signals invalid-argument
        (sharpe-ratio #(1d0 2d0) :periods-per-year 0d0))
      (signals insufficient-data (beta #(1d0 2d0) #(1d0)))))
  (it "covers market values, defaults, time guards, and serialization guards"
    (let* ((quote (make-market-quote 0 1d0 1.1d0))
           (tick (make-tick-data 0 1d0 1.1d0))
           (iso (timestamp->iso8601 0)))
      (expect (market-quote-mid quote) :to-be-close-to 1.05d0 12)
      (expect (tick-data-total-size tick) :to-be-close-to 0d0 12)
      (expect (tick-data-imbalance tick) :to-be-close-to 0d0 12)
      (expect (stringp iso) :to-be t)
      (expect (iso8601->timestamp iso) :to-be 0)
      (signals invalid-argument (market-quote-mid nil))
      (signals invalid-argument (tick-data-mid nil))
      (signals invalid-argument (make-market-quote 0 2d0 1d0))
      (signals invalid-argument (make-tick-data -1 1d0 1.1d0))
      (signals invalid-argument
        (make-ohlcv-bar 0 1d0 0.5d0 0.9d0 1d0 1d0))
      (signals invalid-argument (timestamp->instant -1))
      (signals invalid-argument (timestamp->instant 1d0))
      (signals invalid-argument (instant->timestamp nil))
      (signals invalid-argument (iso8601->timestamp nil))
      (signals invalid-argument (market-quote->json nil))
      (signals invalid-argument (json->market-quote "[]"))))
  (it "covers FX direction and conversion branches"
    (let* ((eur-usd (make-currency-pair "EUR" "USD"))
           (usd-jpy (make-currency-pair "USD" "JPY")))
      (expect (fx-cross-rate eur-usd 1.1d0 usd-jpy 150d0)
              :to-be-close-to 165d0 12)
      (expect (fx-forward-points eur-usd 1.1d0 0.02d0 0.01d0 1d0)
              :to-be-close-to 0.0110551838d0 8)
      (expect (fx-pip-distance eur-usd 1.1d0 1.101d0)
              :to-be-close-to 10d0 10)
      (expect (fx-pnl eur-usd 100000d0 1.1d0 1.09d0
                      :side :short :quote-to-account-rate 2d0)
              :to-be-close-to 2000d0 10)
      (signals invalid-argument (make-currency-pair 42 "USD"))
      (signals invalid-argument (fx-cross-rate nil 1d0 usd-jpy 1d0))))
  (it "covers option boundaries, bracket failures, and discount guards"
    (let* ((contract (make-option-contract :put 100d0 1d0))
           (price (black-scholes-price 100d0 100d0 1d0 0.2d0 0.05d0)))
      (expect (option-contract-payoff contract 90d0)
              :to-be-close-to 10d0 12)
      (expect (discount-factor 0d0 0d0) :to-be-close-to 1d0 12)
      (expect (present-value 100d0 0d0 0d0) :to-be-close-to 100d0 12)
      (expect (forward-price 100d0 0d0 0d0) :to-be-close-to 100d0 12)
      (signals invalid-argument (option-contract-payoff nil 100d0))
      (signals invalid-argument
        (option-contract-price contract 0d0 0.2d0 0.05d0))
      (signals invalid-argument (discount-factor "rate" 1d0))
      (signals invalid-argument (forward-price 0d0 0d0 0d0))
      (signals numerical-error
        (implied-volatility price 100d0 100d0 1d0 0.05d0
                            :lower-bound 0.01d0
                            :upper-bound 1d0
                            :tolerance 1d-20
                            :max-iterations 1))))
  (it "covers risk guardrail precedence and validation"
    (let* ((normal-state (make-risk-decision-state))
           (drawdown-state (make-risk-decision-state
                             :drawdown 1d0 :max-drawdown 1d0))
           (volatility-state (make-risk-decision-state
                               :volatility 1d0 :max-volatility 1d0))
           (normal-result (risk-decision normal-state)))
      (expect (risk-decision-result-action normal-result) :to-be :allow)
      (expect (risk-decision-result-reason normal-result) :to-be :none)
      (expect (risk-decision-result-reason (risk-decision drawdown-state))
              :to-be :drawdown)
      (expect (risk-decision-result-reason (risk-decision volatility-state))
              :to-be :volatility)
      (signals invalid-argument
               (make-risk-decision-state :blackout-p :maybe))
      (signals invalid-argument
               (make-risk-decision-result :reject :none normal-state))
      (signals invalid-argument
               (make-risk-decision-result :allow :unknown normal-state))
      (signals invalid-argument (risk-decision nil))
      (signals invalid-argument
               (historical-var #(-0.1d0 0.1d0) 0.95d0 :notional 0d0))
      (signals invalid-argument (parametric-var 0d0 -1d0 0.95d0))
      (signals invalid-argument (kelly-fraction 0.5d0 0d0))
      (signals invalid-argument
               (volatility-target-position 0d0 1d0))
      (signals invalid-argument (drawdown-series #(0d0 1d0)))
      (signals invalid-shape
               (portfolio-variance #(1d0)
                                    #2A((1d0 0d0) (0d0 1d0))))
      (signals invalid-shape (stress-loss #(1d0) #(1d0 2d0))))))
