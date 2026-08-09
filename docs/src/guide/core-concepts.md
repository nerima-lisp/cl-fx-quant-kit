# Core Concepts

## Pure calculations

Runtime functions receive all of their inputs and return values without
network access, filesystem access, hidden clocks, or mutable global state.
This keeps a calculation reproducible and leaves data acquisition, storage,
and execution policy to the calling application.

## Numeric sequences

The statistical API accepts sequences of real numbers. Inputs are copied to
double-float vectors before calculation. Functions document whether they use
sample or population conventions; for example, `variance` defaults to sample
variance, while `standard-deviation` follows the same convention.

Returns are adjacent observations: `simple-returns` computes
`(P[i] / P[i-1]) - 1`, and `log-returns` computes the natural logarithm of that
ratio. Moving indicators return aligned vectors and use `NIL` during their
warm-up period.

## Value records

Market quotes, bars, currencies, option contracts, indicator results, and risk
states are value records. Constructors validate their invariants and copy
vector inputs where applicable. Accessors expose the fields without providing
mutation operations.

## FX conventions

A currency pair represents quote currency per unit of base currency. Thus an
`EUR/USD` quote of `1.10` means one euro costs 1.10 US dollars. Forward rates,
cross rates, pip distances, pip values, and P&L use that convention explicitly;
see [the API reference](../reference/api.md#fx-conventions).

## Time and serialization

Timestamps are non-negative integer microseconds since the Unix epoch. The
time helpers convert them to `cl-date-kit` instants or canonical UTC ISO 8601
text. JSON helpers serialize value records to text or parse JSON objects; they
do not read from or write to a stream.

## Randomness and simulation

Simulation functions accept an explicit `simulation-rng`. Supplying the same
seed and inputs reproduces the same path, while omitting the optional RNG
creates a fresh generator for that call. Monte Carlo samplers receive the RNG
so their source of randomness remains visible at the call site.

## Conditions

Invalid values are reported with typed conditions such as `invalid-argument`,
`invalid-shape`, `insufficient-data`, `numerical-error`, and `domain-error`.
Use [Conditions](../reference/conditions.md) to inspect the condition data and
validation helpers.
