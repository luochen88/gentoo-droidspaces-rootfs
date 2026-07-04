# Gentoo Droidspaces RootFS 构建器

为 [Droidspaces](https://github.com/Droidspaces) 构建 Gentoo Linux rootfs tarball，在 Android 上运行 Linux 容器。

[English](README.md)

## 版本

| 版本 | 说明 | 分支 |
|------|------|------|
| **Minimal** | 最小化 systemd 系统，含核心工具、SSH、网络 | `main` |
| **Base** | Minimal + 开发工具（GCC, Clang, CMake, Python）+ Docker | `main` |
| **KDE** | 完整 KDE Plasma 桌面环境，X11，中文支持 | `kde` |

## KDE 版本（`kde` 分支）

构建适用于 Droidspaces 的 Gentoo KDE Plasma 桌面环境。目前支持 **X11 模式**——通过 `startplasma-x11` 在 `DISPLAY=:5` 上启动 Plasma。

### 构建选项

| ARG | 默认值 | 说明 |
|-----|--------|------|
| `BUILD_KDE` | `min` | `min`=Plasma桌面+konsole+dolphin, `full`=完整KDE全家桶 |
| `ENABLE_zh` | `true` | 中文locale + 思源/Noto CJK 字体 + Fcitx5 输入法 |
| `ENABLE_dev` | `true` | 开发工具（GCC, Clang, CMake, Python, pip） |
| `PulseAudio` | `socket` | 音频转发：`socket` / `tcp` / 空=不启用 |
| `USERNAME` | `luochen570` | 默认普通用户名 |

### 包含的包

**基础系统**（始终安装）：bash, curl, ca-certificates, git, nano, sudo, openssh, net-tools, iptables, iputils, iproute2, htop, procps, Xorg server, PipeWire

**KDE min**：plasma-desktop, konsole, dolphin, kate, ark, kinfocenter, powerdevil, kscreen, plasma-pa

**KDE full**：plasma-meta, kde-apps-meta + gwenview, okular, spectacle, kcalc, kfind, filelight

### 本地构建

```bash
# KDE min（默认）
./build_rootfs-native.sh -i Gentoo-KDE.Dockerfile -v dev

# KDE full — 通过 Docker build-arg 设置
docker build --build-arg BUILD_KDE=full -f Gentoo-KDE.Dockerfile -o . .
```

## 自定义软件

编辑 `packages.conf`，每行一个包名，构建时自动安装：

```
# 取消注释即可添加
app-editors/neovim
net-im/telegram-desktop
```

## 环境要求

- 内核 5.10+（安卓 aarch64 内核）
- Droidspaces 容器运行时
- KDE 版本需要安卓端的 Termux:X11 或等效 X Server

## 本地构建（非 KDE）

```bash
# aarch64 原生构建
./build_rootfs-native.sh -i Gentoo-Minimal.Dockerfile -v dev

# Base 版本
./build_rootfs-native.sh -i Gentoo-base.Dockerfile -v dev
```

## CI/CD

推送 `main` 和 `kde` 分支或每周定时触发，通过 `ubuntu-24.04-arm` 原生运行器自动构建，产物发布为 GitHub Release。

## 致谢

基于 [Droidspaces-rootfs-builder](https://github.com/Droidspaces/Droidspaces-rootfs-builder)。
KDE 方案参考 [Droidspaces-rootfs-KDE-builder](https://github.com/Goldzxcbug/Droidspaces-rootfs-KDE-builder)。
