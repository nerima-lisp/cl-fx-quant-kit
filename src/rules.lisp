(in-package #:fx-quant-kit)

(defun risk-decision (state)
  "Evaluate deterministic guardrail rules against a validated state record.

The rule order is intentional: blackout, drawdown, and volatility are
reported in that precedence order.  The rulebase is expressed through
CL-PROLOG-KIT's macro-first DSL, while all domain data remains an ordinary value
record that can be created and tested independently."
  (unless (risk-decision-state-p state)
    (error 'invalid-argument :name :state :value state))
  (multiple-value-bind (solution foundp)
      (cl-prolog-kit:query-prolog-first
       *risk-decision-rules*
       (list (list 'decision '?action '?reason state)))
    (unless foundp
      (error 'numerical-error :operation 'risk-decision))
    (make-risk-decision-result
     (cl-prolog-kit:solution-binding '?action solution)
     (cl-prolog-kit:solution-binding '?reason solution)
     state)))
