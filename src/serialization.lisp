(in-package #:fx-quant-kit)

(defun %json-object (members)
  (json-kit:alist->json-object members))

(defun %json-string (members)
  (json-kit:stringify (%json-object members)))

(defun %parsed-json-object (text)
  (unless (stringp text)
    (error 'invalid-argument :name 'json :value text))
  (let ((object
          (handler-case (json-kit:parse text)
            (error ()
              (error 'invalid-argument :name 'json :value text)))))
    (unless (hash-table-p object)
      (error 'invalid-argument :name 'json :value text))
    object))

(defun %json-value (object key)
  (multiple-value-bind (value present-p) (gethash key object)
    (unless present-p
      (error 'invalid-argument :name key :value object))
    value))

(defun market-quote->json (quote)
  "Serialize a MARKET-QUOTE as a JSON object without performing I/O."
  (unless (market-quote-p quote)
    (error 'invalid-argument :name 'quote :value quote))
  (%json-string
   (list (cons "timestamp" (market-quote-timestamp quote))
         (cons "bid" (market-quote-bid quote))
         (cons "ask" (market-quote-ask quote)))))

(defun json->market-quote (text)
  "Parse a JSON object produced by MARKET-QUOTE->JSON."
  (let ((object (%parsed-json-object text)))
    (make-market-quote (%json-value object "timestamp")
                       (%json-value object "bid")
                       (%json-value object "ask"))))

(defun tick-data->json (tick)
  "Serialize TICK-DATA as a JSON object without performing I/O."
  (unless (tick-data-p tick)
    (error 'invalid-argument :name 'tick :value tick))
  (%json-string
   (list (cons "timestamp" (tick-data-timestamp tick))
         (cons "bid" (tick-data-bid tick))
         (cons "ask" (tick-data-ask tick))
         (cons "bid-size" (tick-data-bid-size tick))
         (cons "ask-size" (tick-data-ask-size tick)))))

(defun json->tick-data (text)
  "Parse a JSON object produced by TICK-DATA->JSON."
  (let ((object (%parsed-json-object text)))
    (make-tick-data (%json-value object "timestamp")
                    (%json-value object "bid")
                    (%json-value object "ask")
                    :bid-size (%json-value object "bid-size")
                    :ask-size (%json-value object "ask-size"))))

(defun ohlcv-bar->json (bar)
  "Serialize an OHLCV-BAR as a JSON object without performing I/O."
  (unless (ohlcv-bar-p bar)
    (error 'invalid-argument :name 'bar :value bar))
  (%json-string
   (list (cons "timestamp" (ohlcv-bar-timestamp bar))
         (cons "open" (ohlcv-bar-open bar))
         (cons "high" (ohlcv-bar-high bar))
         (cons "low" (ohlcv-bar-low bar))
         (cons "close" (ohlcv-bar-close bar))
         (cons "volume" (ohlcv-bar-volume bar)))))

(defun json->ohlcv-bar (text)
  "Parse a JSON object produced by OHLCV-BAR->JSON."
  (let ((object (%parsed-json-object text)))
    (make-ohlcv-bar (%json-value object "timestamp")
                    (%json-value object "open")
                    (%json-value object "high")
                    (%json-value object "low")
                    (%json-value object "close")
                    (%json-value object "volume"))))

(defun currency->json (currency)
  "Serialize a CURRENCY as a JSON object without performing I/O."
  (unless (currency-p currency)
    (error 'invalid-argument :name 'currency :value currency))
  (%json-string (list (cons "code" (currency-code currency)))))

(defun json->currency (text)
  "Parse a JSON object produced by CURRENCY->JSON."
  (let ((object (%parsed-json-object text)))
    (make-currency (%json-value object "code"))))

(defun currency-pair->json (pair)
  "Serialize a CURRENCY-PAIR as a JSON object without performing I/O."
  (unless (currency-pair-p pair)
    (error 'invalid-argument :name 'pair :value pair))
  (%json-string
   (list (cons "base" (currency-code (currency-pair-base pair)))
         (cons "quote" (currency-code (currency-pair-quote pair)))
         (cons "pip-size" (currency-pair-pip-size pair)))))

(defun json->currency-pair (text)
  "Parse a JSON object produced by CURRENCY-PAIR->JSON."
  (let ((object (%parsed-json-object text)))
    (make-currency-pair (%json-value object "base")
                        (%json-value object "quote")
                        :pip-size (%json-value object "pip-size"))))
