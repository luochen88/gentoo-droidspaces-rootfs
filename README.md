# Gentoo Droidspaces RootFS Builder

Build Gentoo Linux rootfs tarballs for [Droidspaces](https://github.com/Droidspaces) — running Linux containers on Android.

[中文](README_CN.md)

## Variants

| Variant | Description |
|---------|-------------|
| **Minimal** | Basic systemd system with core utilities, SSH, networking |
| **Base** | Minimal + development tools (GCC, Clang, CMake, Python), Docker |

## Requirements

- Kernel 5.10 and above (for aarch64 Android kernels)
- Droidspaces container runtime

## Building Locally

```bash
# Native build (on aarch64 host)
./build_rootfs-native.sh -i Gentoo-Minimal-Kernel-5.10-and-up.Dockerfile -v dev

# Or the Base variant
./build_rootfs-native.sh -i Gentoo-base-Kernel-5.10-and-up.Dockerfile -v dev
```

## GitHub Actions

Pushes to `main` and weekly cron jobs trigger automatic builds via `ubuntu-24.04-arm` runners. Artifacts are published as GitHub Releases.

## Credits

Based on [Droidspaces-rootfs-builder](https://github.com/Droidspaces/Droidspaces-rootfs-builder).
