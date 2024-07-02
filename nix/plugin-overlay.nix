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
in {
  inherit
    luajit
    luajitPackages
    ;

  vimPlugins =
    prev.vimPlugins
    // {
      inherit nvim-plugin;
    };
}
