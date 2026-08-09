(in-package #:fx-quant-kit)

(defconstant +simulation-modulus+ 2147483647)
(defconstant +simulation-multiplier+ 48271)
(defconstant +simulation-modulus-double+ 2147483647d0)

(defstruct (simulation-rng
             (:constructor %make-simulation-rng (seed)))
  (seed 1 :type integer))

(defun make-simulation-rng (&optional (seed 1))
  "Create an explicit Park-Miller pseudo-random state.

The state is intentionally passed to simulation functions rather than stored
in a package global.  Any integer seed is accepted and reduced to the
generator's nonzero state range."
  (unless (integerp seed)
    (error 'invalid-argument :name :seed :value seed))
  (let ((normalized (mod seed +simulation-modulus+)))
    (%make-simulation-rng (if (zerop normalized) 1 normalized))))

(defun %ensure-rng (rng)
  (unless (simulation-rng-p rng)
    (error 'invalid-argument :name :rng :value rng))
  rng)

(defun %rng-uniform (rng)
  (let* ((next (mod (* +simulation-multiplier+ (simulation-rng-seed rng))
                    +simulation-modulus+))
         (state (if (zerop next) 1 next)))
    (setf (simulation-rng-seed rng) state)
    (/ (coerce state 'double-float) +simulation-modulus-double+)))

(defun rng-uniform (rng)
  "Advance RNG and return a double-float uniform variate in (0, 1)."
  (%rng-uniform (%ensure-rng rng)))

(defun %rng-normal (rng)
  (let* ((u1 (%rng-uniform rng))
         (u2 (%rng-uniform rng)))
    (* (sqrt (* -2d0 (log u1)))
       (cos (* 2d0 pi u2)))))

(defun rng-normal (rng)
  "Advance RNG and return a standard normal variate."
  (let* ((rng (%ensure-rng rng))
         (u1 (rng-uniform rng))
         (u2 (rng-uniform rng)))
    (* (sqrt (* -2d0 (log u1)))
       (cos (* 2d0 pi u2)))))

(defun %ensure-count (value name)
  (unless (and (integerp value) (plusp value))
    (error 'invalid-argument :name name :value value))
  value)

(defun %ensure-simulation-rng (rng)
  (%ensure-rng rng))

(defun %simulate-paths (initial-value steps paths rng transition)
  (let ((result (make-array paths)))
    (dotimes (path-index paths result)
      (let ((path (make-array (1+ steps) :element-type 'double-float)))
        (setf (aref path 0) initial-value)
        (loop for step from 1 to steps
              for previous = (aref path (1- step))
              for shock = (rng-normal rng)
              do (setf (aref path step)
                       (funcall transition previous shock)))
        (setf (aref result path-index) path)))))

(defun %simulate-geometric-brownian-paths
    (initial-value steps paths rng drift-term diffusion-term)
  (let ((result (make-array paths)))
    (dotimes (path-index paths result)
      (let ((path (make-array (1+ steps) :element-type 'double-float)))
        (setf (aref path 0) initial-value)
        (loop for step from 1 to steps
              for previous = (aref path (1- step))
              for shock = (%rng-normal rng)
              do (setf (aref path step)
                       (* previous
                          (exp (+ drift-term (* diffusion-term shock))))))
        (setf (aref result path-index) path)))))

(defun %simulate-ornstein-uhlenbeck-paths
    (initial-value steps paths rng long-term-mean decay innovation-scale)
  (let ((result (make-array paths)))
    (dotimes (path-index paths result)
      (let ((path (make-array (1+ steps) :element-type 'double-float)))
        (setf (aref path 0) initial-value)
        (loop for step from 1 to steps
              for previous = (aref path (1- step))
              for shock = (%rng-normal rng)
              do (setf (aref path step)
                       (+ long-term-mean
                          (* (- previous long-term-mean) decay)
                          (* innovation-scale shock))))
        (setf (aref result path-index) path)))))

(defun %ornstein-uhlenbeck-innovation-scale
    (mean-reversion-speed volatility time-step)
  (if (zerop mean-reversion-speed)
      (* volatility (sqrt time-step))
      (* volatility
         (sqrt (/ (- 1d0
                      (exp (- (* 2d0 mean-reversion-speed time-step))))
                  (* 2d0 mean-reversion-speed))))))

(defun simulate-geometric-brownian-motion
    (initial-value drift volatility time-step steps paths
     &key (rng (make-simulation-rng 1)))
  "Return PATHS geometric-Brownian paths, each including its initial value.

The Euler grid has STEPS increments of TIME-STEP years.  DRIFT and VOLATILITY
are annualized.  RNG is mutable explicit state, making repeated experiments
reproducible when created from the same seed."
  (let* ((initial-value (ensure-positive initial-value :initial-value))
         (drift (ensure-finite drift :drift))
         (volatility (ensure-non-negative volatility :volatility))
         (time-step (ensure-positive time-step :time-step))
         (steps (%ensure-count steps :steps))
         (paths (%ensure-count paths :paths)))
    (let* ((rng (%ensure-simulation-rng rng))
           (sqrt-time-step (sqrt time-step))
           (drift-term
             (* (- drift (* 0.5d0 (expt volatility 2))) time-step))
           (diffusion-term (* volatility sqrt-time-step)))
      (%simulate-geometric-brownian-paths
       initial-value steps paths rng drift-term diffusion-term))))

(defun simulate-ornstein-uhlenbeck
    (initial-value mean-reversion-speed long-term-mean volatility
     time-step steps paths
     &key (rng (make-simulation-rng 1)))
  "Return PATHS exact-grid Ornstein-Uhlenbeck paths.

The process is dX = K(M-X)dt + SIGMA dW.  When K is positive, the exact
conditional Gaussian transition is used; K equal to zero reduces to a normal
random walk."
  (let* ((initial-value (ensure-finite initial-value :initial-value))
         (mean-reversion-speed
           (ensure-non-negative mean-reversion-speed :mean-reversion-speed))
         (long-term-mean (ensure-finite long-term-mean :long-term-mean))
         (volatility (ensure-non-negative volatility :volatility))
         (time-step (ensure-positive time-step :time-step))
         (steps (%ensure-count steps :steps))
         (paths (%ensure-count paths :paths)))
    (let* ((rng (%ensure-simulation-rng rng))
           (decay (exp (- (* mean-reversion-speed time-step))))
           (innovation-scale
             (%ornstein-uhlenbeck-innovation-scale
              mean-reversion-speed volatility time-step)))
      (%simulate-ornstein-uhlenbeck-paths
       initial-value steps paths rng long-term-mean decay innovation-scale))))
