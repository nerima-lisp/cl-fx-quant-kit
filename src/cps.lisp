(in-package #:fx-quant-kit)

(defun %split-continuation-arguments (arguments)
  "Split callback-last ARGUMENTS and validate the continuation contract."
  (unless (consp arguments)
    (error 'invalid-argument :name :continuation :value nil))
  (let ((continuation (car (last arguments))))
    (unless (functionp continuation)
      (error 'invalid-argument :name :continuation :value continuation))
    (values (butlast arguments) continuation)))

(defun %invoke-continuation (function arguments continuation)
  (unless (functionp continuation)
    (error 'invalid-argument :name :continuation :value continuation))
  (multiple-value-call continuation
    (apply function arguments)))
