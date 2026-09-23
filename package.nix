{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  wrapGAppsHook4,
  gtkmm4,
  libadwaita,
  libsoup_3,
  nlohmann_json,
  rclone,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mtsync";
  version = "0.9.13";

  src = fetchFromGitHub {
    owner = "gavindi";
    repo = "MtSync";
    rev = finalAttrs.version;
    # Placeholder — the first `nix build` will fail and print the real
    # hash to paste in here. See README for the exact workflow.
    hash = "sha256-CvKa5q5ODJx0w+jH80QgF0f7j/UIB6HJI3Eb6ywP53g=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtkmm4
    libadwaita
    libsoup_3
    nlohmann_json
  ];

  # rclone is a runtime dependency (Mt. Sync shells out to it), not a
  # library, so it goes on PATH via the GApps wrapper, not buildInputs.
  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ rclone ]})
  '';

  meta = {
    description = "GTK4/libadwaita frontend to rclone";
    homepage = "https://github.com/gavindi/MtSync";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    mainProgram = "mtsync";
  };
})
