(in-package #:fx-quant-kit)

(define-value-record macd-result
  ((line nil :read-only t)
   (signal nil :read-only t)
   (histogram nil :read-only t)))

(defun make-macd-result (line signal histogram)
  (%make-macd-result (%copy-vector line)
                     (%copy-vector signal)
                          (%copy-vector histogram)))
(define-value-record bollinger-result
  ((middle nil :read-only t)
   (upper nil :read-only t)
   (lower nil :read-only t)))

(defun make-bollinger-result (middle upper lower)
  (%make-bollinger-result (%copy-vector middle)
                          (%copy-vector upper)
                          (%copy-vector lower)))
