# API guide

## Statistics

Use `mean`, `variance`, `standard-deviation`, `covariance`, and `correlation`
for descriptive statistics.  `simple-returns` and `log-returns` operate on
ordered price vectors.  `quantile` uses a deterministic interpolated sample
quantile, which is also the convention used by historical risk metrics.

`normal-pdf`, `normal-cdf`, and `inverse-normal-cdf` accept optional `:mean`
and `:standard-deviation` keywords.  The standard deviation must be positive.

## Market and FX values

`make-market-quote` validates a non-negative epoch-microsecond timestamp and
positive bid/ask prices.  `make-ohlcv-bar` validates OHLC ordering and
non-negative volume.  `make-currency-pair` canonicalizes three-letter codes
and selects the conventional pip size, including the JPY quote convention.
`make-tick-data` stores a validated bid/ask snapshot with sizes;
`tick-data-mid`, `tick-data-spread`, and `tick-data-imbalance` are pure accessors
and calculations.  These values do not fetch, aggregate, or persist market
data.

`fx-cross-rate` composes two quote-per-base rates when the intermediate
currency matches.  `fx-forward-points` and `fx-forward-rate` apply the
continuously compounded carry convention, while `fx-pip-distance`,
`pip-value`, and `fx-pnl` make pip and account-currency units explicit.

## Indicators

Moving averages return vectors aligned to the end of each available window.
Oscillators and volatility functions reject insufficient input rather than
silently padding a series.  `macd` and `bollinger-bands` return typed result
objects so their components cannot be confused by positional convention.

## Pricing and risk

`black-scholes-price` and `black-scholes-greeks` implement the continuously
compounded Black-Scholes/Garman-Kohlhagen model.  `implied-volatility` uses a
bounded deterministic solve.  `historical-var`, `parametric-var`, and their
expected-shortfall counterparts return positive loss amounts; `kelly-fraction`
is intentionally not clipped so a caller can apply its own policy.
`make-option-contract` and `option-contract-price` provide a validated
European call/put contract and payoff.  `discount-factor`, `present-value`,
and `forward-price` are generic continuously compounded curve primitives.

`monte-carlo-estimate` accepts an explicit sampler and RNG and returns the
estimate, sample standard error, and sample count using an online estimator.
`portfolio-volatility` and `portfolio-risk-contributions` accept an explicit
covariance matrix; contributions are signed and sum to portfolio variance.
The risk decision API can additionally evaluate the declarative `cl-prolog`
rules without introducing an execution or persistence layer.

The public numerical API documents units and boundary rules at its contract
boundaries.  Invalid input signals an exported condition instead of returning
a sentinel.  Continuation wrappers are generated as `/k` functions with the
same argument and result contracts as their direct counterparts.
