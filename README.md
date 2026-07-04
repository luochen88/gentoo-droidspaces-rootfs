# Gentoo Droidspaces RootFS Builder

Build Gentoo Linux rootfs tarballs for [Droidspaces](https://github.com/Droidspaces) — running Linux containers on Android.

[中文](README_CN.md)

## Variants

| Variant | Description | Branch |
|---------|-------------|--------|
| **Minimal** | Basic systemd system with core utilities, SSH, networking | `main` |
| **Base** | Minimal + development tools (GCC, Clang, CMake, Python), Docker | `main` |
| **KDE** | KDE Plasma desktop + konsole + dolphin, X11, Chinese support | `kde` |
| **KDE Anland** | KDE Plasma + Anland Wayland protocol, GPU acceleration, Android-native rendering | `anland` |

## KDE Anland Variant (`anland` branch)

The most advanced variant: Gentoo KDE Plasma running on Anland V3 display protocol — renders desktop content directly into Android GPU buffers via Wayland. Native performance, no X11 forwarding overhead.

### Key Features

- **Anland V3 daemon**: GPU buffer sharing between KWin and Android surface
- **Wayland-native**: `startplasma-wayland` on `WAYLAND_DISPLAY=wayland-0`
- **GPU acceleration**: Mesa + kgsl driver + Turnip Vulkan for Adreno GPUs
- **Patched KWin/XWayland**: Via `droidspaces-overlay` (priority 50, blocks `::gentoo`)
- **Auto-start**: `anland-daemon.service` → `plasma-wayland.service`

### Build Options

| ARG | Default | Description |
|-----|---------|-------------|
| `ENABLE_zh` | `true` | Chinese locale + Noto CJK fonts + Fcitx5 IME |
| `ENABLE_dev` | `true` | Development tools (GCC, Clang, CMake, Python, pip) |
| `ENABLE_gpu` | `true` | Mesa/kgsl/Turnip GPU environment variables |
| `PulseAudio` | `socket` | Audio forwarding: `socket` / `tcp` / empty=disable |
| `USERNAME` | `luochen570` | Default user (password: `12345678`) |

### Packages

**Base system**: bash, curl, ca-certificates, git, nano, sudo, openssh, net-tools, iptables, iputils, iproute2, htop, procps, Xorg+XWayland, PipeWire, Wayland utils

**KDE Plasma**: plasma-desktop, konsole, dolphin, kate, ark, kinfocenter, powerdevil, kscreen, plasma-pa

**Anland**: anland-daemon (built from source), patched kwin/xwayland (via overlay)

### Android Launch

```bash
# Copy scripts to Termux
bash scripts/on_aaudio_socket.sh
```

### Building

```bash
./build_rootfs-native.sh -i Gentoo-KDE-Anland.Dockerfile -v dev
```

## Requirements

- Kernel 5.10 and above (for aarch64 Android kernels)
- Droidspaces container runtime
- For KDE/X11: Termux:X11
- For KDE Anland: Anland-compatible Android app

## GitHub Actions

Pushes to branches trigger automatic builds via `ubuntu-24.04-arm` runners. Weekly cron keeps artifacts up-to-date. Releases published automatically.

## Overlay

Patched KWin/XWayland ebuilds maintained in [droidspaces-overlay](https://github.com/luochen88/droidspaces-overlay) (priority 50).

## Credits

Based on [Droidspaces-rootfs-builder](https://github.com/Droidspaces/Droidspaces-rootfs-builder).
KDE solution and `on_aaudio` launch scripts adapted from [Droidspaces-rootfs-KDE-builder](https://github.com/Goldzxcbug/Droidspaces-rootfs-KDE-builder) — 感谢！
Anland protocol and patches by [superturtlee/anland](https://github.com/superturtlee/anland).
