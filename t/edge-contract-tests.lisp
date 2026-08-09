(in-package #:fx-quant-kit/test)

(describe "edge contracts"
  (it "covers non-standard distributions and matrix modes"
    (let* ((covariance
             (covariance-matrix
              #(#(1d0 2d0 3d0) #(2d0 4d0 6d0))
              :sample-p nil))
           (correlation
             (correlation-matrix
              #(#(1d0 2d0 3d0) #(2d0 4d0 8d0)))))
      (expect (normal-pdf 1d0 :mean 1d0 :standard-deviation 2d0)
              :to-be-close-to 0.1994711402d0 8)
      (expect (normal-cdf -1d0 :mean 1d0 :standard-deviation 2d0)
              :to-be-close-to 0.1586552539d0 8)
      (expect (inverse-normal-cdf 0.5d0 :mean 10d0 :standard-deviation 2d0)
              :to-be-close-to 10d0 10)
      (expect (aref covariance 0 0) :to-be-close-to (/ 2d0 3d0) 10)
      (expect (aref covariance 0 1) :to-be-close-to (/ 4d0 3d0) 10)
      (expect (aref correlation 0 0) :to-be-close-to 1d0 10)
      (expect (numberp (aref correlation 0 1)) :to-be t)
      (signals insufficient-data
        (skewness #(1d0 2d0) :bias-corrected-p t))
      (signals insufficient-data
        (excess-kurtosis #(1d0 2d0 3d0) :bias-corrected-p t))
      (signals numerical-error
        (correlation-matrix #(#(1d0 1d0) #(1d0 2d0))))))

  (it "covers FX coercions and invalid calculation domains"
    (let* ((eur (make-currency 'eur))
           (usd (make-currency "USD"))
           (eur-usd (make-currency-pair eur usd :pip-size 0.00001d0))
           (eur-jpy (make-currency-pair "EUR" "JPY")))
      (expect (currency-code eur) :to-equal "EUR")
      (expect (currency-pair-pip-size eur-usd) :to-be-close-to .00001d0 12)
      (expect (currency-pair-pip-size eur-jpy) :to-be-close-to .01d0 12)
      (expect (fx-forward-rate eur-usd 1.1d0 .02d0 .01d0 0d0)
              :to-be-close-to 1.1d0 12)
      (expect (pip-value eur-usd 100000d0 :quote-to-account-rate 2d0)
              :to-be-close-to 2d0 12)
      (signals invalid-shape
        (fx-cross-rate eur-usd 1d0 eur-jpy 1d0))
      (signals invalid-argument
        (fx-pip-distance eur-usd 0d0 1d0))
      (signals invalid-argument
        (fx-forward-rate eur-usd 1d0 .02d0 .01d0 -1d0))
      (signals invalid-argument
        (fx-pnl eur-usd 100d0 1d0 1d0 :side :invalid))))

  (it "covers market depth and complete JSON round trips"
    (let* ((tick (make-tick-data 0 1d0 1.1d0 :bid-size 3d0 :ask-size 1d0))
           (tick-copy (json->tick-data (tick-data->json tick)))
           (pair (make-currency-pair "EUR" "USD" :pip-size .00001d0))
           (pair-copy (json->currency-pair (currency-pair->json pair))))
      (expect (tick-data-spread tick) :to-be-close-to .1d0 12)
      (expect (tick-data-total-size tick) :to-be-close-to 4d0 12)
      (expect (tick-data-imbalance tick) :to-be-close-to .5d0 12)
      (expect (tick-data-bid-size tick-copy) :to-be-close-to 3d0 12)
      (expect (currency-code (currency-pair-base pair-copy)) :to-equal "EUR")
      (expect (currency-pair-pip-size pair-copy) :to-be-close-to .00001d0 12)
      (signals invalid-argument (json->tick-data "{}"))
      (signals invalid-argument (json->currency-pair "{}"))))

  (it "covers stochastic branches and the Monte Carlo contract"
    (let* ((gbm (simulate-geometric-brownian-motion
                 100d0 .01d0 .2d0 .01d0 2 1))
           (ou (simulate-ornstein-uhlenbeck
                1d0 .5d0 0d0 .2d0 .01d0 2 1
                :rng (make-simulation-rng 19))))
      (expect (length gbm) :to-be 1)
      (expect (length (aref gbm 0)) :to-be 3)
      (expect (length ou) :to-be 1)
      (expect (length (aref ou 0)) :to-be 3)
      (expect (numberp (aref (aref ou 0) 2)) :to-be t)
      (multiple-value-bind (mean standard-error variance)
          (monte-carlo-estimate
           #'(lambda (rng) (declare (ignore rng)) 2d0)
           3
           :rng (make-simulation-rng 23))
        (expect mean :to-be-close-to 2d0 12)
        (expect standard-error :to-be-close-to 0d0 12)
        (expect variance :to-be-close-to 0d0 12))
      (signals invalid-argument
        (monte-carlo-estimate
         #'(lambda (rng) (declare (ignore rng)) "bad")
         2
         :rng (make-simulation-rng 23)))))

  (it "covers put contracts and portfolio risk contributions"
    (let* ((contract (make-option-contract :put 100d0 1d0))
           (price (option-contract-price contract 100d0 .2d0 .05d0))
           (greeks (option-contract-greeks contract 100d0 .2d0 .05d0))
           (weights #(.5d0 .5d0))
           (covariance #2A((.04d0 .01d0) (.01d0 .09d0)))
           (contributions (portfolio-risk-contributions weights covariance)))
      (expect (option-contract-payoff contract 90d0) :to-be-close-to 10d0 12)
      (expect price :to-be-close-to (greeks-price greeks) 12)
      (expect (length contributions) :to-be 2)
      (expect (portfolio-volatility weights covariance) :to-be-close-to
              (sqrt (portfolio-variance weights covariance)) 12)
      (expect (+ (aref contributions 0) (aref contributions 1))
              :to-be-close-to (portfolio-variance weights covariance) 12)
      (expect (max-drawdown #(100d0 90d0 110d0 80d0))
              :to-be-close-to (/ 3d0 11d0) 12)
      (expect (stress-loss #(1d0 1d0) #(-2d0 -3d0))
              :to-be-close-to 5d0 12))))
