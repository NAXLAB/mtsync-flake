# mtsync-flake

A [Nix flake](https://nixos.wiki/wiki/Flakes) packaging [MtSync](https://github.com/gavindi/MtSync) — a GTK4/libadwaita frontend for `rclone` — for use on NixOS or with Home Manager.

This repo doesn't vendor or fork MtSync's source. `package.nix` fetches it directly from gavindi's GitHub repo at build time, pinned to a specific tag.

## Usage

### Try it without installing

```bash
nix run github:NAXLAB/mtsync-flake
```

### Add it to your system flake

```nix
inputs.mtsync.url = "github:NAXLAB/mtsync-flake";
```

Then reference the package in your configuration:

```nix
# NixOS (configuration.nix / a module)
environment.systemPackages = [ inputs.mtsync.packages.${pkgs.system}.default ];

# Home Manager
home.packages = [ inputs.mtsync.packages.${pkgs.system}.default ];
```

Rebuild your system (`nixos-rebuild switch` / `home-manager switch`) and `mtsync` will be on your `$PATH`.

### Build/develop locally

```bash
nix build          # builds ./result
nix develop        # drops into a shell with build deps available
```

## Updating to a new MtSync release

1. Bump `version` in `package.nix` to the new tag.
2. Reset `hash` to `lib.fakeHash`.
3. Run `nix build`, copy the real hash it reports, paste it into `hash`.
4. Commit and push.

## Updating nixpkgs / flake-utils

```bash
nix flake update
```

## Structure

| File | Purpose |
|---|---|
| `flake.nix` | Thin wrapper — wires up `nixpkgs` + `flake-utils`, calls `package.nix` |
| `package.nix` | The actual derivation (standard `callPackage` format) |

## License

The packaging code in this repo (`flake.nix`, `package.nix`) is MIT licensed — see [LICENSE](./LICENSE).

MtSync itself is licensed GPL-2.0, per [upstream](https://github.com/gavindi/MtSync).
