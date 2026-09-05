(in-package #:fx-quant-kit/test)

(describe
  "value records, CPS, and declarative risk rules"
  (it
    "keeps risk state and decisions as validated value data"
    (let* ((state (make-risk-decision-state
                   :drawdown 0.25d0
                   :max-drawdown 0.20d0
                   :volatility 0.10d0
                   :max-volatility 0.30d0))
           (decision (risk-decision state)))
      (expect (risk-decision-state-p state) :to-be t)
      (expect (risk-decision-result-p decision) :to-be t)
      (expect (risk-decision-result-action decision) :to-be :block)
      (expect (risk-decision-result-reason decision) :to-be :drawdown)
      (expect (risk-decision-result-state decision) :to-be state)))

  (it
    "uses CPS wrappers"
    (with-cps-result (result mean/k #(1d0 2d0 3d0))
      (expect result :to-be-close-to 2d0 10))
    (with-cps-result (series sma/k #(1d0 2d0 3d0) 2)
      (expect (length series) :to-be 3)
      (expect (aref series 0) :to-be nil)
      (expect (aref series 1) :to-be-close-to 1.5d0 10)
      (expect (aref series 2) :to-be-close-to 2.5d0 10))
    (with-cps-result (price black-scholes-price/k
                             100d0 100d0 1d0 0.2d0 0.05d0)
      (expect price :to-be-close-to 10.450583572185565d0 8))
    (let ((state (make-risk-decision-state :blackout-p t)))
      (with-cps-result (decision risk-decision/k state)
        (expect (risk-decision-result-reason decision)
                :to-be
                :blackout)))
    (signals invalid-argument
             (mean/k #(1d0 2d0 3d0) nil))))

(cl-weave:it-property
 "the arithmetic kernel is translation equivariant"
 ((left (cl-weave:gen-integer :min -100 :max 100))
  (right (cl-weave:gen-integer :min -100 :max 100)))
 (let* ((values (vector (coerce left 'double-float)
                        (coerce right 'double-float)))
        (actual (mean values))
        (expected (/ (+ left right) 2d0)))
   (expect actual :to-be-close-to expected 10)))

(cl-weave:it-fuzz
 "normal CDF remains a probability"
 ((value (cl-weave:gen-integer :min -8 :max 8)))
 (:trials 16 :timeout-per-trial 1)
 (let ((cdf (normal-cdf (coerce value 'double-float))))
   (expect (<= 0d0 cdf 1d0) :to-be t)))
