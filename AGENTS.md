# Agent Guidance: cabang's NixOS Configuration

## How to Help Here

The owner is **learning Nix/NixOS**. Your job is to be a sounding board and an extra pair of eyes — not to refactor unsolicited, not to dump finished code, not to take over.

- Answer questions directly and concisely. Teach the *why* behind a suggestion, not just the *what*.
- Prefer to **explain trade-offs** (e.g. `mkDefault` vs `mkForce`, `imports = [ ./dir ]` vs explicit list) over silently picking one.
- Show small, focused diffs when asked to edit. Never rewrite large swaths unprompted.
- If you see something that looks wrong or smelly, **point it out and ask**, don't auto-fix.
- Don't add comments to code (see policy below). Don't add TODOs. If a TODO exists, mention it to the owner — they may want it gone.

If in doubt about scope, ask. The owner prefers fewer, well-considered changes over a flurry of "while I was in there" edits.

## Overview

Personal NixOS configuration managed as a **Nix flake**. Declaratively configures a single host (`cwbfw`) for user `cwb`.

## Architecture

```
.
├── flake.nix              # Entry point: inputs, outputs, nixosSystem + 5 top-level module imports
├── flake.lock             # Pinned input versions
├── system.nix             # System policy: kernel, boot, gc, locale, fonts, docker, keyring, qmk
├── tools.nix              # Personal user-facing apps (flameshot, spotify, gimp, nautilus, ...)
├── modules/
│   ├── default.nix        # Root: imports the four bundles below
│   ├── bundles/
│   │   ├── core.nix       # configuration, hardware-configuration, identity, sops, gpg, yubikey
│   │   ├── desktop.nix    # hyprland, firefox, ghostty, alacritty, tmux, audio, bluetooth, nushell, socials
│   │   ├── dev.nix        # coding/, editor/, git/, opencode, television, nix-alien
│   │   └── services.nix   # tailscale, postgres
│   ├── configuration.nix      # Base NixOS config (boot, networking, stateVersion, experimental-features)
│   ├── hardware-configuration.nix  # Auto-generated; do not edit by hand
│   ├── identity.nix           # User account (parametersied via `hostname`/`user` specialArgs)
│   ├── coding/default.nix     # Wraps the per-language modules (dotnet, go, rust, ...)
│   ├── editor/helix.nix       # Helix editor config (kept out of coding/ — an editor isn't a language)
│   ├── television/default.nix # Wraps config/theme + per-cable modules under cables/
│   ├── hyprland/              # Window manager module + waybar/wofi/config + assets/wallpaper.png (LFS-tracked)
│   ├── nushell/               # default.nix + config.nu (nushell rc)
│   └── *.nix                  # Single-purpose feature modules (firefox, audio, tailscale, ...)
└── taskfile.yml           # Common tasks (sync, format, iso, setup)
```

### Key conventions

- **flake.nix is small by design.** It imports five things: `sops-nix` module, an inline overlay/allowUnfree block, `home-manager` module, `./system.nix`, `./tools.nix`, and `./modules` (which resolves to `modules/default.nix`).
- **Grouping via bundles.** New modules go into the appropriate bundle in `modules/bundles/`, not into `flake.nix` directly.
- **Directory modules use `default.nix`** so `imports = [ ./foo ]` works (e.g. `./modules`, `./modules/coding`, `./modules/television`).
- **`system.nix` is policy-only.** Anything that would be identical across every host you ever own (timezone, fonts, docker-daemon-on, gc) lives here. Personal apps go in `tools.nix` or a feature module.
- **`tools.nix` is personal tooling.** Apps you would install on your machine but which don't need their own module (e.g. `gimp`, `nautilus`, `chromium`). If a tool needs config (settings, secrets, packages with non-trivial options), promote it to `modules/<feature>.nix`.
- **`modules/configuration.nix`** holds `system.stateVersion` and a few base settings (bootloader, networkmanager, experimental-features). **Never change `stateVersion`** unless you understand the migration implications.
- **Special args** (`hostname`, `user`, `email`, `fullName`, `nixOsVersion`, `inputs`) flow from `flake.nix` to every module via `specialArgs`. Use them — never hardcode `cwb` or `cwbfw` in modules.
- **Binary assets** (e.g. `modules/hyprland/assets/wallpaper.png`) are tracked via **git-lfs**. The `.gitattributes` pattern `modules/hyprland/assets/*.png` routes new wallpapers through LFS automatically. `git-lfs` is installed system-wide via `tools.nix`. Use `git lfs install --local` on fresh clones (the global git config is read-only on this machine, so `git lfs install` without `--local` will fail).

## Build & Deploy

| Action | Command |
|--------|---------|
| Build (no switch) | `nixos-rebuild build --flake .#cwbfw` |
| Switch the live system | `sudo nixos-rebuild switch --flake .#cwbfw` |
| Update lock file | `nix flake lock` or `nix flake update --all` |
| Format all Nix files | `nixfmt .` |
| Show flake outputs | `nix flake show` |
| Check flake | `nix flake check` |
| Build ISO | `task iso` (see `taskfile.yml`) |

> **Tip:** `task sync` formats and rebuilds the system in one go. The `flake` URI uses `.#cwbfw` (relative) so it works from any checkout or worktree.

## Code Style

- **Formatter:** `nixfmt` (modern name; the package `nixfmt-rfc-style` is deprecated — `nixfmt` in current nixpkgs *is* the RFC 166-style formatter). Enforced via `task format`.
- **Run `nixfmt .` before committing.**
- **NO COMMENTS.** The owner dislikes comments in Nix code — they see them as a code smell. A comment is a signal that the surrounding code is doing too much, naming too little, or mixing concerns. When tempted to write a comment, first try one of: splitting the block into a named helper/module, renaming a binding to make intent explicit, or extracting a sub-module. If after that the code is self-evident, the comment wasn't needed. If it's still not self-evident, the structure is wrong — not the documentation. The only accepted exceptions are: (a) shebangs when a file is also executable, (b) `#![...]`-style directives the language requires — neither of which applies to Nix.
- Keep modules focused. If a module grows past ~150 lines, split it (see `modules/television/` for the pattern: `default.nix` + one file per concern).
- Prefer `lib.mkOverride` / `lib.mkForce` over redefining options that another module already sets.

## Git & Commits

- **Always ask for explicit confirmation before creating any commit.** Never commit unprompted.
- **Always use [Conventional Commits](https://www.conventionalcommits.org/).**
- Allowed types:
  - `feat:` — new module, new package, new capability
  - `fix:` — bug fix in config
  - `chore:` — routine maintenance, lockfile updates, formatting, refactor
  - `docs:` — README, AGENTS.md, documentation
  - `remove:` — deleting modules, inputs, or packages
- Examples:
  - `feat: add tailscale module`
  - `fix: correct hyprland monitor layout`
  - `chore: update flake.lock`
  - `remove: drop qgt work-only modules`

## Adding a New Module

1. Pick the right home:
   - Personal app with no config → add the package to `tools.nix`.
   - System policy (timezone, fonts, services) → add to `system.nix` or a feature module.
   - Self-contained feature → `modules/<feature>.nix`.
2. If you create `modules/<feature>.nix`, import it from the appropriate bundle in `modules/bundles/<bundle>.nix` (not from `flake.nix`).
3. Keep it a plain `{ config, pkgs, lib, ... }:` module unless it needs `user`, `hostname`, etc. — then declare them in the module args.
4. Run `nixfmt .`.
5. Build (don't switch) to verify: `nixos-rebuild build --flake .#cwbfw`.

## Special Notes for Agents

- This repo controls a **live NixOS machine**. A bad config can break boot, networking, or the desktop. For anything beyond package additions, prefer `nixos-rebuild build --flake .#cwbfw` before `switch`.
- **Secrets** are managed via `sops-nix` (the module `sops-nix.nixosModules.sops` is imported in `flake.nix`; `modules/sops.nix` currently only installs the `sops` binary — no secrets are wired yet). Do not hardcode secrets.
- **Home-manager** is integrated as a NixOS module (`home-manager.nixosModules.home-manager`). User-level config goes through `home-manager.users.${user}` in the relevant module.
- The repo may use **git worktrees** for isolated feature work (e.g. `../os-<feature>`). Check `git worktree list` before assuming you're in the only checkout.
- **Flakes ignore untracked files.** If you add a new file (e.g. an asset like `wallpaper.png`), `git add` it before evaluating — otherwise the build silently won't see it.
