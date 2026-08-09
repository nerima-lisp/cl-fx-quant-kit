(in-package #:fx-quant-kit)

(defmacro define-cps-wrapper (name)
  "Define NAME/K, a continuation-passing wrapper around NAME.

The wrapper accepts NAME's ordinary arguments followed by a function.  Every
value returned by NAME is passed to that function, preserving multiple-value
semantics without introducing a second implementation of the calculation."
  (unless (symbolp name)
    (error "CPS wrapper name must be a symbol: ~S" name))
  (let ((wrapper
          (intern (format nil "~A/K" (symbol-name name))
                  (symbol-package name)))
        (function-arguments (gensym "FUNCTION-ARGUMENTS-"))
        (continuation (gensym "CONTINUATION-")))
    `(defun ,wrapper (&rest arguments)
       ,(format nil
                "Call ~A and pass all returned values to a continuation."
                name)
       (multiple-value-bind (,function-arguments ,continuation)
           (%split-continuation-arguments arguments)
         (%invoke-continuation #',name ,function-arguments ,continuation)))))

(defmacro define-cps-wrappers (&rest names)
  "Define callback-last wrappers for each computational function in NAMES.

The ordinary function remains the single implementation of the calculation;
the generated wrapper only adapts its return values to continuation style."
  (dolist (name names)
    (unless (symbolp name)
      (error "CPS wrapper name must be a symbol: ~S" name)))
  `(progn
     ,@(mapcar (lambda (name)
                 `(define-cps-wrapper ,name))
               names)))

(define-cps-wrappers
  mean weighted-mean variance standard-deviation covariance correlation
  sum-of-squares simple-returns log-returns cumulative-return quantile median
  normal-pdf normal-cdf inverse-normal-cdf
  skewness excess-kurtosis sharpe-ratio sortino-ratio beta tracking-error
  information-ratio covariance-matrix correlation-matrix
  fx-forward-rate fx-forward-points fx-cross-rate fx-pip-distance fx-pnl
  pip-value
  sma ema wilder-average rsi macd bollinger-bands true-range atr
  hurst-exponent garch11-variance garch11-forecast realized-volatility
  black-scholes-price black-scholes-greeks implied-volatility
  rng-uniform rng-normal simulate-geometric-brownian-motion
  simulate-ornstein-uhlenbeck monte-carlo-estimate
  historical-var historical-expected-shortfall parametric-var
  parametric-expected-shortfall kelly-fraction volatility-target-position
  drawdown-series max-drawdown portfolio-variance portfolio-volatility
  portfolio-risk-contributions stress-loss risk-decision)
