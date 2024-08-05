{
  description = "rocks-dev.nvim flake";

  nixConfig = {
    extra-substituters = "https://neorocks.cachix.org";
    extra-trusted-public-keys = "neorocks.cachix.org-1:WqMESxmVTOJX7qoBC54TwrMMoVI1xAM+7yFin8NRfwk=";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
    };

    neorocks.url = "github:nvim-neorocks/neorocks";

    rocks-nvim.url = "github:nvim-neorocks/rocks.nvim";

    gen-luarc = {
      url = "github:mrcjkb/nix-gen-luarc-json";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cats-doc.url = "github:mrcjkb/cats-doc";

    rocks-nvim-flake = {
      url = "github:nvim-neorocks/rocks.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    git-hooks,
    neorocks,
    rocks-nvim,
    gen-luarc,
    ...
  }: let
    name = "rocks-edit.nvim";

    plugin-overlay = import ./nix/plugin-overlay.nix {
      inherit name self inputs;
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        system,
        ...
      }: let
        ci-overlay = import ./nix/ci-overlay.nix {
          inherit
            self
            inputs
            ;
          plugin-name = name;
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            ci-overlay
            neorocks.overlays.default
            gen-luarc.overlays.default
            rocks-nvim.overlays.default
            plugin-overlay
          ];
        };

        mk-luarc = nvim:
          pkgs.mk-luarc {
            inherit nvim;
            plugins = with pkgs.luajitPackages; [
              rocks-nvim
              nvim-nio
            ];
          };

        luarc-nightly = mk-luarc pkgs.neovim-nightly;
        luarc-stable = mk-luarc pkgs.neovim-unwrapped;

        mk-type-check = luarc:
          git-hooks.lib.${system}.run {
            src = self;
            hooks = {
              lua-ls = {
                enable = true;
                settings.configuration = luarc;
              };
            };
          };

        type-check-nightly = mk-type-check luarc-nightly;
        type-check-stable = mk-type-check luarc-stable;

        pre-commit-check = git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            alejandra.enable = true;
            stylua.enable = true;
            luacheck.enable = true;
            editorconfig-checker.enable = true;
            markdownlint.enable = true;
            docgen = {
              enable = true;
              name = "docgen";
              entry = "${pkgs.docgen}/bin/docgen";
              files = "\\.(lua)$";
              pass_filenames = false;
            };
          };
        };

        devShell = pkgs.nvim-nightly-tests.overrideAttrs (oa: {
          name = "rocks-edit.nvim devShell";
          shellHook = ''
            ${pre-commit-check.shellHook}
            ln -fs ${pkgs.luarc-to-json luarc-nightly} .luarc.json
          '';
          buildInputs =
            self.checks.${system}.pre-commit-check.enabledPackages
            ++ (with pkgs; [
              lua-language-server
              docgen
            ])
            ++ oa.buildInputs
            ++ oa.propagatedBuildInputs;
          doCheck = false;
        });
      in {
        devShells = {
          default = devShell;
          inherit devShell;
        };

        packages = rec {
          default = rocks-edit-nvim;
          inherit (pkgs.luajitPackages) rocks-edit-nvim;
          inherit (pkgs) docgen;
        };

        checks = {
          inherit
            pre-commit-check
            type-check-stable
            type-check-nightly
            ;
          inherit
            (pkgs)
            nvim-stable-tests
            nvim-nightly-tests
            ;
        };
      };
      flake = {
        overlays.default = plugin-overlay;
      };
    };
}
