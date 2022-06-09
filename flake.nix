{
  description = "Dummy project imports haskell-backend";
  inputs = {
    haskell-nix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskell-nix/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, haskell-nix }:
    let
      perSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      nixpkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = [ haskell-nix.overlay ];
          inherit (haskell-nix) config;
        };
      nixpkgsFor' = system:
        import nixpkgs {
          inherit system;
          inherit (haskell-nix) config;
        };
    in {
      project = perSystem (system:
        let
          pkgs = nixpkgsFor system;
          pkgs' = nixpkgsFor' system;
        in pkgs.haskell-nix.stackProject' ({
          src = ./.;
          compiler-nix-name = "ghc8107";
        }));

      flake = perSystem (system: self.project.${system}.flake { });
      packages = perSystem (system: self.flake.${system}.packages);

      apps = perSystem (system: self.flake.${system}.apps);
      devShell = perSystem (system: self.flake.${system}.devShell);


    };
}
