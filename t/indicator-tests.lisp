(in-package #:fx-quant-kit/test)

(describe "technical indicators"
  (it "computes moving averages and RSI"
    (let ((values #(1d0 2d0 3d0 4d0 5d0)))
      (expect (aref (sma values 3) 0) :to-be nil)
      (expect (aref (sma values 3) 2) :to-be-close-to 2d0 10)
      (expect (aref (sma values 3) 4) :to-be-close-to 4d0 10)
      (expect (aref (ema values 3) 2) :to-be-close-to 2d0 10)
      (expect (aref (wilder-average values 3) 4)
              :to-be-close-to 3.4444444444d0 8)
      (expect (aref (rsi values 3) 3) :to-be-close-to 100d0 10)))

  (it "computes MACD and Bollinger bands"
    (let* ((values (coerce (loop for index from 1 to 40
                                 collect (coerce index 'double-float))
                           'vector))
           (macd-value (macd values))
           (bands (bollinger-bands values 5)))
      (expect (macd-result-p macd-value) :to-be-truthy)
      (expect (aref (macd-result-line macd-value) 0) :to-be nil)
      (expect (aref (macd-result-line macd-value) 25) :to-be-close-to 7d0 8)
      (expect (aref (bollinger-result-middle bands) 4)
              :to-be-close-to 3d0 10)
      (expect (aref (bollinger-result-upper bands) 4)
              :to-be-close-to 5.8284271247d0 8)
      (expect (aref (bollinger-result-lower bands) 4)
              :to-be-close-to 0.1715728753d0 8)))

  (it "computes range and volatility measures"
    (let* ((bars (vector
                  (make-ohlcv-bar 1 10d0 12d0 9d0 11d0 100d0)
                  (make-ohlcv-bar 2 11d0 13d0 10d0 12d0 110d0)))
           (ranges (true-range bars))
           (atr-value (atr bars 2))
           (returns #(0.01d0 -0.02d0 0.015d0 -0.005d0)))
      (expect-vector-close ranges #(3d0 3d0) 10)
      (expect (aref atr-value 0) :to-be nil)
      (expect (aref atr-value 1) :to-be-close-to 3d0 10)
      (expect (realized-volatility returns :annualization-factor 100d0)
              :to-be-close-to 0.1369306394d0 8)))

  (it "computes Hurst and GARCH quantities"
    (let* ((values (coerce (loop for index from 1 to 40
                                 collect (coerce index 'double-float))
                           'vector))
           (returns #(0.01d0 -0.02d0))
           (variance (garch11-variance returns
                                       :omega 0.1d0
                                       :alpha 0.2d0
                                       :beta 0.3d0
                                       :initial-variance 0.4d0))
           (forecast (garch11-forecast returns 2
                                       :omega 0.1d0
                                       :alpha 0.2d0
                                       :beta 0.3d0
                                       :initial-variance 0.4d0)))
      (expect (hurst-exponent values) :to-be-truthy)
      (expect (aref variance 0) :to-be-close-to 0.4d0 10)
      (expect (aref variance 1) :to-be-close-to 0.22002d0 8)
      (expect (aref forecast 0) :to-be-close-to 0.206006d0 7)
      (expect (aref forecast 1) :to-be-close-to 0.2018018d0 7))))
