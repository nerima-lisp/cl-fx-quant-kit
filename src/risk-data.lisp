(in-package #:fx-quant-kit)

(define-value-record risk-decision-state
  ((blackout-p nil :read-only t)
   (drawdown 0d0 :type double-float :read-only t)
   (max-drawdown 1d0 :type double-float :read-only t)
   (volatility 0d0 :type double-float :read-only t)
   (max-volatility 1d0 :type double-float :read-only t)))

(defun make-risk-decision-state (&key (blackout-p nil) (drawdown 0d0)
                                      (max-drawdown 1d0) (volatility 0d0)
                                      (max-volatility 1d0))
  (unless (member blackout-p '(nil t) :test #'eq)
    (error 'invalid-argument :name :blackout-p :value blackout-p))
  (%make-risk-decision-state
   blackout-p
   (ensure-non-negative drawdown :drawdown)
   (ensure-positive max-drawdown :max-drawdown)
   (ensure-non-negative volatility :volatility)
   (ensure-positive max-volatility :max-volatility)))

(define-value-record risk-decision-result
  ((action nil :read-only t)
   (reason nil :read-only t)
   (state nil :read-only t)))

(defun make-risk-decision-result (action reason state)
  (unless (member action '(:allow :block) :test #'eq)
    (error 'invalid-argument :name :action :value action))
  (unless (member reason '(:none :blackout :drawdown :volatility) :test #'eq)
    (error 'invalid-argument :name :reason :value reason))
  (unless (risk-decision-state-p state)
    (error 'invalid-argument :name :state :value state))
  (%make-risk-decision-result action reason state))
