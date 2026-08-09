(in-package #:fx-quant-kit)

(defun %proper-list-p (value)
  "Return true when VALUE is a proper list, including NIL."
  (and (listp value)
       (handler-case
           (progn
             (length value)
             t)
         (type-error () nil))))

(defun %validate-value-record-slot (slot)
  "Validate one ordinary DEFSTRUCT slot specification for the record DSL."
  (unless (or (symbolp slot)
              (and (consp slot)
                   (%proper-list-p slot)))
    (error "Value-record slot must be a symbol or proper list: ~S" slot))
  (let ((name (if (symbolp slot) slot (first slot)))
        (options (and (consp slot) (cddr slot))))
    (unless (symbolp name)
      (error "Value-record slot name must be a symbol: ~S" name))
    (unless (evenp (length options))
      (error "Value-record slot options must be keyword/value pairs: ~S"
             slot))
    (loop for option in options by #'cddr
          unless (keywordp option)
            do (error "Value-record slot option must be a keyword: ~S"
                      option)))
  slot)

(defun %validate-value-record (name slots)
  "Validate the macro-time contract of DEFINE-VALUE-RECORD."
  (unless (symbolp name)
    (error "Value-record name must be a symbol: ~S" name))
  (unless (%proper-list-p slots)
    (error "Value-record slots must be a proper list: ~S" slots))
  (mapc #'%validate-value-record-slot slots)
  slots)

(defun %record-slot-names (slots)
  (mapcar (lambda (slot)
            (if (symbolp slot)
                slot
                (first slot)))
          slots))

(defun %immutable-slot-spec (slot)
  "Return a DEFSTRUCT slot specification with a read-only accessor.

The value-record DSL deliberately makes immutability a property of the
generated record, rather than a convention callers have to remember.  The
ordinary DEFSTRUCT syntax remains accepted, including :TYPE and other slot
  options."
  (if (symbolp slot)
      `(,slot nil :read-only t)
      (let ((name (first slot))
            (initform (second slot))
            (options (cddr slot)))
        `(,name ,initform
                ,@(loop for (option value) on options by #'cddr
                        unless (eq option :read-only)
                          append (list option value))
                :read-only t))))

(defmacro define-value-record (name slots &key conc-name)
  "Define an immutable value record with a private constructor.

SLOTS uses the ordinary DEFSTRUCT slot syntax.  The public constructor can be
defined separately when validation or normalization is required, while the
generated constructor remains private to the implementation package.  Every
slot is emitted with :READ-ONLY T, even when the option is omitted from SLOTS."
  (%validate-value-record name slots)
  (let ((constructor
          (intern (format nil "%MAKE-~A" (symbol-name name))
                  (symbol-package name)))
        (immutable-slots (mapcar #'%immutable-slot-spec slots)))
    `(defstruct (,name
                 (:constructor ,constructor
                     ,(%record-slot-names slots))
                 (:copier nil)
                 ,@(when conc-name
                     `((:conc-name ,conc-name))))
       ,@immutable-slots)))
