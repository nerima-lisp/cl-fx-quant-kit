(in-package #:fx-quant-kit)

(defparameter *risk-decision-rules*
  (cl-prolog-kit:prolog
    ((decision :block :blackout ?state)
     (:when (risk-decision-state-blackout-p ?state)))
    ((decision :block :drawdown ?state)
     (:when (>= (risk-decision-state-drawdown ?state)
                (risk-decision-state-max-drawdown ?state))))
    ((decision :block :volatility ?state)
     (:when (>= (risk-decision-state-volatility ?state)
                (risk-decision-state-max-volatility ?state))))
    ((decision :allow :none ?state)
     (:when (and (not (risk-decision-state-blackout-p ?state))
                 (< (risk-decision-state-drawdown ?state)
                    (risk-decision-state-max-drawdown ?state))
                 (< (risk-decision-state-volatility ?state)
                    (risk-decision-state-max-volatility ?state)))))))
