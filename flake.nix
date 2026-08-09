{
  description = "Pure quantitative finance and FX primitives for Common Lisp";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    cl-nix-forge = {
      url = "github:nerima-lisp/cl-nix-forge/v0.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cl-date-kit = {
      url = "github:nerima-lisp/cl-date-kit/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cl-json-kit = {
      url = "github:nerima-lisp/cl-json-kit/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cl-prolog = {
      url = "github:nerima-lisp/cl-prolog/v1.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cl-weave = {
      url = "github:nerima-lisp/cl-weave/v1.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    paredit-cli = {
      url = "github:nerima-lisp/paredit-cli/v1.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      cl-nix-forge,
      cl-date-kit,
      cl-json-kit,
      cl-prolog,
      cl-weave,
      paredit-cli,
      treefmt-nix,
    }:
    let
      systems = [
        "x86_64-linux"
      ];
    in
    cl-nix-forge.lib.${builtins.head systems}.mkPackageFlake {
      inherit self systems nixpkgs;

      pname = "fx-quant-kit";
      asd = ./fx-quant-kit.asd;
      root = ./.;

      meta = {
        description = "Pure quantitative finance and FX primitives for Common Lisp";
        homepage = "https://github.com/nerima-lisp/cl-fx-quant-kit";
        license = nixpkgs.lib.licenses.mit;
        platforms = [ "x86_64-linux" ];
      };

      lispDependencies = ctx: [
        cl-date-kit.packages.${ctx.system}.cl-date-kit
        cl-json-kit.packages.${ctx.system}.cl-json-kit
        cl-prolog.packages.${ctx.system}.cl-prolog
      ];

      lispCheckDependencies = ctx: [
        cl-weave.packages.${ctx.system}.cl-weave
      ];

      docs.root = ./docs;
      treefmt.evalModule = treefmt-nix.lib.evalModule;

      devShellPackages =
        ctx:
        [
          self.formatter.${ctx.system}
          ctx.pkgs.python3Packages.mkdocs-material
          cl-weave.packages.${ctx.system}.default
        ]
        ++
          ctx.pkgs.lib.optional (builtins.hasAttr ctx.system paredit-cli.packages)
            paredit-cli.packages.${ctx.system}.default;

      extraOutputs = ctx: {
        packages.coverage = ctx.cl.mkCoverageReport {
          drv = ctx.package.enableCheck;
          name = "fx-quant-kit-coverage";
          systems = [ "fx-quant-kit" ];
          timeoutSeconds = 600;
          killAfterSeconds = 30;
        };

        checks = ctx.pkgs.lib.optionalAttrs (builtins.hasAttr ctx.system paredit-cli.lib) {
          paredit-lint = paredit-cli.lib.${ctx.system}.mkLintCheck {
            inherit (ctx) src;
            name = "fx-quant-kit-paredit-lint";
          };
        };
      };
    };
}
