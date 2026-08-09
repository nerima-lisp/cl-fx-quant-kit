(in-package #:fx-quant-kit/test)

(describe "market data and FX conventions"
  (it "validates quotes and bars"
    (let ((quote (make-market-quote 1000 1.1000d0 1.1002d0))
          (bar (make-ohlcv-bar 1000 1.1001d0 1.1010d0 1.0990d0
                               1.1005d0 250d0)))
      (expect (market-quote-mid quote) :to-be-close-to 1.1001d0 10)
      (expect (market-quote-spread quote) :to-be-close-to 0.0002d0 10)
      (expect (ohlcv-bar-close bar) :to-be-close-to 1.1005d0 10)
      (signals invalid-argument
        (make-market-quote 1000 1.2d0 1.1d0))
      (signals invalid-argument
        (make-ohlcv-bar 1000 1.1d0 1.0d0 0.9d0 1.0d0 1d0))))

  (it "round trips JSON without changing values"
    (let* ((quote (make-market-quote 1000 1.1000d0 1.1002d0))
           (quote-copy (json->market-quote (market-quote->json quote)))
           (bar (make-ohlcv-bar 1000 1.1d0 1.2d0 1.0d0 1.15d0 20d0))
           (bar-copy (json->ohlcv-bar (ohlcv-bar->json bar))))
      (expect (market-quote-timestamp quote-copy) :to-be 1000)
      (expect (market-quote-bid quote-copy) :to-be-close-to 1.1d0 10)
      (expect (market-quote-ask quote-copy) :to-be-close-to 1.1002d0 10)
      (expect (ohlcv-bar-timestamp bar-copy) :to-be 1000)
      (expect (ohlcv-bar-volume bar-copy) :to-be-close-to 20d0 10)))

  (it "converts timestamps through cl-date-kit"
    (let* ((timestamp 1704067200000000)
           (instant (timestamp->instant timestamp))
           (text (timestamp->iso8601 timestamp)))
      (expect (instant->timestamp instant) :to-be timestamp)
      (expect (iso8601->timestamp text) :to-be timestamp)
      (signals invalid-argument (iso8601->timestamp "not-a-timestamp"))))

  (it "normalizes currencies and prices FX forwards"
    (let* ((pair (make-currency-pair "eur" "usd"))
           (copy (json->currency-pair (currency-pair->json pair))))
      (expect (currency-code (currency-pair-base pair)) :to-equal "EUR")
      (expect (currency-code (currency-pair-quote pair)) :to-equal "USD")
      (expect (currency-pair-pip-size pair) :to-be-close-to 0.0001d0 10)
      (expect (currency-code (currency-pair-base copy)) :to-equal "EUR")
      (expect (fx-forward-rate pair 1.1d0 0.02d0 0.01d0 1d0)
              :to-be-close-to 1.1110551838d0 8)
      (expect (pip-value pair 100000d0) :to-be-close-to 10d0 10)
      (expect (pip-value pair 100000d0 :quote-to-account-rate 1.2d0)
              :to-be-close-to 12d0 10))))
