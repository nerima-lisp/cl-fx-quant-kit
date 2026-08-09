# Conditions

All public validation errors descend from `quantitative-error`. Conditions
carry the offending values needed by a caller or debugger to explain the
failure without parsing a message string.

## Condition hierarchy

### `quantitative-error`

Base condition for errors raised by the quantitative calculations.

### `invalid-argument`

Signals when an argument violates a value constraint. `invalid-argument-name`
and `invalid-argument-value` expose the argument name and value.

### `invalid-shape`

Signals when vectors or matrices do not have a required shape.
`invalid-shape-expected` and `invalid-shape-actual` expose both shapes.

### `insufficient-data`

Signals when a calculation needs more observations than supplied.
`insufficient-data-required` and `insufficient-data-actual` expose the counts.

### `numerical-error`

Signals when an algorithm cannot produce a finite result.
`numerical-error-operation` names the calculation.

### `domain-error`

Signals when an input is outside a mathematical domain.
`domain-error-operation` and `domain-error-value` identify the operation and
value.

## Validation helpers

### `ensure-real`

```lisp
(ensure-real value name)
```

Returns `value` when it is real; otherwise signals `invalid-argument`.

### `ensure-finite`

```lisp
(ensure-finite value name)
```

Returns a finite double-float representation or signals `invalid-argument`.

### `ensure-positive`

```lisp
(ensure-positive value name)
```

Validates a strictly positive real value.

### `ensure-non-negative`

```lisp
(ensure-non-negative value name)
```

Validates a real value greater than or equal to zero.

### `ensure-probability`

```lisp
(ensure-probability value name)
```

Validates a value in the closed interval `[0, 1]`.

### `approx=`

```lisp
(approx= left right &key absolute-tolerance relative-tolerance)
```

Compares finite real values using the larger of the absolute tolerance and a
scale-aware relative tolerance. It returns a generalized boolean and validates
the tolerance arguments.
