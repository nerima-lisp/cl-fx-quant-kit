# Architecture

## Public boundary

The public surface is the single `FX-QUANT-KIT` package.  Internally, source
files are ordered by ASDF so that lower-level validation and numeric kernels
are available before market types, indicators, pricing, simulation, and
risk.

```text
conditions -> macros -> core -> statistics -> analytics
                                      -> market-data -> time -> fx -> serialization
                                      -> indicators
                                      -> pricing
                                      -> simulation
                                      -> risk
```

The arrows describe source dependencies, not mutable runtime services.
The source remains flat, while the file split keeps market values, numerical
kernels, pricing, simulation, and risk contracts independently readable.
`cps` is loaded after the public functions and generates the continuation
wrappers from the same definitions; it is not a second implementation layer.

## Dependency policy

`cl-date-kit` is used only for conversion between the documented Unix epoch
microsecond representation and date-kit instants.  `cl-json-kit` is used only
at the explicit JSON boundary.  `cl-prolog` is used only by the declarative
rule boundary.  `cl-weave` and `paredit-cli` are development dependencies;
`paredit-cli` is never loaded by the library.  `cl-nix-forge` and
`treefmt-nix` provide the reproducible package, documentation, formatting, and
check graph rather than runtime behavior.  Packages such as `cl-dataflow` and
`cl-boundary-kit` are intentionally absent: this library has no graph-runtime,
network, clock-service, filesystem, or adapter symbol to justify them.  There
is no runtime dependency on PostgreSQL, broker APIs, network clients, process
execution, or application packages.

## Numerical policy

Public numeric inputs are copied into double-float vectors where appropriate,
then checked for shape, finiteness, positivity, or probability bounds.  The
standard normal CDF uses a deterministic quadrature kernel rather than a
platform-dependent external service.  Simulations take an explicit seeded RNG
object; no global random stream is modified.

## Domain policy

FX pairs use the convention “quote currency per base currency”.  Prices and
rates are represented as real numbers and their units are stated in function
docstrings.  The package intentionally leaves calendars, curve construction,
settlement, execution, and persistence to higher-level libraries.
