# API Reference

The public API belongs to the `FX-QUANT-KIT` package. Function arguments
are shown in Common Lisp notation. Unless stated otherwise, numeric results are
double-floats and invalid inputs signal one of the typed conditions described
in [Conditions](conditions.md).

This page is a compact index; see [Getting Started](../getting-started.md) and
[Core Concepts](../guide/core-concepts.md) for runnable workflows.

## Conditions and validation

### `quantitative-error`

Base condition for errors raised by quantitative calculations.

### `invalid-argument`

Condition for an argument that violates a value constraint.

### `invalid-argument-name`

Reader for the name of an invalid argument.

### `invalid-argument-value`

Reader for the value of an invalid argument.

### `invalid-shape`

Condition for a vector or matrix with an unexpected shape.

### `invalid-shape-expected`

Reader for the expected shape.

### `invalid-shape-actual`

Reader for the actual shape.

### `insufficient-data`

Condition for a calculation that needs more observations than supplied.

### `insufficient-data-required`

Reader for the required observation count.

### `insufficient-data-actual`

Reader for the supplied observation count.

### `numerical-error`

Condition for an algorithm that cannot produce a finite result.

### `numerical-error-operation`

Reader for the calculation that failed numerically.

### `domain-error`

Condition for an input outside a mathematical domain.

### `domain-error-operation`

Reader for the operation whose domain was violated.

### `domain-error-value`

Reader for the value outside that domain.

### `ensure-real`

```lisp
(fx-quant-kit:ensure-real value name)
  => value
```

Returns a real value or signals `invalid-argument`.

### `ensure-finite`

```lisp
(fx-quant-kit:ensure-finite value name)
  => value
```

Returns a finite double-float or signals `invalid-argument`.

### `ensure-positive`

```lisp
(fx-quant-kit:ensure-positive value name)
  => value
```

Validates and returns a strictly positive real value.

### `ensure-non-negative`

```lisp
(fx-quant-kit:ensure-non-negative value name)
  => value
```

Validates and returns a real value greater than or equal to zero.

### `ensure-probability`

```lisp
(fx-quant-kit:ensure-probability value name)
  => value
```

Validates and returns a value in the closed interval `[0, 1]`.

### `approx=`

```lisp
(fx-quant-kit:approx= left right &key absolute-tolerance relative-tolerance)
  => value
```

Compares finite real values using absolute and scale-aware relative
tolerances. It returns a generalized boolean.

## Macro and continuation DSL

### `define-value-record`

```lisp
(fx-quant-kit:define-value-record name slots &key conc-name)
  => value
```

Defines an immutable value record with validated, read-only accessors. The
macro is the common record boundary used by market, FX, indicator, pricing,
and risk values.

### `define-cps-wrapper`

```lisp
(fx-quant-kit:define-cps-wrapper name)
  => value
```

Defines a callback-last `name/k` wrapper around `name` without
duplicating the calculation.

### `define-cps-wrappers`

```lisp
(fx-quant-kit:define-cps-wrappers &rest names)
  => value
```

Defines callback-last wrappers for several calculation functions.

The generated wrappers use the concrete signature
`(wrapper-name/k &rest arguments)`. The final argument must be a
function; the preceding arguments are passed to the direct function, and all
returned values are passed to the continuation.

### `mean/k`

```lisp
(fx-quant-kit:mean/k &rest arguments)
  => value
```

Callback-last wrapper for `mean`.

### `weighted-mean/k`

```lisp
(fx-quant-kit:weighted-mean/k &rest arguments)
  => value
```

Callback-last wrapper for `weighted-mean`.

### `variance/k`

```lisp
(fx-quant-kit:variance/k &rest arguments)
  => value
```

Callback-last wrapper for `variance`.

### `standard-deviation/k`

```lisp
(fx-quant-kit:standard-deviation/k &rest arguments)
  => value
```

Callback-last wrapper for `standard-deviation`.

### `covariance/k`

```lisp
(fx-quant-kit:covariance/k &rest arguments)
  => value
```

Callback-last wrapper for `covariance`.

### `correlation/k`

```lisp
(fx-quant-kit:correlation/k &rest arguments)
  => value
```

Callback-last wrapper for `correlation`.

### `sum-of-squares/k`

```lisp
(fx-quant-kit:sum-of-squares/k &rest arguments)
  => value
```

Callback-last wrapper for `sum-of-squares`.

### `simple-returns/k`

```lisp
(fx-quant-kit:simple-returns/k &rest arguments)
  => value
```

Callback-last wrapper for `simple-returns`.

### `log-returns/k`

```lisp
(fx-quant-kit:log-returns/k &rest arguments)
  => value
```

Callback-last wrapper for `log-returns`.

### `cumulative-return/k`

```lisp
(fx-quant-kit:cumulative-return/k &rest arguments)
  => value
```

Callback-last wrapper for `cumulative-return`.

### `quantile/k`

```lisp
(fx-quant-kit:quantile/k &rest arguments)
  => value
```

Callback-last wrapper for `quantile`.

### `median/k`

```lisp
(fx-quant-kit:median/k &rest arguments)
  => value
```

Callback-last wrapper for `median`.

### `normal-pdf/k`

```lisp
(fx-quant-kit:normal-pdf/k &rest arguments)
  => value
```

Callback-last wrapper for `normal-pdf`.

### `normal-cdf/k`

```lisp
(fx-quant-kit:normal-cdf/k &rest arguments)
  => value
```

Callback-last wrapper for `normal-cdf`.

### `inverse-normal-cdf/k`

```lisp
(fx-quant-kit:inverse-normal-cdf/k &rest arguments)
  => value
```

Callback-last wrapper for `inverse-normal-cdf`.

### `skewness/k`

```lisp
(fx-quant-kit:skewness/k &rest arguments)
  => value
```

Callback-last wrapper for `skewness`.

### `excess-kurtosis/k`

```lisp
(fx-quant-kit:excess-kurtosis/k &rest arguments)
  => value
```

Callback-last wrapper for `excess-kurtosis`.

### `sharpe-ratio/k`

```lisp
(fx-quant-kit:sharpe-ratio/k &rest arguments)
  => value
```

Callback-last wrapper for `sharpe-ratio`.

### `sortino-ratio/k`

```lisp
(fx-quant-kit:sortino-ratio/k &rest arguments)
  => value
```

Callback-last wrapper for `sortino-ratio`.

### `beta/k`

```lisp
(fx-quant-kit:beta/k &rest arguments)
  => value
```

Callback-last wrapper for `beta`.

### `tracking-error/k`

```lisp
(fx-quant-kit:tracking-error/k &rest arguments)
  => value
```

Callback-last wrapper for `tracking-error`.

### `information-ratio/k`

```lisp
(fx-quant-kit:information-ratio/k &rest arguments)
  => value
```

Callback-last wrapper for `information-ratio`.

### `covariance-matrix/k`

```lisp
(fx-quant-kit:covariance-matrix/k &rest arguments)
  => value
```

Callback-last wrapper for `covariance-matrix`.

### `correlation-matrix/k`

```lisp
(fx-quant-kit:correlation-matrix/k &rest arguments)
  => value
```

Callback-last wrapper for `correlation-matrix`.

### `fx-forward-rate/k`

```lisp
(fx-quant-kit:fx-forward-rate/k &rest arguments)
  => value
```

Callback-last wrapper for `fx-forward-rate`.

### `fx-forward-points/k`

```lisp
(fx-quant-kit:fx-forward-points/k &rest arguments)
  => value
```

Callback-last wrapper for `fx-forward-points`.

### `fx-cross-rate/k`

```lisp
(fx-quant-kit:fx-cross-rate/k &rest arguments)
  => value
```

Callback-last wrapper for `fx-cross-rate`.

### `fx-pip-distance/k`

```lisp
(fx-quant-kit:fx-pip-distance/k &rest arguments)
  => value
```

Callback-last wrapper for `fx-pip-distance`.

### `fx-pnl/k`

```lisp
(fx-quant-kit:fx-pnl/k &rest arguments)
  => value
```

Callback-last wrapper for `fx-pnl`.

### `pip-value/k`

```lisp
(fx-quant-kit:pip-value/k &rest arguments)
  => value
```

Callback-last wrapper for `pip-value`.

### `sma/k`

```lisp
(fx-quant-kit:sma/k &rest arguments)
  => value
```

Callback-last wrapper for `sma`.

### `ema/k`

```lisp
(fx-quant-kit:ema/k &rest arguments)
  => value
```

Callback-last wrapper for `ema`.

### `wilder-average/k`

```lisp
(fx-quant-kit:wilder-average/k &rest arguments)
  => value
```

Callback-last wrapper for `wilder-average`.

### `rsi/k`

```lisp
(fx-quant-kit:rsi/k &rest arguments)
  => value
```

Callback-last wrapper for `rsi`.

### `macd/k`

```lisp
(fx-quant-kit:macd/k &rest arguments)
  => value
```

Callback-last wrapper for `macd`.

### `bollinger-bands/k`

```lisp
(fx-quant-kit:bollinger-bands/k &rest arguments)
  => value
```

Callback-last wrapper for `bollinger-bands`.

### `true-range/k`

```lisp
(fx-quant-kit:true-range/k &rest arguments)
  => value
```

Callback-last wrapper for `true-range`.

### `atr/k`

```lisp
(fx-quant-kit:atr/k &rest arguments)
  => value
```

Callback-last wrapper for `atr`.

### `hurst-exponent/k`

```lisp
(fx-quant-kit:hurst-exponent/k &rest arguments)
  => value
```

Callback-last wrapper for `hurst-exponent`.

### `garch11-variance/k`

```lisp
(fx-quant-kit:garch11-variance/k &rest arguments)
  => value
```

Callback-last wrapper for `garch11-variance`.

### `garch11-forecast/k`

```lisp
(fx-quant-kit:garch11-forecast/k &rest arguments)
  => value
```

Callback-last wrapper for `garch11-forecast`.

### `realized-volatility/k`

```lisp
(fx-quant-kit:realized-volatility/k &rest arguments)
  => value
```

Callback-last wrapper for `realized-volatility`.

### `black-scholes-price/k`

```lisp
(fx-quant-kit:black-scholes-price/k &rest arguments)
  => value
```

Callback-last wrapper for `black-scholes-price`.

### `black-scholes-greeks/k`

```lisp
(fx-quant-kit:black-scholes-greeks/k &rest arguments)
  => value
```

Callback-last wrapper for `black-scholes-greeks`.

### `implied-volatility/k`

```lisp
(fx-quant-kit:implied-volatility/k &rest arguments)
  => value
```

Callback-last wrapper for `implied-volatility`.

### `rng-uniform/k`

```lisp
(fx-quant-kit:rng-uniform/k &rest arguments)
  => value
```

Callback-last wrapper for `rng-uniform`.

### `rng-normal/k`

```lisp
(fx-quant-kit:rng-normal/k &rest arguments)
  => value
```

Callback-last wrapper for `rng-normal`.

### `simulate-geometric-brownian-motion/k`

```lisp
(fx-quant-kit:simulate-geometric-brownian-motion/k &rest arguments)
  => value
```

Callback-last wrapper for `simulate-geometric-brownian-motion`.

### `simulate-ornstein-uhlenbeck/k`

```lisp
(fx-quant-kit:simulate-ornstein-uhlenbeck/k &rest arguments)
  => value
```

Callback-last wrapper for `simulate-ornstein-uhlenbeck`.

### `monte-carlo-estimate/k`

```lisp
(fx-quant-kit:monte-carlo-estimate/k &rest arguments)
  => value
```

Callback-last wrapper for `monte-carlo-estimate`.

### `historical-var/k`

```lisp
(fx-quant-kit:historical-var/k &rest arguments)
  => value
```

Callback-last wrapper for `historical-var`.

### `historical-expected-shortfall/k`

```lisp
(fx-quant-kit:historical-expected-shortfall/k &rest arguments)
  => value
```

Callback-last wrapper for `historical-expected-shortfall`.

### `parametric-var/k`

```lisp
(fx-quant-kit:parametric-var/k &rest arguments)
  => value
```

Callback-last wrapper for `parametric-var`.

### `parametric-expected-shortfall/k`

```lisp
(fx-quant-kit:parametric-expected-shortfall/k &rest arguments)
  => value
```

Callback-last wrapper for `parametric-expected-shortfall`.

### `kelly-fraction/k`

```lisp
(fx-quant-kit:kelly-fraction/k &rest arguments)
  => value
```

Callback-last wrapper for `kelly-fraction`.

### `volatility-target-position/k`

```lisp
(fx-quant-kit:volatility-target-position/k &rest arguments)
  => value
```

Callback-last wrapper for `volatility-target-position`.

### `drawdown-series/k`

```lisp
(fx-quant-kit:drawdown-series/k &rest arguments)
  => value
```

Callback-last wrapper for `drawdown-series`.

### `max-drawdown/k`

```lisp
(fx-quant-kit:max-drawdown/k &rest arguments)
  => value
```

Callback-last wrapper for `max-drawdown`.

### `portfolio-variance/k`

```lisp
(fx-quant-kit:portfolio-variance/k &rest arguments)
  => value
```

Callback-last wrapper for `portfolio-variance`.

### `portfolio-volatility/k`

```lisp
(fx-quant-kit:portfolio-volatility/k &rest arguments)
  => value
```

Callback-last wrapper for `portfolio-volatility`.

### `portfolio-risk-contributions/k`

```lisp
(fx-quant-kit:portfolio-risk-contributions/k &rest arguments)
  => value
```

Callback-last wrapper for `portfolio-risk-contributions`.

### `stress-loss/k`

```lisp
(fx-quant-kit:stress-loss/k &rest arguments)
  => value
```

Callback-last wrapper for `stress-loss`.

### `risk-decision/k`

```lisp
(fx-quant-kit:risk-decision/k &rest arguments)
  => value
```

Callback-last wrapper for `risk-decision`.

## Statistics and distributions

### `mean`

```lisp
(fx-quant-kit:mean values)
  => value
```

Returns the arithmetic mean of a non-empty numeric sequence.

### `weighted-mean`

```lisp
(fx-quant-kit:weighted-mean values weights)
  => value
```

Returns the weighted mean. Values and weights must have equal length, with
non-negative weights and a non-zero total weight.

### `variance`

```lisp
(fx-quant-kit:variance values &key (sample-p t))
  => value
```

Returns sample variance by default; pass `:sample-p nil` for population
variance.

### `standard-deviation`

```lisp
(fx-quant-kit:standard-deviation values &key (sample-p t))
  => value
```

Returns the square root of `variance` using the same sample or population
convention.

### `covariance`

```lisp
(fx-quant-kit:covariance left right &key (sample-p t))
  => value
```

Returns the covariance of two aligned sequences.

### `correlation`

```lisp
(fx-quant-kit:correlation left right)
  => value
```

Returns the Pearson correlation of two aligned sequences.

### `sum-of-squares`

```lisp
(fx-quant-kit:sum-of-squares values)
  => value
```

Returns the compensated sum of squared values.

### `simple-returns`

```lisp
(fx-quant-kit:simple-returns prices)
  => value
```

Returns adjacent simple returns, `P[i] / P[i-1] - 1`, for positive prices.

### `log-returns`

```lisp
(fx-quant-kit:log-returns prices)
  => value
```

Returns adjacent natural-log returns for positive prices.

### `cumulative-return`

```lisp
(fx-quant-kit:cumulative-return returns)
  => value
```

Compounds an ordered return sequence into one cumulative return.

### `quantile`

```lisp
(fx-quant-kit:quantile values probability)
  => value
```

Returns a linearly interpolated quantile for a probability in `[0, 1]`.

### `median`

```lisp
(fx-quant-kit:median values)
  => value
```

Returns `(quantile values 0.5)`.

### `normal-pdf`

```lisp
(fx-quant-kit:normal-pdf x &key (mean 0d0) (standard-deviation 1d0))
  => value
```

Evaluates a normal probability density with positive standard deviation.

### `normal-cdf`

```lisp
(fx-quant-kit:normal-cdf x &key (mean 0d0) (standard-deviation 1d0))
  => value
```

Evaluates a normal cumulative distribution function.

### `inverse-normal-cdf`

```lisp
(fx-quant-kit:inverse-normal-cdf probability &key (mean 0d0) (standard-deviation 1d0))
  => value
```

Returns the inverse normal quantile for a probability strictly between zero and
one.

### `skewness`

```lisp
(fx-quant-kit:skewness values &key (bias-corrected-p nil))
  => value
```

Returns the third standardized central moment. Bias correction is optional and
requires enough observations for the corrected estimator.

### `excess-kurtosis`

```lisp
(fx-quant-kit:excess-kurtosis values &key (bias-corrected-p nil))
  => value
```

Returns excess kurtosis, with optional finite-sample bias correction.

### `sharpe-ratio`

```lisp
(fx-quant-kit:sharpe-ratio returns &key (risk-free-rate 0d0) (periods-per-year 1d0))
  => value
```

Returns an annualized arithmetic Sharpe ratio using sample volatility.

### `sortino-ratio`

```lisp
(fx-quant-kit:sortino-ratio returns &key (target-return 0d0) (periods-per-year 1d0))
  => value
```

Returns an annualized Sortino ratio using downside population RMS relative to
the target return.

### `beta`

```lisp
(fx-quant-kit:beta returns benchmark &key (sample-p t))
  => value
```

Returns covariance with the benchmark divided by benchmark variance.

### `tracking-error`

```lisp
(fx-quant-kit:tracking-error returns benchmark &key (periods-per-year 1d0))
  => value
```

Returns annualized sample volatility of active returns.

### `information-ratio`

```lisp
(fx-quant-kit:information-ratio returns benchmark &key (periods-per-year 1d0))
  => value
```

Returns active-return mean divided by annualized tracking error.

### `covariance-matrix`

```lisp
(fx-quant-kit:covariance-matrix series &key (sample-p t))
  => value
```

Returns the symmetric covariance matrix for aligned series.

### `correlation-matrix`

```lisp
(fx-quant-kit:correlation-matrix series)
  => value
```

Returns the symmetric Pearson correlation matrix for aligned series.

## Market data values

### `market-quote`

```lisp
(fx-quant-kit:market-quote timestamp bid ask)
  => value
```

Immutable two-sided quote record. The timestamp is epoch microseconds, and
prices must be positive with bid no greater than ask.

### `market-quote-p`

```lisp
(fx-quant-kit:market-quote-p object)
  => value
```

Returns true when object is a market-quote record.

### `make-market-quote`

```lisp
(fx-quant-kit:make-market-quote timestamp bid ask)
  => value
```

Constructs a market quote after validating its timestamp and price ordering.

### `market-quote-timestamp`

```lisp
(fx-quant-kit:market-quote-timestamp quote)
  => value
```

Returns the quote timestamp in epoch microseconds.

### `market-quote-bid`

```lisp
(fx-quant-kit:market-quote-bid quote)
  => value
```

Returns the bid price.

### `market-quote-ask`

```lisp
(fx-quant-kit:market-quote-ask quote)
  => value
```

Returns the ask price.

### `market-quote-mid`

```lisp
(fx-quant-kit:market-quote-mid quote)
  => value
```

Returns the arithmetic midpoint of bid and ask.

### `market-quote-spread`

```lisp
(fx-quant-kit:market-quote-spread quote)
  => value
```

Returns ask minus bid.

### `tick-data`

```lisp
(fx-quant-kit:tick-data timestamp bid ask bid-size ask-size)
  => value
```

Immutable quote-plus-size record for one tick. Bid and ask sizes are
non-negative.

### `tick-data-p`

```lisp
(fx-quant-kit:tick-data-p object)
  => value
```

Returns true when object is a tick-data record.

### `make-tick-data`

```lisp
(fx-quant-kit:make-tick-data timestamp bid ask &key (bid-size 0d0) (ask-size 0d0))
  => value
```

Constructs tick data with optional bid and ask sizes.

### `tick-data-timestamp`

```lisp
(fx-quant-kit:tick-data-timestamp tick)
  => value
```

Returns the tick timestamp.

### `tick-data-bid`

```lisp
(fx-quant-kit:tick-data-bid tick)
  => value
```

Returns the tick bid price.

### `tick-data-ask`

```lisp
(fx-quant-kit:tick-data-ask tick)
  => value
```

Returns the tick ask price.

### `tick-data-bid-size`

```lisp
(fx-quant-kit:tick-data-bid-size tick)
  => value
```

Returns the bid-side size.

### `tick-data-ask-size`

```lisp
(fx-quant-kit:tick-data-ask-size tick)
  => value
```

Returns the ask-side size.

### `tick-data-mid`

```lisp
(fx-quant-kit:tick-data-mid tick)
  => value
```

Returns the tick midpoint.

### `tick-data-spread`

```lisp
(fx-quant-kit:tick-data-spread tick)
  => value
```

Returns the tick spread.

### `tick-data-total-size`

```lisp
(fx-quant-kit:tick-data-total-size tick)
  => value
```

Returns bid size plus ask size.

### `tick-data-imbalance`

```lisp
(fx-quant-kit:tick-data-imbalance tick)
  => value
```

Returns the size imbalance `(bid-size - ask-size) / total-size`;
an empty book has zero imbalance.

### `ohlcv-bar`

```lisp
(fx-quant-kit:ohlcv-bar timestamp open high low close volume)
  => value
```

Immutable OHLCV record with positive prices, non-negative volume, and
consistent high/low bounds.

### `ohlcv-bar-p`

```lisp
(fx-quant-kit:ohlcv-bar-p object)
  => value
```

Returns true when object is an OHLCV bar.

### `make-ohlcv-bar`

```lisp
(fx-quant-kit:make-ohlcv-bar timestamp open high low close volume)
  => value
```

Constructs and validates an OHLCV bar.

### `ohlcv-bar-timestamp`

```lisp
(fx-quant-kit:ohlcv-bar-timestamp bar)
  => value
```

Returns the bar timestamp.

### `ohlcv-bar-open`

```lisp
(fx-quant-kit:ohlcv-bar-open bar)
  => value
```

Returns the opening price.

### `ohlcv-bar-high`

```lisp
(fx-quant-kit:ohlcv-bar-high bar)
  => value
```

Returns the high price.

### `ohlcv-bar-low`

```lisp
(fx-quant-kit:ohlcv-bar-low bar)
  => value
```

Returns the low price.

### `ohlcv-bar-close`

```lisp
(fx-quant-kit:ohlcv-bar-close bar)
  => value
```

Returns the closing price.

### `ohlcv-bar-volume`

```lisp
(fx-quant-kit:ohlcv-bar-volume bar)
  => value
```

Returns the traded volume.

### `timestamp->instant`

```lisp
(fx-quant-kit:timestamp->instant timestamp)
  => value
```

Converts epoch-microsecond timestamps to a cl-date-kit instant.

### `instant->timestamp`

```lisp
(fx-quant-kit:instant->timestamp instant)
  => value
```

Converts a cl-date-kit instant to epoch microseconds.

### `timestamp->iso8601`

```lisp
(fx-quant-kit:timestamp->iso8601 timestamp)
  => value
```

Formats a timestamp as canonical UTC ISO 8601 text.

### `iso8601->timestamp`

```lisp
(fx-quant-kit:iso8601->timestamp text)
  => value
```

Parses canonical UTC ISO 8601 text into epoch microseconds.

## FX conventions

FX prices use quote-currency units per one unit of base currency. Currency
pairs also carry a pip size; the default is `0.0001`, or
`0.01` when the quote currency is JPY.

### `currency`

```lisp
(fx-quant-kit:currency code)
  => value
```

Immutable three-letter currency value.

### `currency-p`

```lisp
(fx-quant-kit:currency-p object)
  => value
```

Returns true when object is a currency value.

### `make-currency`

```lisp
(fx-quant-kit:make-currency code)
  => value
```

Constructs a normalized three-letter currency code.

### `currency-code`

```lisp
(fx-quant-kit:currency-code currency)
  => value
```

Returns the currency code string.

### `currency-pair`

```lisp
(fx-quant-kit:currency-pair base quote pip-size)
  => value
```

Immutable base/quote pair with its pip size.

### `currency-pair-p`

```lisp
(fx-quant-kit:currency-pair-p object)
  => value
```

Returns true when object is a currency-pair value.

### `make-currency-pair`

```lisp
(fx-quant-kit:make-currency-pair base quote &key pip-size)
  => value
```

Constructs a currency pair and rejects identical currencies or an invalid
pip size.

### `currency-pair-base`

```lisp
(fx-quant-kit:currency-pair-base pair)
  => value
```

Returns the base currency.

### `currency-pair-quote`

```lisp
(fx-quant-kit:currency-pair-quote pair)
  => value
```

Returns the quote currency.

### `currency-pair-pip-size`

```lisp
(fx-quant-kit:currency-pair-pip-size pair)
  => value
```

Returns the pair's price increment.

### `fx-forward-rate`

```lisp
(fx-quant-kit:fx-forward-rate pair spot base-rate quote-rate time-to-maturity)
  => value
```

Returns spot multiplied by
`exp((base-rate - quote-rate) * time-to-maturity)`.

### `fx-forward-points`

```lisp
(fx-quant-kit:fx-forward-points pair spot base-rate quote-rate time-to-maturity)
  => value
```

Returns the forward rate minus spot, expressed in price units.

### `fx-cross-rate`

```lisp
(fx-quant-kit:fx-cross-rate left-pair left-rate right-pair right-rate)
  => value
```

Combines two compatible quoted rates into a cross rate.

### `fx-pip-distance`

```lisp
(fx-quant-kit:fx-pip-distance pair from-price to-price)
  => value
```

Returns signed price movement measured in pips.

### `fx-pnl`

```lisp
(fx-quant-kit:fx-pnl pair base-notional entry-price exit-price &key (side :long) (quote-to-account-rate 1d0))
  => value
```

Returns account-currency P&L for a long or short base-currency position.

### `pip-value`

```lisp
(fx-quant-kit:pip-value pair notional &key (quote-to-account-rate 1d0))
  => value
```

Returns the account-currency value of one pip for a base notional.

### `market-quote->json`

```lisp
(fx-quant-kit:market-quote->json quote)
  => value
```

Serializes a market quote to JSON text without performing I/O.

### `json->market-quote`

```lisp
(fx-quant-kit:json->market-quote text)
  => value
```

Parses JSON text into a validated market quote.

### `tick-data->json`

```lisp
(fx-quant-kit:tick-data->json tick)
  => value
```

Serializes tick data to JSON text.

### `json->tick-data`

```lisp
(fx-quant-kit:json->tick-data text)
  => value
```

Parses JSON text into validated tick data.

### `ohlcv-bar->json`

```lisp
(fx-quant-kit:ohlcv-bar->json bar)
  => value
```

Serializes an OHLCV bar to JSON text.

### `json->ohlcv-bar`

```lisp
(fx-quant-kit:json->ohlcv-bar text)
  => value
```

Parses JSON text into a validated OHLCV bar.

### `currency->json`

```lisp
(fx-quant-kit:currency->json currency)
  => value
```

Serializes a currency value to JSON text.

### `json->currency`

```lisp
(fx-quant-kit:json->currency text)
  => value
```

Parses JSON text into a currency value.

### `currency-pair->json`

```lisp
(fx-quant-kit:currency-pair->json pair)
  => value
```

Serializes a currency pair to JSON text.

### `json->currency-pair`

```lisp
(fx-quant-kit:json->currency-pair text)
  => value
```

Parses JSON text into a currency pair.

## Indicators and volatility

Moving-window indicators return sequences with `NIL` warm-up values
where a full lookback window is not available.

### `sma`

```lisp
(fx-quant-kit:sma values period)
  => value
```

Returns a simple moving average sequence.

### `ema`

```lisp
(fx-quant-kit:ema values period)
  => value
```

Returns an exponentially weighted moving average sequence.

### `wilder-average`

```lisp
(fx-quant-kit:wilder-average values period)
  => value
```

Returns Wilder's smoothed moving average.

### `rsi`

```lisp
(fx-quant-kit:rsi prices period)
  => value
```

Returns the relative strength index for positive prices.

### `macd-result`

```lisp
(fx-quant-kit:macd-result line signal histogram)
  => value
```

Immutable result record containing the MACD line, signal line, and histogram.

### `macd-result-p`

```lisp
(fx-quant-kit:macd-result-p object)
  => value
```

Returns true when object is a MACD result.

### `make-macd-result`

```lisp
(fx-quant-kit:make-macd-result line signal histogram)
  => value
```

Constructs a MACD result record.

### `macd-result-line`

```lisp
(fx-quant-kit:macd-result-line result)
  => value
```

Returns the MACD line sequence.

### `macd-result-signal`

```lisp
(fx-quant-kit:macd-result-signal result)
  => value
```

Returns the signal line sequence.

### `macd-result-histogram`

```lisp
(fx-quant-kit:macd-result-histogram result)
  => value
```

Returns the MACD histogram sequence.

### `macd`

```lisp
(fx-quant-kit:macd values &key (fast-period 12) (slow-period 26) (signal-period 9))
  => value
```

Returns a `macd-result` using the conventional 12/26/9 periods by
default.

### `bollinger-result`

```lisp
(fx-quant-kit:bollinger-result middle upper lower)
  => value
```

Immutable result record containing Bollinger middle, upper, and lower bands.

### `bollinger-result-p`

```lisp
(fx-quant-kit:bollinger-result-p object)
  => value
```

Returns true when object is a Bollinger result.

### `make-bollinger-result`

```lisp
(fx-quant-kit:make-bollinger-result middle upper lower)
  => value
```

Constructs a Bollinger result record.

### `bollinger-result-middle`

```lisp
(fx-quant-kit:bollinger-result-middle result)
  => value
```

Returns the middle band sequence.

### `bollinger-result-upper`

```lisp
(fx-quant-kit:bollinger-result-upper result)
  => value
```

Returns the upper band sequence.

### `bollinger-result-lower`

```lisp
(fx-quant-kit:bollinger-result-lower result)
  => value
```

Returns the lower band sequence.

### `bollinger-bands`

```lisp
(fx-quant-kit:bollinger-bands values period &key (deviations 2d0))
  => value
```

Returns Bollinger bands built from a moving mean and standard deviation.

### `true-range`

```lisp
(fx-quant-kit:true-range bars)
  => value
```

Returns the true-range sequence for OHLCV bars.

### `atr`

```lisp
(fx-quant-kit:atr bars period)
  => value
```

Returns the average true range using Wilder smoothing.

### `hurst-exponent`

```lisp
(fx-quant-kit:hurst-exponent values)
  => value
```

Estimates the Hurst exponent of a numeric sequence.

### `garch11-variance`

```lisp
(fx-quant-kit:garch11-variance returns &key (omega 1d-6) (alpha 0.1d0) (beta 0.85d0) initial-variance)
  => value
```

Returns the final conditional variance from a GARCH(1,1) recurrence.

### `garch11-forecast`

```lisp
(fx-quant-kit:garch11-forecast returns steps &key (omega 1d-6) (alpha 0.1d0) (beta 0.85d0) initial-variance)
  => value
```

Returns conditional variance forecasts for the requested number of steps.

### `realized-volatility`

```lisp
(fx-quant-kit:realized-volatility returns &key (annualization-factor 252d0))
  => value
```

Returns annualized realized volatility from periodic returns.

## Option pricing and stochastic processes

### `black-scholes-price`

```lisp
(fx-quant-kit:black-scholes-price spot strike time-to-expiry volatility risk-free-rate &key (dividend-yield 0d0) (option-type :call))
  => value
```

Returns the Black--Scholes price of a European call or put.

### `option-contract`

```lisp
(fx-quant-kit:option-contract option-type strike time-to-expiry)
  => value
```

Immutable option contract record.

### `option-contract-p`

```lisp
(fx-quant-kit:option-contract-p object)
  => value
```

Returns true when object is an option contract.

### `make-option-contract`

```lisp
(fx-quant-kit:make-option-contract option-type strike time-to-expiry)
  => value
```

Constructs a call or put contract with positive strike and time to expiry.

### `option-contract-option-type`

```lisp
(fx-quant-kit:option-contract-option-type contract)
  => value
```

Returns `:call` or `:put`.

### `option-contract-strike`

```lisp
(fx-quant-kit:option-contract-strike contract)
  => value
```

Returns the contract strike.

### `option-contract-time-to-expiry`

```lisp
(fx-quant-kit:option-contract-time-to-expiry contract)
  => value
```

Returns the contract time to expiry.

### `option-contract-payoff`

```lisp
(fx-quant-kit:option-contract-payoff contract spot &key (quantity 1d0))
  => value
```

Returns expiry payoff for the contract at a given spot.

### `option-contract-price`

```lisp
(fx-quant-kit:option-contract-price contract spot volatility risk-free-rate &key (dividend-yield 0d0) (quantity 1d0))
  => value
```

Returns the discounted Black--Scholes price multiplied by quantity.

### `option-contract-greeks`

```lisp
(fx-quant-kit:option-contract-greeks contract spot volatility risk-free-rate &key (dividend-yield 0d0) (quantity 1d0))
  => value
```

Returns a scaled `black-scholes-greeks` record for the contract.

### `discount-factor`

```lisp
(fx-quant-kit:discount-factor rate time-to-maturity)
  => value
```

Returns the continuously compounded discount factor.

### `present-value`

```lisp
(fx-quant-kit:present-value cash-flow rate time-to-maturity)
  => value
```

Returns the present value of a future cash flow.

### `forward-price`

```lisp
(fx-quant-kit:forward-price spot carry-rate time-to-maturity)
  => value
```

Returns the continuously compounded forward price.

### `black-scholes-greeks`

```lisp
(fx-quant-kit:black-scholes-greeks spot strike time-to-expiry volatility risk-free-rate &key (dividend-yield 0d0) (option-type :call))
  => value
```

Returns price, delta, gamma, vega, theta, and rho for a European option.

### `black-scholes-greeks-p`

```lisp
(fx-quant-kit:black-scholes-greeks-p object)
  => value
```

Returns true when object is a Black--Scholes Greeks record.

### `make-black-scholes-greeks`

```lisp
(fx-quant-kit:make-black-scholes-greeks &key price delta gamma vega theta rho)
  => value
```

Constructs a Black--Scholes Greeks record.

### `greeks-price`

```lisp
(fx-quant-kit:greeks-price greeks)
  => value
```

Returns the option price from a Greeks record.

### `greeks-delta`

```lisp
(fx-quant-kit:greeks-delta greeks)
  => value
```

Returns delta from a Greeks record.

### `greeks-gamma`

```lisp
(fx-quant-kit:greeks-gamma greeks)
  => value
```

Returns gamma from a Greeks record.

### `greeks-vega`

```lisp
(fx-quant-kit:greeks-vega greeks)
  => value
```

Returns vega from a Greeks record.

### `greeks-theta`

```lisp
(fx-quant-kit:greeks-theta greeks)
  => value
```

Returns theta from a Greeks record.

### `greeks-rho`

```lisp
(fx-quant-kit:greeks-rho greeks)
  => value
```

Returns rho from a Greeks record.

### `implied-volatility`

```lisp
(fx-quant-kit:implied-volatility target-price spot strike time-to-expiry risk-free-rate &key (dividend-yield 0d0) (option-type :call) (lower-bound 1d-8) (upper-bound 8d0) (tolerance 1d-10) (max-iterations 200))
  => value
```

Solves for volatility whose Black--Scholes price matches target price.

### `simulation-rng`

```lisp
(fx-quant-kit:simulation-rng seed)
  => value
```

Mutable seeded pseudo-random generator record used by simulation functions.

### `simulation-rng-p`

```lisp
(fx-quant-kit:simulation-rng-p object)
  => value
```

Returns true when object is a simulation RNG.

### `make-simulation-rng`

```lisp
(fx-quant-kit:make-simulation-rng &optional (seed 1))
  => value
```

Constructs a deterministic simulation RNG.

### `simulation-rng-seed`

```lisp
(fx-quant-kit:simulation-rng-seed rng)
  => value
```

Returns the current mutable generator seed.

### `rng-uniform`

```lisp
(fx-quant-kit:rng-uniform rng)
  => value
```

Returns the next uniform variate from `rng`.

### `rng-normal`

```lisp
(fx-quant-kit:rng-normal rng)
  => value
```

Returns the next standard normal variate from `rng`.

### `simulate-geometric-brownian-motion`

```lisp
(fx-quant-kit:simulate-geometric-brownian-motion initial-value drift volatility time-step steps paths &key (rng (make-simulation-rng 1)))
  => value
```

Simulates geometric Brownian motion paths using the supplied or default RNG.

### `simulate-ornstein-uhlenbeck`

```lisp
(fx-quant-kit:simulate-ornstein-uhlenbeck initial-value mean-reversion-speed long-term-mean volatility time-step steps paths &key (rng (make-simulation-rng 1)))
  => value
```

Simulates Ornstein--Uhlenbeck mean-reverting paths.

### `monte-carlo-estimate`

```lisp
(fx-quant-kit:monte-carlo-estimate sampler sample-count &key (rng (make-simulation-rng 1)))
  => value
```

Runs a sampler and returns the estimate, standard error, and sample variance.

## Risk

Risk measures use loss-positive conventions where documented, and return
plain numeric values or immutable decision records.

### `historical-var`

```lisp
(fx-quant-kit:historical-var returns confidence &key (notional 1d0))
  => value
```

Returns historical value at risk at the requested confidence and notional.

### `historical-expected-shortfall`

```lisp
(fx-quant-kit:historical-expected-shortfall returns confidence &key (notional 1d0))
  => value
```

Returns the historical expected shortfall beyond the VaR threshold.

### `parametric-var`

```lisp
(fx-quant-kit:parametric-var mean-return volatility confidence &key (notional 1d0))
  => value
```

Returns normal-parametric value at risk.

### `parametric-expected-shortfall`

```lisp
(fx-quant-kit:parametric-expected-shortfall mean-return volatility confidence &key (notional 1d0))
  => value
```

Returns normal-parametric expected shortfall.

### `kelly-fraction`

```lisp
(fx-quant-kit:kelly-fraction win-probability win-loss-ratio)
  => value
```

Returns the Kelly betting fraction from win probability and win/loss ratio.

### `volatility-target-position`

```lisp
(fx-quant-kit:volatility-target-position target-volatility current-volatility &key (max-leverage 1d0))
  => value
```

Returns a position multiplier targeting the requested volatility and capped
by maximum leverage.

### `drawdown-series`

```lisp
(fx-quant-kit:drawdown-series wealth)
  => value
```

Returns drawdown from each running wealth peak.

### `max-drawdown`

```lisp
(fx-quant-kit:max-drawdown wealth)
  => value
```

Returns the maximum drawdown of a wealth sequence.

### `portfolio-variance`

```lisp
(fx-quant-kit:portfolio-variance weights covariance-matrix)
  => value
```

Returns portfolio variance from weights and a covariance matrix.

### `portfolio-volatility`

```lisp
(fx-quant-kit:portfolio-volatility weights covariance-matrix)
  => value
```

Returns the square root of portfolio variance.

### `portfolio-risk-contributions`

```lisp
(fx-quant-kit:portfolio-risk-contributions weights covariance-matrix)
  => value
```

Returns each asset's contribution to portfolio volatility.

### `stress-loss`

```lisp
(fx-quant-kit:stress-loss positions shocks)
  => value
```

Returns the loss produced by applying stress shocks to positions.

### `risk-decision-state`

```lisp
(fx-quant-kit:risk-decision-state blackout-p drawdown max-drawdown volatility max-volatility)
  => value
```

Immutable state consumed by `risk-decision`.

### `risk-decision-state-p`

```lisp
(fx-quant-kit:risk-decision-state-p object)
  => value
```

Returns true when object is a risk decision state.

### `make-risk-decision-state`

```lisp
(fx-quant-kit:make-risk-decision-state &key (blackout-p nil) (drawdown 0d0) (max-drawdown 1d0) (volatility 0d0) (max-volatility 1d0))
  => value
```

Constructs a risk decision state with permissive default thresholds.

### `risk-decision-state-blackout-p`

```lisp
(fx-quant-kit:risk-decision-state-blackout-p state)
  => value
```

Returns whether the state is in a blackout period.

### `risk-decision-state-drawdown`

```lisp
(fx-quant-kit:risk-decision-state-drawdown state)
  => value
```

Returns current drawdown.

### `risk-decision-state-max-drawdown`

```lisp
(fx-quant-kit:risk-decision-state-max-drawdown state)
  => value
```

Returns the maximum permitted drawdown.

### `risk-decision-state-volatility`

```lisp
(fx-quant-kit:risk-decision-state-volatility state)
  => value
```

Returns current volatility.

### `risk-decision-state-max-volatility`

```lisp
(fx-quant-kit:risk-decision-state-max-volatility state)
  => value
```

Returns the maximum permitted volatility.

### `risk-decision-result`

```lisp
(fx-quant-kit:risk-decision-result action reason state)
  => value
```

Immutable result record returned by `risk-decision`.

### `risk-decision-result-p`

```lisp
(fx-quant-kit:risk-decision-result-p object)
  => value
```

Returns true when object is a risk decision result.

### `make-risk-decision-result`

```lisp
(fx-quant-kit:make-risk-decision-result action reason state)
  => value
```

Constructs a risk decision result.

### `risk-decision-result-action`

```lisp
(fx-quant-kit:risk-decision-result-action result)
  => value
```

Returns the decision action.

### `risk-decision-result-reason`

```lisp
(fx-quant-kit:risk-decision-result-reason result)
  => value
```

Returns the decision reason.

### `risk-decision-result-state`

```lisp
(fx-quant-kit:risk-decision-result-state result)
  => value
```

Returns the state evaluated by the decision.

### `risk-decision`

```lisp
(fx-quant-kit:risk-decision state)
  => value
```

Evaluates blackout, drawdown, and volatility rules and returns a decision
result with the first applicable action and reason.
