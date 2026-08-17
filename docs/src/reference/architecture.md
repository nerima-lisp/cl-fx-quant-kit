# Architecture

## Runtime boundary

The public package is `FX-QUANT-KIT`. Its runtime is a flat ASDF system under
`src/`; callers provide data, numerical parameters, and optional random-number
generators. There are no runtime services, threads, network clients,
filesystem adapters, or global configuration objects.

## Source organization

The source files are organized by calculation family:

- `core.lisp`, `validation.lisp`, `macros.lisp`, and `cps*.lisp` provide common
  numerical helpers, validation, value-record definitions, and callback-last
  wrappers.
- `statistics.lisp`, `analytics-*.lisp`, and `time.lisp` provide descriptive
  statistics, return analytics, matrices, and timestamp conversion.
- `market-data.lisp`, `fx.lisp`, and `serialization.lisp` provide market and
  FX value objects, conventions, and JSON conversion.
- `indicators-*.lisp` provide moving, oscillator, regime, and volatility
  indicators.
- `pricing-*.lisp` provide option contracts, Black--Scholes calculations,
  Greeks, implied volatility, and present-value helpers.
- `simulation*.lisp` provide seeded random generators, stochastic paths, and
  Monte Carlo estimation.
- `risk*.lisp` and `rules*.lisp` provide risk metrics, immutable decision
  values, and rule-based decisions.

The test system is kept in `t/` and is loaded through the root test runner.

## Dependency policy

The runtime depends on small pure packages: `cl-date-kit` for time values,
`cl-json-kit` for JSON objects and text, and `cl-prolog-kit` for risk-decision
rules. `cl-weave` is a test and coverage dependency. Application concerns such
as transport, persistence, exchange connectivity, and order execution remain
outside this system.

## Numerical policy

Inputs are validated at public boundaries. Sequences are copied to
double-float vectors, matrix dimensions are checked before multiplication, and
domain constraints are represented by typed conditions. Algorithms state their
conventions in their API entries, including annualization factors, sample or
population estimators, option-rate conventions, and indicator warm-up values.

## Extension boundary

New calculations should preserve explicit inputs, typed validation, and the
value-oriented records used by neighboring modules. A feature that requires
I/O, global lifecycle management, or an application policy belongs in a
separate system rather than in the runtime package.
