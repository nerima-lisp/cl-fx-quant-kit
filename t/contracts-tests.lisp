(in-package #:fx-quant-kit/test)

(describe "public contracts and boundary behavior"
  (it "reports typed validation failures"
    (let ((condition
            (handler-case
                (progn (ensure-positive 0d0 :price) nil)
              (invalid-argument (value) value))))
      (expect (invalid-argument-name condition) :to-be :price)
      (expect (invalid-argument-value condition) :to-be 0d0))
    (signals invalid-argument (ensure-real #C(1d0 2d0) :value))
    (signals invalid-argument (ensure-finite "not-a-number" :value))
    (signals invalid-argument (ensure-non-negative -1d0 :value))
    (signals invalid-argument (ensure-probability 1.1d0 :probability)))

  (it "keeps distribution boundaries deterministic"
    (expect (normal-pdf 0d0) :to-be-close-to 0.3989422804d0 9)
    (expect (normal-cdf 0d0) :to-be-close-to 0.5d0 12)
    (expect (normal-cdf 9d0) :to-be 1d0)
    (expect (normal-cdf -9d0) :to-be 0d0)
    (expect (inverse-normal-cdf 0.5d0) :to-be-close-to 0d0 10)
    (expect (inverse-normal-cdf 0.975d0) :to-be-close-to 1.9599639845d0 7)
    (signals invalid-argument (inverse-normal-cdf 0d0))
    (signals invalid-argument (normal-pdf 0d0 :standard-deviation 0d0)))

  (it "rejects incompatible statistical shapes and domains"
    (signals invalid-shape (covariance #(1d0 2d0) #(1d0 2d0 3d0)))
    (signals numerical-error (correlation #(1d0 1d0) #(2d0 3d0)))
    (signals numerical-error (weighted-mean #(1d0 2d0) #(0d0 0d0)))
    (signals invalid-argument (log-returns #(1d0 0d0)))
    (signals invalid-argument (quantile #(1d0 2d0) 1.1d0)))

  (it "preserves value-record data when source vectors are changed"
    (let* ((line (vector 1d0 2d0))
           (signal (vector 3d0 4d0))
           (histogram (vector -2d0 -2d0))
           (result (make-macd-result line signal histogram))
           (middle (vector 1d0 2d0 3d0))
           (upper (vector 2d0 3d0 4d0))
           (lower (vector 0d0 1d0 2d0))
           (bands (make-bollinger-result middle upper lower)))
      (setf (aref line 0) 99d0
            (aref middle 0) 99d0)
      (expect-vector-close (macd-result-line result) #(1d0 2d0) 12)
      (expect-vector-close (bollinger-result-middle bands) #(1d0 2d0 3d0) 12)
      (expect (macd-result-p result) :to-be t)
      (expect (bollinger-result-p bands) :to-be t)))

  (it "round-trips market values and rejects malformed JSON"
    (let* ((quote (make-market-quote 1704067200000000 1.1000d0 1.1002d0))
           (bar (make-ohlcv-bar 1704067200000000
                                1.1d0 1.2d0 1.0d0 1.15d0 20d0))
           (quote-copy (json->market-quote (market-quote->json quote)))
           (bar-copy (json->ohlcv-bar (ohlcv-bar->json bar)))
           (timestamp (market-quote-timestamp quote)))
      (expect (market-quote-timestamp quote-copy) :to-be timestamp)
      (expect (market-quote-mid quote-copy) :to-be-close-to 1.1001d0 10)
      (expect (ohlcv-bar-close bar-copy) :to-be-close-to 1.15d0 10)
      (expect (iso8601->timestamp (timestamp->iso8601 timestamp))
              :to-be timestamp)
      (signals invalid-argument (json->market-quote "[]"))
      (signals invalid-argument (json->currency "{}"))
      (signals invalid-argument (iso8601->timestamp "not-an-instant"))))

  (it "enforces FX conventions and conversion contracts"
    (let* ((jpy-pair (make-currency-pair "USD" "JPY"))
           (eur-pair (make-currency-pair "EUR" "USD"))
           (currency-copy (json->currency
                           (currency->json (make-currency "jpy")))))
      (expect (currency-code currency-copy) :to-equal "JPY")
      (expect (currency-pair-pip-size jpy-pair)
              :to-be-close-to 0.01d0 12)
      (expect (pip-value jpy-pair 100000d0) :to-be-close-to 1000d0 10)
      (expect (fx-forward-rate eur-pair 1.1d0 0.02d0 0.01d0 1d0)
              :to-be-close-to 1.1110551838d0 8)
      (signals invalid-argument (make-currency-pair "USD" "USD"))
      (signals invalid-argument
               (make-currency-pair "US" "JPY"))
      (signals invalid-argument
               (pip-value eur-pair 100000d0 :quote-to-account-rate 0d0))))

  (it "covers indicator warmups and invalid regimes"
    (let ((flat (make-array 20 :element-type 'double-float
                            :initial-element 1d0)))
      (expect (aref (rsi #(1d0 1d0 1d0) 1) 2)
              :to-be-close-to 50d0 10)
      (expect (aref (rsi #(1d0 2d0 3d0) 1) 2)
              :to-be-close-to 100d0 10)
      (expect (aref (rsi #(3d0 2d0 1d0) 1) 2)
              :to-be-close-to 0d0 10)
      (expect (length (garch11-forecast #(0.01d0) 0)) :to-be 0)
      (signals numerical-error (hurst-exponent flat))
      (signals invalid-argument (macd #(1d0 2d0 3d0) :fast-period 3
                                      :slow-period 3))
      (signals invalid-argument
               (bollinger-bands #(1d0 2d0 3d0) 2 :deviations -1d0))
      (signals insufficient-data (true-range #()))
      (signals invalid-argument
               (garch11-variance #(0.01d0) :alpha 0.6d0 :beta 0.4d0))))

  (it "keeps pricing contracts bracketed and explicit"
    (let* ((price (black-scholes-price 100d0 100d0 1d0 0.2d0 0.05d0))
           (greeks (black-scholes-greeks 100d0 100d0 1d0 0.2d0 0.05d0))
           (solved (implied-volatility price 100d0 100d0 1d0 0.05d0)))
      (expect (black-scholes-greeks-p greeks) :to-be t)
      (expect (greeks-price greeks) :to-be-close-to price 10)
      (expect (greeks-gamma greeks) :to-be-close-to 0.0187620173d0 8)
      (expect (greeks-vega greeks) :to-be-close-to 37.5240347d0 7)
      (expect solved :to-be-close-to 0.2d0 7)
      (signals invalid-argument
               (make-black-scholes-greeks :price "not-a-number"))
      (signals domain-error
               (implied-volatility 0d0 100d0 100d0 1d0 0.01d0))
      (signals invalid-argument
               (implied-volatility price 100d0 100d0 1d0 0.05d0
                                   :lower-bound 1d0 :upper-bound 1d0))
      (signals invalid-argument
               (implied-volatility price 100d0 100d0 1d0 0.05d0
                                   :max-iterations 0))))

  (it "keeps seeded simulations reproducible without global state"
    (let* ((left (make-simulation-rng 42))
           (right (make-simulation-rng 42))
           (left-value (rng-uniform left))
           (right-value (rng-uniform right))
           (zero-noise
             (simulate-geometric-brownian-motion
              100d0 0d0 0d0 0.25d0 2 2 :rng (make-simulation-rng 7)))
           (ou
             (simulate-ornstein-uhlenbeck
              1d0 0d0 1d0 0d0 1d0 1 1
              :rng (make-simulation-rng 7))))
      (expect left-value :to-be-close-to right-value 15)
      (loop for path across zero-noise
            do (expect-vector-close path #(100d0 100d0 100d0) 10))
      (expect-vector-close (aref ou 0) #(1d0 1d0) 10)
      (signals invalid-argument (rng-uniform :not-an-rng))
      (signals invalid-argument
               (simulate-geometric-brownian-motion
                100d0 0d0 0d0 0.25d0 0 1))
      (signals invalid-argument
               (simulate-ornstein-uhlenbeck
                1d0 0d0 1d0 0.25d0 0.25d0 1 1 :rng nil))))

  (it "keeps risk decisions and CPS wrappers equivalent"
    (let* ((state (make-risk-decision-state :blackout-p t))
           (decision (risk-decision state))
           (var (parametric-var 0d0 0.1d0 0.95d0))
           (expected-shortfall
             (parametric-expected-shortfall 0d0 0.1d0 0.95d0)))
      (expect (risk-decision-result-action decision) :to-be :block)
      (expect (risk-decision-result-reason decision) :to-be :blackout)
      (expect (> expected-shortfall var 0d0) :to-be t)
      (with-cps-result (value quantile/k #(1d0 2d0 3d0) 0.5d0)
        (expect value :to-be-close-to 2d0 10))
      (with-cps-result (value risk-decision/k state)
        (expect (risk-decision-result-reason value) :to-be :blackout))
      (signals invalid-argument (quantile/k #(1d0 2d0) 0.5d0 nil)))))
