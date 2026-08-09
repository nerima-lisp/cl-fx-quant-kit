(in-package #:fx-quant-kit)

(defun black-scholes-greeks (spot strike time-to-expiry volatility
                             risk-free-rate
                             &key (dividend-yield 0d0) (option-type :call))
  "Return price and first- and second-order Black-Scholes sensitivities.

VEGA is the price change per unit (1.00) change in volatility, while THETA is
the calendar-time decay conventionally quoted as a negative value for a call.
All rates and volatility are annualized."
  (multiple-value-bind (spot strike time-to-expiry volatility risk-free-rate
                        dividend-yield option-type d1 d2 dividend-discount
                        risk-free-discount)
      (%black-scholes-components spot strike time-to-expiry volatility
                                 risk-free-rate dividend-yield option-type)
    (let* ((sqrt-time (sqrt time-to-expiry))
           (density (normal-pdf d1))
           (price (black-scholes-price
                   spot strike time-to-expiry volatility risk-free-rate
                   :dividend-yield dividend-yield
                   :option-type option-type))
           (d1-probability (normal-cdf d1))
           (d2-probability (normal-cdf d2)))
      (let* ((delta (if (eq option-type :call)
                        (* dividend-discount d1-probability)
                        (* dividend-discount
                           (- d1-probability 1d0))))
             (gamma (/ (* dividend-discount density)
                       (* spot volatility sqrt-time)))
             (vega (* spot dividend-discount density sqrt-time))
             (common-theta (- (/ (* spot dividend-discount density volatility)
                                 (* 2d0 sqrt-time))))
             (theta (if (eq option-type :call)
                        (+ common-theta
                           (- (* risk-free-rate strike risk-free-discount
                                 d2-probability))
                           (* dividend-yield spot dividend-discount
                              d1-probability))
                        (+ common-theta
                           (* risk-free-rate strike risk-free-discount
                              (normal-cdf (- d2)))
                           (- (* dividend-yield spot dividend-discount
                                 (normal-cdf (- d1)))))))
             (rho (if (eq option-type :call)
                      (* strike time-to-expiry risk-free-discount
                         d2-probability)
                      (- (* strike time-to-expiry risk-free-discount
                            (normal-cdf (- d2)))))))
        (%make-black-scholes-greeks price delta gamma vega theta rho)))))
