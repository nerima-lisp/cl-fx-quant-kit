(in-package #:fx-quant-kit)

(define-condition quantitative-error (error)
  ()
  (:report
   (lambda (condition stream)
     (declare (ignore condition))
     (format stream "Quantitative calculation failed."))))

(define-condition invalid-argument (quantitative-error)
  ((name :initarg :name :reader invalid-argument-name)
   (value :initarg :value :reader invalid-argument-value))
  (:report
   (lambda (condition stream)
     (format stream "Invalid argument ~S: ~S"
             (invalid-argument-name condition)
             (invalid-argument-value condition)))))

(define-condition invalid-shape (quantitative-error)
  ((expected :initarg :expected :reader invalid-shape-expected)
   (actual :initarg :actual :reader invalid-shape-actual))
  (:report
   (lambda (condition stream)
     (format stream "Invalid shape; expected ~S, got ~S"
             (invalid-shape-expected condition)
             (invalid-shape-actual condition)))))

(define-condition insufficient-data (quantitative-error)
  ((required :initarg :required :reader insufficient-data-required)
   (actual :initarg :actual :reader insufficient-data-actual))
  (:report
   (lambda (condition stream)
     (format stream "Insufficient data; require at least ~D observations, got ~D"
             (insufficient-data-required condition)
             (insufficient-data-actual condition)))))

(define-condition numerical-error (quantitative-error)
  ((operation :initarg :operation :reader numerical-error-operation))
  (:report
   (lambda (condition stream)
     (format stream "Numerical calculation failed during ~A"
             (numerical-error-operation condition)))))

(define-condition domain-error (quantitative-error)
  ((operation :initarg :operation :reader domain-error-operation)
   (value :initarg :value :reader domain-error-value))
  (:report
   (lambda (condition stream)
     (format stream "Domain error during ~A for value ~S"
             (domain-error-operation condition)
             (domain-error-value condition)))))
