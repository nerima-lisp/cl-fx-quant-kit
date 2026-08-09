# fx-quant-kit

`fx-quant-kit` is a pure Common Lisp library for quantitative finance and FX
calculations. It provides reusable numerical primitives without network,
filesystem, or global-state dependencies.

The library covers descriptive statistics, return and risk measures, market
data value objects, FX conventions, technical indicators, option pricing,
stochastic simulation, and rule-based risk decisions.

Start with [Getting Started](getting-started.md), then use the [core concepts
guide](guide/core-concepts.md) and the [API reference](reference/api.md) to
choose the right data model and calculation.

## Design goals

- Keep runtime calculations deterministic and side-effect free.
- Make numerical conventions explicit in function signatures and documentation.
- Validate domain errors at the library boundary.
- Reuse small pure packages in the `nerima-lisp` ecosystem where they are
  useful, without coupling the runtime to an application framework.

## Scope

The package is a calculation library, not a market-data client, trading
engine, persistence layer, or portfolio application. Callers provide data and
choose the operational policies around it.

The ASDF system currently reports version `0.5.1`. The public API is evolving;
pin a release when reproducibility matters.
