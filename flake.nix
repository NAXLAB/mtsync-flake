{
  description = "MtSync - GTK4/libadwaita frontend to rclone (packaged from gavindi/MtSync)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Upstream source, tracked as a flake input so you never have to
    # vendor or manually sync gavindi's repo. Bump with:
    #   nix flake lock --update-input mtsync-src
    mtsync-src = {
      url = "github:gavindi/MtSync/0.9.13"; # pin to a tag; drop the ref to track master
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, mtsync-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "mtsync";
          version = "0.9.13";

          src = mtsync-src;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
            wrapGAppsHook4
          ];

          buildInputs = with pkgs; [
            gtkmm4
            libadwaita
            libsoup_3
            nlohmann_json
          ];

          # rclone is a runtime dependency (Mt. Sync shells out to it), not a
          # library, so put it on PATH via the GApps wrapper instead of buildInputs.
          preFixup = ''
            gappsWrapperArgs+=(--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.rclone ]})
          '';

          meta = with pkgs.lib; {
            description = "GTK4/libadwaita frontend to rclone";
            homepage = "https://github.com/gavindi/MtSync";
            license = licenses.gpl2Only;
            platforms = platforms.linux;
            mainProgram = "mtsync";
          };
        };

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
          exe = "mtsync";
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.default ];
        };
      }
    );
}
