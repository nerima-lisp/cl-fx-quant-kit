(in-package #:fx-quant-kit)

(defun %ensure-option-type (option-type)
  (unless (member option-type '(:call :put) :test #'eq)
    (error 'invalid-argument
           :name :option-type
           :value option-type))
  option-type)

(define-value-record option-contract
  ((option-type :call)
   (strike 0d0 :type double-float)
   (time-to-expiry 0d0 :type double-float))
  :conc-name option-contract-)

(defun make-option-contract (option-type strike time-to-expiry)
  "Construct a European option contract used by pricing functions."
  (%make-option-contract
   (%ensure-option-type option-type)
   (ensure-positive strike 'strike)
   (ensure-positive time-to-expiry 'time-to-expiry)))

(define-value-record black-scholes-greeks
  ((price 0d0 :type double-float :read-only t)
   (delta 0d0 :type double-float :read-only t)
   (gamma 0d0 :type double-float :read-only t)
   (vega 0d0 :type double-float :read-only t)
   (theta 0d0 :type double-float :read-only t)
   (rho 0d0 :type double-float :read-only t))
  :conc-name greeks-)

(defun make-black-scholes-greeks (&key price delta gamma vega theta rho)
  (%make-black-scholes-greeks
   (ensure-finite price :price)
   (ensure-finite delta :delta)
   (ensure-finite gamma :gamma)
   (ensure-finite vega :vega)
   (ensure-finite theta :theta)
   (ensure-finite rho :rho)))
