(in-package #:fx-quant-kit/test)

(describe "pricing and simulation"
  (it "prices Black-Scholes calls and puts"
    (let ((call (black-scholes-price 100d0 100d0 1d0 0.2d0 0.05d0))
          (put (black-scholes-price 100d0 100d0 1d0 0.2d0 0.05d0
                                    :option-type :put)))
      (expect call :to-be-close-to 10.4505835722d0 7)
      (expect put :to-be-close-to 5.5735260223d0 7)
      (expect (- call put) :to-be-close-to
              (- 100d0 (* 100d0 (exp -0.05d0))) 7)))

  (it "returns coherent Greeks and implied volatility"
    (let* ((price (black-scholes-price 100d0 100d0 1d0 0.2d0 0.05d0))
           (greeks (black-scholes-greeks 100d0 100d0 1d0 0.2d0 0.05d0))
           (volatility (implied-volatility price 100d0 100d0 1d0 0.05d0)))
      (expect (greeks-price greeks) :to-be-close-to price 10)
      (expect (greeks-delta greeks) :to-be-close-to 0.6368306512d0 7)
      (expect (greeks-gamma greeks) :to-be-truthy)
      (expect (greeks-vega greeks) :to-be-truthy)
      (expect volatility :to-be-close-to 0.2d0 7)))

  (it "uses the correct dividend-adjusted put delta"
    (let* ((call (black-scholes-greeks 100d0 100d0 1d0 0.2d0 0.05d0
                                       :dividend-yield 0.02d0))
           (put (black-scholes-greeks 100d0 100d0 1d0 0.2d0 0.05d0
                                      :dividend-yield 0.02d0
                                      :option-type :put)))
      (expect (greeks-delta put)
              :to-be-close-to
              (- (greeks-delta call) (exp -0.02d0)) 12)))

  (it "keeps simulations deterministic with explicit RNG state"
    (let* ((left (make-simulation-rng 42))
           (right (make-simulation-rng 42))
           (left-uniform (rng-uniform left))
           (right-uniform (rng-uniform right))
           (paths (simulate-geometric-brownian-motion
                   100d0 0d0 0d0 0.25d0 2 2
                   :rng (make-simulation-rng 7)))
           (ou (simulate-ornstein-uhlenbeck
                0d0 1d0 10d0 0d0 1d0 1 1
                :rng (make-simulation-rng 7))))
      (expect left-uniform :to-be-close-to right-uniform 15)
      (loop for path across paths
            do (expect-vector-close path #(100d0 100d0 100d0) 10))
      (expect (aref (aref ou 0) 1)
              :to-be-close-to (* 10d0 (- 1d0 (exp -1d0))) 10))))
