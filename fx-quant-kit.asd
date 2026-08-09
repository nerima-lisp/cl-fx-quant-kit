(in-package #:asdf-user)

(defsystem "fx-quant-kit"
  :description "A pure quantitative finance toolkit for Common Lisp."
  :long-description "Pure numerical, market-data, FX, pricing, indicator, simulation, risk, time, and JSON primitives with deterministic contracts."
  :author "fx-quant-kit contributors"
  :maintainer "fx-quant-kit contributors"
  :version "0.5.0"
  :homepage "https://github.com/nerima-lisp/cl-fx-quant-kit"
  :bug-tracker "https://github.com/nerima-lisp/cl-fx-quant-kit/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-fx-quant-kit.git")
  :license "MIT"
  :depends-on ("cl-date-kit" "cl-json-kit" "cl-prolog")
  :pathname "src"
  :serial t
  :components ((:file "package")
               (:file "conditions")
               (:file "validation")
               (:file "macros")
               (:file "core")
               (:file "statistics")
               (:file "analytics-moments")
               (:file "analytics-ratios")
               (:file "analytics-matrices")
               (:file "market-data")
               (:file "time")
               (:file "fx")
               (:file "fx-calculations")
               (:file "serialization")
               (:file "indicator-data")
               (:file "indicators-moving")
               (:file "indicators-oscillators")
               (:file "indicators-volatility")
               (:file "indicators-regime")
               (:file "pricing-data")
               (:file "pricing-core")
               (:file "pricing-greeks")
               (:file "pricing-contracts")
               (:file "pricing-implied-volatility")
               (:file "simulation")
               (:file "simulation-monte-carlo")
               (:file "risk-data")
               (:file "risk")
               (:file "risk-portfolio")
               (:file "rules-data")
               (:file "rules")
               (:file "cps")
               (:file "cps-macros"))
  :in-order-to ((test-op (test-op "fx-quant-kit/test"))))

(defsystem "fx-quant-kit/test"
  :description "Tests for fx-quant-kit."
  :long-description "Deterministic contract and numerical tests for fx-quant-kit."
  :author "fx-quant-kit contributors"
  :maintainer "fx-quant-kit contributors"
  :version "0.5.0"
  :homepage "https://github.com/nerima-lisp/cl-fx-quant-kit"
  :bug-tracker "https://github.com/nerima-lisp/cl-fx-quant-kit/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-fx-quant-kit.git")
  :license "MIT"
  :depends-on ("fx-quant-kit" "cl-weave")
  :pathname "t"
  :serial t
  :components ((:file "package")
               (:file "core-tests")
               (:file "statistics-tests")
               (:file "market-tests")
               (:file "market-extension-tests")
               (:file "indicator-tests")
               (:file "pricing-tests")
               (:file "pricing-extension-tests")
               (:file "risk-tests")
               (:file "macro-cps-tests")
               (:file "advanced-tests")
               (:file "simulation-extension-tests")
               (:file "portfolio-extension-tests")
               (:file "analytics-tests")
               (:file "contracts-tests")
               (:file "boundary-tests")
               (:file "edge-contract-tests"))
  :perform (test-op (operation component)
             (declare (ignore operation component))
             (unless (uiop:symbol-call :fx-quant-kit/test :run-tests)
               (error "fx-quant-kit test suite failed."))))
