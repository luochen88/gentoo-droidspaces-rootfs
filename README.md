# Gentoo Droidspaces RootFS Builder

Build Gentoo Linux rootfs tarballs for [Droidspaces](https://github.com/Droidspaces) — running Linux containers on Android.

[中文](README_CN.md)

## Variants

| Variant | Description | Branch |
|---------|-------------|--------|
| **Minimal** | Basic systemd system with core utilities, SSH, networking | `main` |
| **Base** | Minimal + development tools (GCC, Clang, CMake, Python), Docker | `main` |
| **KDE** | KDE Plasma desktop with konsole + dolphin, X11, Chinese support | `kde` |

## KDE Variant (`kde` branch)

Builds a Gentoo KDE Plasma desktop environment for Droidspaces. Starts Plasma via `startplasma-x11` on `DISPLAY=:5`.

### Build Options

| ARG | Default | Description |
|-----|---------|-------------|
| `ENABLE_zh` | `true` | Chinese locale + Noto CJK fonts + Fcitx5 IME |
| `ENABLE_dev` | `true` | Development tools (GCC, Clang, CMake, Python, pip) |
| `PulseAudio` | `socket` | Audio forwarding: `socket` / `tcp` / empty=disable |
| `USERNAME` | `luochen570` | Default user (password: `12345678`) |

### Packages

**Base system**: bash, curl, ca-certificates, git, nano, sudo, openssh, net-tools, iptables, iputils, iproute2, htop, procps, Xorg server, PipeWire

**KDE Plasma**: plasma-desktop, konsole, dolphin, kate, ark, kinfocenter, powerdevil, kscreen, plasma-pa

**Optional**: fcitx5 + Chinese addons (ENABLE_zh=true), GCC/Clang/CMake/Python (ENABLE_dev=true)

### Building

```bash
./build_rootfs-native.sh -i Gentoo-KDE.Dockerfile -v dev
```

## Requirements

- Kernel 5.10 and above (for aarch64 Android kernels)
- Droidspaces container runtime
- For KDE: Termux:X11 or equivalent X server on Android

## Building Locally (Non-KDE)

```bash
# Native build (on aarch64 host)
./build_rootfs-native.sh -i Gentoo-Minimal.Dockerfile -v dev

# Or the Base variant
./build_rootfs-native.sh -i Gentoo-base.Dockerfile -v dev
```

## Custom Packages

Edit `packages.conf` to add extra packages (one per line):

```
# Uncomment to add
app-editors/neovim
net-im/telegram-desktop
```

## GitHub Actions

Pushes to `main` and `kde` branches trigger automatic builds via `ubuntu-24.04-arm` runners. Weekly cron builds keep artifacts up-to-date. Releases are published automatically.

## Credits

Based on [Droidspaces-rootfs-builder](https://github.com/Droidspaces/Droidspaces-rootfs-builder).
KDE integration inspired by [Droidspaces-rootfs-KDE-builder](https://github.com/Goldzxcbug/Droidspaces-rootfs-KDE-builder).
