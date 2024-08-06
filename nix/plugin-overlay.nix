{
  name,
  self,
  inputs,
}: final: prev: let
  rocks-nvim = inputs.rocks-nvim-flake.packages.${final.system}.rocks-nvim;
  luaPackageOverrides = luaself: luaprev: {
    rocks-edit-nvim = luaself.callPackage ({
      buildLuarocksPackage,
      nvim-nio,
    }:
      buildLuarocksPackage {
        pname = name;
        version = "scm-1";
        propagatedBuildInputs = [
          rocks-nvim
          nvim-nio
        ];
        knownRockspec = "${self}/${name}-scm-1.rockspec";
        src = self;
      }) {};
  };

  luajit = prev.luajit.override {
    packageOverrides = luaPackageOverrides;
  };
  luajitPackages = prev.luajitPackages // final.luajit.pkgs;

  # TODO: Rename
  nvim-plugin = final.neovimUtils.buildNeovimPlugin {
    pname = name;
    src = self;
    version = "dev";
  };

  neovim-with-rocks = let
    rocks = inputs.rocks-nvim-flake.packages.${final.system}.rocks-nvim;
    rocks-edit = final.luajitPackages.rocks-edit-nvim;
    neovimConfig = final.neovimUtils.makeNeovimConfig {
      withPython3 = true;
      viAlias = false;
      vimAlias = false;
      # plugins = [ final.vimPlugins.rocks-nvim ];
      extraLuaPackages = _: [rocks];
    };
  in
    final.wrapNeovimUnstable final.neovim-nightly (neovimConfig
      // {
        luaRcContent =
          /*
          lua
          */
          ''
            -- Copied from installer.lua
            local rocks_config = {
                rocks_path = vim.fn.stdpath("data") .. "/rocks",
                luarocks_binary = "${final.luajitPackages.luarocks}/bin/luarocks",
            }

            vim.g.rocks_nvim = rocks_config

            local luarocks_path = {
                vim.fs.joinpath("${rocks}", "share", "lua", "5.1", "?.lua"),
                vim.fs.joinpath("${rocks}", "share", "lua", "5.1", "?", "init.lua"),
                vim.fs.joinpath("${rocks-edit}", "share", "lua", "5.1", "?.lua"),
                vim.fs.joinpath("${rocks-edit}", "share", "lua", "5.1", "?", "init.lua"),
                vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
                vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?", "init.lua"),
            }
            package.path = package.path .. ";" .. table.concat(luarocks_path, ";")

            local luarocks_cpath = {
                vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.so"),
                vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.so"),
            }
            package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")

            vim.opt.runtimepath:append(vim.fs.joinpath("${rocks}", "rocks.nvim-scm-1-rocks", "rocks.nvim", "*"))
            vim.opt.runtimepath:append(vim.fs.joinpath("${rocks-edit}", "rocks-edit.nvim-scm-1-rocks", "rocks-edit.nvim", "*"))
          '';
        wrapRc = true;
        wrapperArgs =
          final.lib.escapeShellArgs neovimConfig.wrapperArgs
          + " "
          + ''--set NVIM_APPNAME "nvimrocks"'';
      });
in {
  inherit
    luajit
    luajitPackages
    neovim-with-rocks
    ;

  vimPlugins =
    prev.vimPlugins
    // {
      inherit nvim-plugin;
    };
}
