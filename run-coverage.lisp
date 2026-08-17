(progn
  #.(progn (require :asdf) (require :sb-cover) nil)

  (defun script-directory ()
    (make-pathname :name nil
                   :type nil
                   :defaults (or *load-truename*
                                 *compile-file-truename*
                                 (error "Unable to determine the script location"))))

  (defun project-root ()
    (uiop:ensure-directory-pathname (script-directory)))

  (defun configure-local-source-registry (root)
    (asdf:initialize-source-registry
     `(:source-registry
       (:tree ,root)
       :inherit-configuration)))

  (defun coverage-arguments ()
    (remove "--" (uiop:command-line-arguments) :test #'string=))

  (defun output-directory (root)
    (let ((arguments (coverage-arguments)))
      (when (> (length arguments) 1)
        (error "Expected at most one coverage output directory, got ~S"
               arguments))
      (ensure-directories-exist
       (if arguments
           (uiop:ensure-directory-pathname
            (uiop:parse-native-namestring (first arguments)))
           (merge-pathnames "coverage/" root)))))

  (defun preload-dependencies ()
    (dolist (system '("cl-weave" "cl-date-kit" "cl-json-kit" "cl-prolog-kit"))
      (asdf:load-system system)))

  (defun coverage-excluded-pathnames (root)
    "Exclude declaration and definition-only sources from runtime coverage.

These files are exercised by compilation and system loading.  Their contracts
are tested through macroexpansion and public behavior, while executable
calculation functions remain in the measured source set."
    (let ((source (merge-pathnames "src/" root)))
      (mapcar (lambda (name) (merge-pathnames name source))
              '("package.lisp"
                "conditions.lisp"
                "macros.lisp"
                "cps-macros.lisp"
                "rules-data.lisp"))))

  (defun run-coverage (root output)
    ;; Resolve the system definition before installing the scoped compiler
    ;; hook.  The project itself is loaded only after the hook is active, so
    ;; top-level executable forms are measured together with their functions.
    (let ((project-system (asdf:find-system "fx-quant-kit")))
      ;; Only source files belonging to this system are instrumented.  A
      ;; global proclamation would also recompile dependencies and can make
      ;; package initialization order observable in their source files.
      (defmethod asdf:perform :around
          ((operation asdf:compile-op) (component asdf:cl-source-file))
        (declare (ignore operation))
        (if (eq (asdf:component-system component) project-system)
            (progn
              (proclaim '(optimize (sb-cover:store-coverage-data 3)))
              (unwind-protect
                   (call-next-method)
                (proclaim '(optimize (sb-cover:store-coverage-data 0)))))
            (call-next-method)))
      (unwind-protect
           (progn
             ;; Dependencies are preloaded before the project is compiled.
             ;; The normal ASDF output translation is retained so different
             ;; systems with the same basename (for example package.lisp)
             ;; cannot overwrite one another in a flattened cache.
             ;; Load the project under the scoped hook, then force-load its
             ;; test system so the current sources are used.
             (asdf:load-system "fx-quant-kit" :force t)
             (asdf:load-system "fx-quant-kit/test" :force t)
             (let ((passed
                     (uiop:symbol-call
                      :fx-quant-kit/test
                      :run-tests
                      :coverage t
                      :coverage-output
                      (merge-pathnames "fx-quant-kit.coverage" output)
                      :coverage-report-directory
                      (merge-pathnames "report/" output)
                      :coverage-include-pathnames
                      (list (merge-pathnames "src/" root))
                      :coverage-exclude-pathnames
                      (coverage-excluded-pathnames root)
                      :coverage-minimum-expression 100
                      :coverage-minimum-branch 100)))
               (unless passed
                 (uiop:quit 1)))
             (format t "Coverage reports written to ~A~%" output))
        ;; Never leave the current image globally instrumented after a
        ;; failure.  The hook also restores this proclamation after each
        ;; project component.
        (proclaim '(optimize (sb-cover:store-coverage-data 0))))))

  (let* ((root (project-root))
         (output (output-directory root)))
    (configure-local-source-registry root)
    ;; Resolve dependency packages before compiling the project under the
    ;; coverage proclamation.
    (preload-dependencies)
    (run-coverage root output)
    (uiop:quit 0)))
