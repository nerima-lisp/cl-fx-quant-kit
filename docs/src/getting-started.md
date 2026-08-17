# Getting Started

`fx-quant-kit` is distributed as an ASDF system. Load it in a Common Lisp
image, construct plain values, and call the calculation functions directly.

## Load the system

With the repository available to ASDF:

```lisp
(asdf:load-system :fx-quant-kit)
```

The runtime dependencies are `cl-date-kit`, `cl-json-kit`, and `cl-prolog-kit`.
They provide time values, JSON conversion, and the small rule engine used by
risk decisions; the library itself performs no network or file I/O.

## Calculate from explicit inputs

```lisp
(fx-quant-kit:mean #(0.01d0 0.02d0 -0.01d0))
(fx-quant-kit:make-currency-pair "EUR" "USD")
(fx-quant-kit:black-scholes-price 100d0 100d0 1d0 0.2d0 0.03d0)
```

Numeric sequences are copied to double-float vectors at the calculation
boundary. Value records are immutable, so a caller can safely retain and pass
them between calculations.

## Run the checks

From the repository root:

```console
sbcl --script run-tests.lisp
mkdocs build --strict --config-file docs/mkdocs.yml
```

See [Development](project/development.md) for Nix-based commands and the
project layout.
