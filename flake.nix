{
  description = "MtSync - GTK4/libadwaita frontend to rclone (tracks gavindi/MtSync latest commit)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Source is pulled as a flake input, so flake.lock pins the exact commit.
    # Bump to the newest commit with:  nix flake update mtsync
    mtsync = {
      url = "github:NAXLAB/MtSync/unreadable-directory-fix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, mtsync }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;

        mtsyncPkg = pkgs.stdenv.mkDerivation {
          pname = "mtsync";
          version = "unstable-${builtins.substring 0 8 mtsync.lastModifiedDate}-${mtsync.shortRev or "dirty"}";

          src = mtsync;

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
          # library, so it goes on PATH via the GApps wrapper, not buildInputs.
          preFixup = ''
            gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ pkgs.rclone ]})
          '';

          meta = {
            description = "GTK4/libadwaita frontend to rclone";
            homepage = "https://github.com/gavindi/MtSync";
            license = lib.licenses.gpl2Only;
            platforms = lib.platforms.linux;
            mainProgram = "mtsync";
          };
        };
      in
      {
        packages.default = mtsyncPkg;

        apps.default = flake-utils.lib.mkApp {
          drv = mtsyncPkg;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ mtsyncPkg ];
        };
      }
    );
}