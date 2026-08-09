# fx-quant-kit

`fx-quant-kit` is a dependency-light quantitative finance library for Common
Lisp.  It exposes one package, `FX-QUANT-KIT`, and is designed to be usable by
backtests, research notebooks, offline analysis, and trading applications.

The calculation boundary is deliberately narrow: inputs enter as validated
values, pure functions calculate a result, and no function opens a database,
contacts a network, reads the current time, or persists state.

See [Development](development.md) for installation and the complete
non-goal list.

## Versioning

The ASDF system version is the release version. Releases use matching
annotated Git tags with a `v` prefix, such as `v0.5.1`.
