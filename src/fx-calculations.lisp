(in-package #:fx-quant-kit)

(defun fx-forward-points (pair spot base-rate quote-rate time-to-maturity)
  "Return forward points for a currency pair.

The result is the forward rate minus SPOT, in quote-currency units per base
unit.  Rates use continuous compounding and the pair convention is quote per
base."
  (let ((spot-price (ensure-positive spot 'spot)))
    (- (fx-forward-rate pair spot-price base-rate quote-rate time-to-maturity)
       spot-price)))

(defun fx-cross-rate (left-pair left-rate right-pair right-rate)
  "Multiply adjacent FX rates to form a cross rate.

LEFT-PAIR must be A/B and RIGHT-PAIR must be B/C.  The result is C per A."
  (unless (currency-pair-p left-pair)
    (error 'invalid-argument :name 'left-pair :value left-pair))
  (unless (currency-pair-p right-pair)
    (error 'invalid-argument :name 'right-pair :value right-pair))
  (let ((intermediate-left (currency-code (currency-pair-quote left-pair)))
        (intermediate-right (currency-code (currency-pair-base right-pair)))
        (left-price (ensure-positive left-rate 'left-rate))
        (right-price (ensure-positive right-rate 'right-rate)))
    (unless (string= intermediate-left intermediate-right)
      (error 'invalid-shape
             :expected (list intermediate-left intermediate-left)
             :actual (list intermediate-left intermediate-right)))
    (* left-price right-price)))

(defun fx-pip-distance (pair from-price to-price)
  "Return signed pip distance from FROM-PRICE to TO-PRICE."
  (unless (currency-pair-p pair)
    (error 'invalid-argument :name 'pair :value pair))
  (/ (- (ensure-positive to-price 'to-price)
        (ensure-positive from-price 'from-price))
     (currency-pair-pip-size pair)))

(defun fx-pnl (pair base-notional entry-price exit-price
               &key (side :long) (quote-to-account-rate 1d0))
  "Return account-currency P&L for a base-notional FX position.

SIDE is :LONG or :SHORT.  Prices use the pair's quote-per-base convention;
QUOTE-TO-ACCOUNT-RATE converts quote currency into account currency."
  (unless (currency-pair-p pair)
    (error 'invalid-argument :name 'pair :value pair))
  (unless (member side '(:long :short) :test #'eq)
    (error 'invalid-argument :name 'side :value side))
  (let ((notional (ensure-positive base-notional 'base-notional))
        (entry (ensure-positive entry-price 'entry-price))
        (exit (ensure-positive exit-price 'exit-price))
        (conversion (ensure-positive quote-to-account-rate
                                     'quote-to-account-rate)))
    (* (if (eq side :long) 1d0 -1d0)
       notional
       (- exit entry)
       conversion)))
