# Development

The repository follows the nerima-lisp library layout: one ASDF file, a flat
`src/` directory, a flat `t/` directory, and a root `run-tests.lisp`.

The test system is `fx-quant-kit/test`.  It uses `cl-weave` with the spec
reporter and refuses an empty selector.  The suite is deterministic: no test
opens a network connection or database, and simulation tests construct an
explicit RNG with a fixed seed.  `cl-weave`'s property, journal, mutation, and
coverage APIs are used directly rather than hidden behind a project-local
runner abstraction.

Install or otherwise register `cl-date-kit`, `cl-json-kit`, `cl-prolog`, and
`cl-weave` in the caller's ASDF source registry before running the root script.
The script registers this checkout and inherits that registry; it does not
discover or modify sibling checkouts implicitly.  `nix develop` supplies the
same dependency closure, plus `paredit-cli`, the documentation toolchain,
`cl-nix-forge`, and `treefmt-nix`.  The flake currently evaluates the
documented Linux system and the CI gate runs on Ubuntu.  `cl-dataflow` and
`cl-boundary-kit` are not included because no source reference requires their
runtime abstractions; adding them would widen a pure numerical library's
boundary without providing behavior.

For an instrumented report, run `nix build .#coverage`.  The Nix build uses
the check-enabled derivation and `cl-nix-forge`'s SBCL `sb-cover` runner to
force-load the target system under coverage instrumentation.  The test runner
also forwards `cl-weave` coverage thresholds for direct test invocations.

Before changing a numerical definition, add a reference-value test and an
invalid-input test.  Keep the public package single and do not move execution
or persistence concerns into this repository.

## Release

Use the `:version` value in `fx-quant-kit.asd` as the release version.  Before
creating a release tag, run the canonical test command, `nix flake check
--print-build-logs`, and `git diff --check`.  Create an annotated tag whose
name matches the ASDF version with a `v` prefix, for example:

```sh
git tag -a v0.5.0 -m "Release v0.5.0"
```
