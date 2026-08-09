(in-package #:fx-quant-kit)

(defun %black-scholes-inputs (spot strike time-to-expiry volatility
                              risk-free-rate dividend-yield option-type)
  (values (ensure-positive spot :spot)
          (ensure-positive strike :strike)
          (ensure-positive time-to-expiry :time-to-expiry)
          (ensure-positive volatility :volatility)
          (ensure-finite risk-free-rate :risk-free-rate)
          (ensure-finite dividend-yield :dividend-yield)
          (%ensure-option-type option-type)))

(defun %black-scholes-d1-d2 (spot strike time-to-expiry volatility
                             risk-free-rate dividend-yield)
  (let* ((sqrt-time (sqrt time-to-expiry))
         (volatility-time (* volatility sqrt-time))
         (d1 (/ (+ (log (/ spot strike))
                   (* (+ (- risk-free-rate dividend-yield)
                         (* 0.5d0 volatility volatility))
                      time-to-expiry))
                volatility-time)))
    (values d1 (- d1 volatility-time))))

(defun %black-scholes-components (spot strike time-to-expiry volatility
                                  risk-free-rate dividend-yield option-type)
  (multiple-value-bind (spot strike time-to-expiry volatility risk-free-rate
                        dividend-yield option-type)
      (%black-scholes-inputs spot strike time-to-expiry volatility
                             risk-free-rate dividend-yield option-type)
    (multiple-value-bind (d1 d2)
        (%black-scholes-d1-d2 spot strike time-to-expiry volatility
                              risk-free-rate dividend-yield)
      (values spot strike time-to-expiry volatility risk-free-rate
              dividend-yield option-type d1 d2
              (exp (- (* dividend-yield time-to-expiry)))
              (exp (- (* risk-free-rate time-to-expiry)))))))

(defun black-scholes-price (spot strike time-to-expiry volatility
                            risk-free-rate
                            &key (dividend-yield 0d0) (option-type :call))
  "Return the continuously compounded Black-Scholes/Garman-Kohlhagen price.

VOLATILITY is annualized and the returned value is per unit of underlying.
The option type is either :CALL or :PUT.  TIME-TO-EXPIRY must be positive;
expiry-boundary pricing is deliberately kept separate from this differentiable
formula."
  (multiple-value-bind (spot strike time-to-expiry volatility risk-free-rate
                        dividend-yield option-type d1 d2 dividend-discount
                        risk-free-discount)
      (%black-scholes-components spot strike time-to-expiry volatility
                                 risk-free-rate dividend-yield option-type)
    (declare (ignore time-to-expiry volatility risk-free-rate dividend-yield))
    (let ((call (- (* spot dividend-discount (normal-cdf d1))
                   (* strike risk-free-discount (normal-cdf d2)))))
      (if (eq option-type :call)
          call
          (+ call
             (* strike risk-free-discount)
             (- (* spot dividend-discount)))))))
