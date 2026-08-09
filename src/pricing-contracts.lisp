(in-package #:fx-quant-kit)

(defun %ensure-option-contract (contract)
  (unless (option-contract-p contract)
    (error 'invalid-argument :name 'contract :value contract))
  contract)

(defun option-contract-payoff (contract spot &key (quantity 1d0))
  "Return the signed intrinsic payoff of CONTRACT at SPOT."
  (%ensure-option-contract contract)
  (let ((underlying (ensure-positive spot 'spot))
        (scale (ensure-finite quantity 'quantity)))
    (* scale
       (if (eq (option-contract-option-type contract) :call)
           (max 0d0 (- underlying (option-contract-strike contract)))
           (max 0d0 (- (option-contract-strike contract) underlying))))))

(defun option-contract-price (contract spot volatility risk-free-rate
                              &key (dividend-yield 0d0) (quantity 1d0))
  "Return the Black-Scholes price of CONTRACT, scaled by QUANTITY."
  (%ensure-option-contract contract)
  (let ((scale (ensure-finite quantity 'quantity)))
    (* scale
       (black-scholes-price
        spot
        (option-contract-strike contract)
        (option-contract-time-to-expiry contract)
        volatility
        risk-free-rate
        :dividend-yield dividend-yield
        :option-type (option-contract-option-type contract)))))

(defun option-contract-greeks (contract spot volatility risk-free-rate
                               &key (dividend-yield 0d0) (quantity 1d0))
  "Return Black-Scholes Greeks of CONTRACT, scaled by QUANTITY."
  (%ensure-option-contract contract)
  (let ((scale (ensure-finite quantity 'quantity)))
    (let ((greeks
            (black-scholes-greeks
             spot
             (option-contract-strike contract)
             (option-contract-time-to-expiry contract)
             volatility
             risk-free-rate
             :dividend-yield dividend-yield
             :option-type (option-contract-option-type contract))))
      (make-black-scholes-greeks
       :price (* scale (greeks-price greeks))
       :delta (* scale (greeks-delta greeks))
       :gamma (* scale (greeks-gamma greeks))
       :vega (* scale (greeks-vega greeks))
       :theta (* scale (greeks-theta greeks))
       :rho (* scale (greeks-rho greeks))))))

(defun discount-factor (rate time-to-maturity)
  "Return a continuously compounded discount factor."
  (let ((interest-rate (ensure-finite rate 'rate))
        (maturity (ensure-non-negative time-to-maturity
                                       'time-to-maturity)))
    (ensure-finite (exp (* (- interest-rate) maturity))
                   'discount-factor)))

(defun present-value (cash-flow rate time-to-maturity)
  "Discount CASH-FLOW continuously from TIME-TO-MATURITY."
  (* (ensure-finite cash-flow 'cash-flow)
     (discount-factor rate time-to-maturity)))

(defun forward-price (spot carry-rate time-to-maturity)
  "Return a continuously compounded forward price."
  (ensure-finite
   (* (ensure-positive spot 'spot)
      (exp (* (ensure-finite carry-rate 'carry-rate)
              (ensure-non-negative time-to-maturity
                                   'time-to-maturity))))
   'forward-price))
