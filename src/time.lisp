(in-package #:fx-quant-kit)

(defun timestamp->instant (timestamp)
  "Convert a non-negative Unix-epoch microsecond timestamp to an instant."
  (unless (and (integerp timestamp) (>= timestamp 0))
    (error 'invalid-argument :name 'timestamp :value timestamp))
  (cl-date-kit:instant-of-epoch-micros timestamp))

(defun instant->timestamp (instant)
  "Convert a date-kit instant to a non-negative Unix-epoch microsecond value."
  (unless (cl-date-kit:instant-p instant)
    (error 'invalid-argument :name 'instant :value instant))
  (let ((timestamp (cl-date-kit:instant-to-epoch-micros instant)))
    (unless (and (integerp timestamp) (>= timestamp 0))
      (error 'invalid-argument :name 'instant :value instant))
    timestamp))

(defun timestamp->iso8601 (timestamp)
  "Return the canonical UTC ISO-8601 representation of TIMESTAMP."
  (cl-date-kit:format-instant (timestamp->instant timestamp)))

(defun iso8601->timestamp (text)
  "Parse an ISO-8601 instant and return a Unix-epoch microsecond timestamp."
  (unless (stringp text)
    (error 'invalid-argument :name 'text :value text))
  (handler-case
      (instant->timestamp (cl-date-kit:parse-instant text))
    (error ()
      (error 'invalid-argument :name 'text :value text))))
