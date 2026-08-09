(in-package #:fx-quant-kit)

(defun %currency-code (code)
  (let ((text (string-upcase (string code))))
    (unless (and (= (length text) 3)
                 (loop for character across text
                       always (<= 65 (char-code character) 90)))
      (error 'invalid-argument :name 'code :value code))
    text))

(define-value-record currency
  ((code "" :type string)))

(defun make-currency (code)
  "Construct a canonical three-letter ASCII currency code."
  (%make-currency (%currency-code code)))

(defun %coerce-currency (value name)
  (cond ((currency-p value) value)
        ((or (stringp value) (symbolp value) (characterp value))
         (make-currency value))
        (t (error 'invalid-argument :name name :value value))))

(define-value-record currency-pair
  ((base nil :type currency)
   (quote nil :type currency)
   (pip-size 0d0 :type double-float))
  :conc-name currency-pair-)

(defun %default-pip-size (quote)
  (if (string= (currency-code quote) "JPY") 0.01d0 0.0001d0))

(defun make-currency-pair (base quote &key pip-size)
  "Construct a currency pair using the convention QUOTE per BASE.

PIP-SIZE defaults to 0.0001, or 0.01 when the quote currency is JPY."
  (let ((base-currency (%coerce-currency base 'base))
        (quote-currency (%coerce-currency quote 'quote)))
    (when (string= (currency-code base-currency)
                   (currency-code quote-currency))
      (error 'invalid-argument :name 'quote :value quote))
    (%make-currency-pair
     base-currency
     quote-currency
     (ensure-positive (or pip-size (%default-pip-size quote-currency))
                      'pip-size))))

(defun fx-forward-rate (pair spot base-rate quote-rate time-to-maturity)
  "Return the continuously compounded FX forward rate.

The pair convention is quote currency per base currency, so the covered
interest parity formula is SPOT * exp((BASE-RATE - QUOTE-RATE) * T)."
  (unless (currency-pair-p pair)
    (error 'invalid-argument :name 'pair :value pair))
  (let ((spot-price (ensure-positive spot 'spot))
        (base-interest-rate (ensure-finite base-rate 'base-rate))
        (quote-interest-rate (ensure-finite quote-rate 'quote-rate))
        (maturity (ensure-non-negative time-to-maturity
                                       'time-to-maturity)))
    (* spot-price
       (exp (* (- base-interest-rate quote-interest-rate) maturity)))))

(defun pip-value (pair notional &key (quote-to-account-rate 1d0))
  "Return the absolute account-currency value of one pip for a base notional.

QUOTE-TO-ACCOUNT-RATE converts one quote-currency unit to the account
currency."
  (unless (currency-pair-p pair)
    (error 'invalid-argument :name 'pair :value pair))
  (* (ensure-positive notional 'notional)
     (currency-pair-pip-size pair)
     (ensure-positive quote-to-account-rate 'quote-to-account-rate)))
