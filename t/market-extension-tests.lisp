(in-package #:fx-quant-kit/test)

(describe "tick data and FX portfolio calculations"
  (it "validates tick sizes and derives microstructure measures"
    (let ((tick (make-tick-data 42 1.1d0 1.1002d0
                                :bid-size 3d0 :ask-size 1d0))
          (empty (make-tick-data 42 1.1d0 1.1002d0)))
      (expect (tick-data-timestamp tick) :to-be 42)
      (expect (tick-data-mid tick) :to-be-close-to 1.1001d0 10)
      (expect (tick-data-spread tick) :to-be-close-to 0.0002d0 10)
      (expect (tick-data-total-size tick) :to-be-close-to 4d0 10)
      (expect (tick-data-imbalance tick) :to-be-close-to 0.5d0 10)
      (expect (tick-data-imbalance empty) :to-be-close-to 0d0 10)
      (signals invalid-argument (make-tick-data 42 1.2d0 1.1d0))
      (signals invalid-argument
        (make-tick-data 42 1.1d0 1.2d0 :bid-size -1d0))))

  (it "round trips ticks through JSON"
    (let* ((tick (make-tick-data 42 1.1d0 1.1002d0
                                 :bid-size 3d0 :ask-size 1d0))
           (copy (json->tick-data (tick-data->json tick))))
      (expect (tick-data-timestamp copy) :to-be 42)
      (expect (tick-data-bid-size copy) :to-be-close-to 3d0 10)
      (expect (tick-data-ask-size copy) :to-be-close-to 1d0 10)))

  (it "computes FX cross rates, pips, points, and P&L"
    (let* ((eur-usd (make-currency-pair "EUR" "USD"))
           (usd-jpy (make-currency-pair "USD" "JPY"))
           (points (fx-forward-points eur-usd 1.1d0 0.02d0 0.01d0 1d0)))
      (expect (fx-cross-rate eur-usd 1.1d0 usd-jpy 150d0)
              :to-be-close-to 165d0 10)
      (expect points :to-be-close-to
              (- (fx-forward-rate eur-usd 1.1d0 0.02d0 0.01d0 1d0)
                 1.1d0) 10)
      (expect (fx-pip-distance eur-usd 1.1d0 1.1012d0)
              :to-be-close-to 12d0 10)
      (expect (fx-pnl eur-usd 100000d0 1.1d0 1.101d0)
              :to-be-close-to 100d0 10)
      (expect (fx-pnl eur-usd 100000d0 1.1d0 1.101d0
                      :side :short :quote-to-account-rate 2d0)
              :to-be-close-to -200d0 10)
      (signals invalid-shape
        (fx-cross-rate eur-usd 1.1d0 eur-usd 1.1d0)))))
