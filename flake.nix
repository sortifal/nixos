{
  description = "NixOS + home-manager configuration: Hyprland desktop, Catppuccin Macchiato";

  inputs = {
    # The stable release the system tracks. Bumping this (and `home-manager`
    # alongside it) is the one edit a release upgrade needs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Tracked in parallel so individual packages can be pulled ahead of the
    # stable release; see the `unstable` binding in hosts/nixos/default.nix.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # home-manager must evaluate against the same nixpkgs as the system,
      # or the two get subtly different package sets.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # Every host is one directory under ./hosts holding default.nix and its
      # own (git-ignored) hardware-configuration.nix. Adding a machine is a new directory
      # plus a line below - nothing else in the repo has to change.
      mkHost = { hostname, system ? "x86_64-linux" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          # Makes the flake inputs available to every module as `inputs`.
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/${hostname} ];
        };
    in
    {
      nixosConfigurations = {
        nixos = mkHost { hostname = "nixos"; };
      };

      # `nix develop` - tooling for the machine setup scripts (scripts/post_deploy).
      devShells.x86_64-linux.default =
        let pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in pkgs.mkShell {
          name = "nix-ansible";
          packages = with pkgs; [
            python312
            uv
            go-task
            jq
            tctl
            ansible
          ];
        };
    };
}
