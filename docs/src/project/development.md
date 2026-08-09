# Development

## Repository layout

The ASDF system is `fx-quant-kit.asd`. Runtime source is in `src/`, tests are
in `t/`, the root scripts run the test and coverage checks, and the MkDocs
source is in `docs/src/`.

The documentation follows the repository-wide structure: root pages contain
orientation, while `guide/`, `reference/`, and `project/` contain the detailed
material. Keep API entries aligned with the exports in `src/package.lisp`.

## Test and coverage commands

The canonical local test command is:

```console
sbcl --script run-tests.lisp
```

The Nix checks exercise the declared development environment and include the
test system. Coverage can be generated with:

```console
nix build .#coverage
```

The resulting report is a build artifact and should not be committed.

## Documentation checks

Build the site with the same strict configuration used by the project:

```console
mkdocs build --strict --config-file docs/mkdocs.yml
```

Strict mode catches broken internal links, missing navigation entries, and
configuration warnings. When `mkdocs` is unavailable in the shell, enter the
flake development shell or use the declared Nix package set.

## Source changes

Keep calculations pure and make domain conventions visible in the function
signature or API page. Add tests for numerical behavior, boundary validation,
and any new value-record invariant. Run the narrowest relevant test first,
then the complete test command and strict documentation build before handing
off a change.
