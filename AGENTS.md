# Agent Guidance: cabang's NixOS Configuration

## Overview

This is a personal NixOS system configuration managed as a **Nix flake**.
It declaratively configures a single NixOS host (`cwbfw`) for user `cwb`.

## Architecture

```
.
├── flake.nix              # Entry point: inputs, outputs, module imports
├── flake.lock             # Pinned input versions
├── main.nix               # Shared system-level settings (timezone, fonts, packages, docker, etc.)
├── modules/
│   ├── configuration.nix  # Base NixOS config (boot, networking, stateVersion)
│   ├── hardware-configuration.nix  # Auto-generated hardware config
│   ├── identity.nix       # User account definition
│   ├── coding/            # Dev tools & language support
│   └── *.nix              # Feature modules (hyprland, audio, firefox, etc.)
└── taskfile.yml           # Common tasks (sync, format, iso)
```

### Key conventions

- **Modules** are plain NixOS modules. Each should be self-contained and imported in `flake.nix`.
- **`main.nix`** holds cross-cutting system config. Prefer adding feature-specific config to a dedicated module under `modules/`.
- **`modules/configuration.nix`** contains `system.stateVersion`. **Never change this** unless you fully understand the migration implications.
- Flake inputs (e.g. `home-manager`, `sops-nix`, `nix-alien`) are pinned and follow the repo's `nixpkgs` via `inputs.<input>.inputs.nixpkgs.follows = "nixpkgs"`.

## Build & Deploy

| Action | Command |
|--------|---------|
| Build / switch system | `sudo nixos-rebuild switch --flake /home/cwb/Documents/os#cwbfw` |
| Update lock file | `nix flake lock` or `nix flake update` |
| Format all Nix files | `nixfmt .` (RFC style) |
| Show flake outputs | `nix flake show` |
| Check flake | `nix flake check` |
| Build ISO | `task iso` (see `taskfile.yml`) |

> **Tip:** `task sync` formats and rebuilds the system in one go.

## Code Style

- **Formatter:** `nixfmt-rfc-style` (enforced via `task format`).
- **Run `nixfmt .` before committing any Nix changes.**
- Keep modules focused. If a module grows large, split it (e.g. `modules/coding/*.nix`).

## Git & Commits

- **Always ask for explicit user confirmation before creating any commit.** Never commit unprompted.
- **Always use [Conventional Commits](https://www.conventionalcommits.org/).**
- Allowed types in this repo:
  - `feat:` — new module, new package, new capability
  - `fix:` — bug fix in config
  - `chore:` — routine maintenance, updates, formatting, refactor
  - `docs:` — README, comments, documentation
  - `remove:` — deleting modules, inputs, or packages
- Examples:
  - `feat: add tailscale module`
  - `fix: correct hyprland monitor layout`
  - `chore: update flake.lock`
  - `remove: drop nixvim in favor of helix`

## Adding a New Module

1. Create `modules/<feature>.nix`.
2. Import it in the `modules = [ ... ]` list in `flake.nix`.
3. Keep it a plain `{ config, pkgs, lib, ... }:` module unless it needs special args.
4. Run `nixfmt .`.
5. Rebuild to verify: `sudo nixos-rebuild switch --flake .#cwbfw`.

## Special Notes for Agents

- This repo controls a **live NixOS machine**. A bad config can break boot, networking, or the desktop. When making risky changes, prefer building first (`nixos-rebuild build --flake .#cwbfw`) before `switch`.
- Secrets are managed via `sops-nix` (`modules/sops.nix`). Do not hardcode secrets.
- Home-manager is integrated as a NixOS module (`home-manager.nixosModules.home-manager`). User-level config goes through `home-manager.users.${user}` in relevant modules.
- The repo may use **git worktrees** for isolated feature work (e.g. `../os-<feature>`). Check `git worktree list` before assuming you're in the only checkout.
