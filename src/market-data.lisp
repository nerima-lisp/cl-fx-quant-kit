(in-package #:fx-quant-kit)

(defun %ensure-timestamp (timestamp)
  (unless (and (integerp timestamp) (>= timestamp 0))
    (error 'invalid-argument :name 'timestamp :value timestamp))
  timestamp)

(define-value-record market-quote
  ((timestamp 0 :type integer)
   (bid 0d0 :type double-float)
   (ask 0d0 :type double-float)))

(defun make-market-quote (timestamp bid ask)
  "Construct a quote whose prices are quote-currency units per base unit.

TIMESTAMP is a non-negative Unix-epoch microsecond value."
  (let ((time (%ensure-timestamp timestamp))
        (bid-price (ensure-positive bid 'bid))
        (ask-price (ensure-positive ask 'ask)))
    (when (> bid-price ask-price)
      (error 'invalid-argument :name 'ask :value ask))
    (%make-market-quote time bid-price ask-price)))

(defun market-quote-mid (quote)
  "Return the arithmetic midpoint of a valid quote."
  (unless (market-quote-p quote)
    (error 'invalid-argument :name 'quote :value quote))
  (/ (+ (market-quote-bid quote) (market-quote-ask quote)) 2d0))

(defun market-quote-spread (quote)
  "Return the absolute bid/ask spread in quote-currency units."
  (unless (market-quote-p quote)
    (error 'invalid-argument :name 'quote :value quote))
  (- (market-quote-ask quote) (market-quote-bid quote)))

(define-value-record tick-data
  ((timestamp 0 :type integer)
   (bid 0d0 :type double-float)
   (ask 0d0 :type double-float)
   (bid-size 0d0 :type double-float)
   (ask-size 0d0 :type double-float)))

(defun make-tick-data (timestamp bid ask &key (bid-size 0d0) (ask-size 0d0))
  "Construct a validated quote tick with optional displayed sizes.

TIMESTAMP is a non-negative Unix-epoch microsecond value.  BID-SIZE and
ASK-SIZE are non-negative base-currency quantities."
  (let ((time (%ensure-timestamp timestamp))
        (bid-price (ensure-positive bid 'bid))
        (ask-price (ensure-positive ask 'ask))
        (bid-quantity (ensure-non-negative bid-size 'bid-size))
        (ask-quantity (ensure-non-negative ask-size 'ask-size)))
    (when (> bid-price ask-price)
      (error 'invalid-argument :name 'ask :value ask))
    (%make-tick-data time bid-price ask-price bid-quantity ask-quantity)))

(defun tick-data-mid (tick)
  "Return the arithmetic midpoint of a valid TICK-DATA value."
  (unless (tick-data-p tick)
    (error 'invalid-argument :name 'tick :value tick))
  (/ (+ (tick-data-bid tick) (tick-data-ask tick)) 2d0))

(defun tick-data-spread (tick)
  "Return the absolute bid/ask spread of a valid tick."
  (unless (tick-data-p tick)
    (error 'invalid-argument :name 'tick :value tick))
  (- (tick-data-ask tick) (tick-data-bid tick)))

(defun tick-data-total-size (tick)
  "Return displayed bid plus ask size for a valid tick."
  (unless (tick-data-p tick)
    (error 'invalid-argument :name 'tick :value tick))
  (+ (tick-data-bid-size tick) (tick-data-ask-size tick)))

(defun tick-data-imbalance (tick)
  "Return signed displayed-size imbalance in the interval [-1, 1]."
  (unless (tick-data-p tick)
    (error 'invalid-argument :name 'tick :value tick))
  (let ((total (tick-data-total-size tick)))
    (if (zerop total)
        0d0
        (/ (- (tick-data-bid-size tick) (tick-data-ask-size tick))
           total))))

(define-value-record ohlcv-bar
  ((timestamp 0 :type integer)
   (open 0d0 :type double-float)
   (high 0d0 :type double-float)
   (low 0d0 :type double-float)
   (close 0d0 :type double-float)
   (volume 0d0 :type double-float)))

(defun make-ohlcv-bar (timestamp open high low close volume)
  "Construct an OHLCV bar with internally consistent positive prices."
  (let ((time (%ensure-timestamp timestamp))
        (opening (ensure-positive open 'open))
        (highest (ensure-positive high 'high))
        (lowest (ensure-positive low 'low))
        (closing (ensure-positive close 'close))
        (traded-volume (ensure-non-negative volume 'volume)))
    (unless (and (>= highest opening)
                 (>= highest closing)
                 (<= lowest opening)
                 (<= lowest closing)
                 (>= highest lowest))
      (error 'invalid-argument
             :name 'ohlcv
             :value (list open high low close)))
    (%make-ohlcv-bar time opening highest lowest closing traded-volume)))
