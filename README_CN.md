# Gentoo Droidspaces RootFS 构建器

为 [Droidspaces](https://github.com/Droidspaces) 构建 Gentoo Linux rootfs tarball，在 Android 上运行 Linux 容器。

[English](README.md)

## 版本

| 版本 | 说明 | 分支 |
|------|------|------|
| **Minimal** | 最小化 systemd 系统，含核心工具、SSH、网络 | `main` |
| **Base** | Minimal + 开发工具（GCC, Clang, CMake, Python）+ Docker | `main` |
| **KDE** | KDE Plasma 桌面 + konsole + dolphin，X11，中文支持 | `kde` |
| **KDE Anland** | KDE Plasma + Anland Wayland 协议，GPU 加速，安卓原生渲染 | `anland` |

## KDE Anland 版本（`anland` 分支）

最激进的版本：Gentoo KDE Plasma 运行在 Anland V3 显示协议上 — 桌面内容直接渲染到 Android GPU buffer，通过 Wayland 零拷贝传输。原生性能，无 X11 转发开销。

### 核心特性

- **Anland V3 守护进程**：桥接 KWin 合成器与 Android Surface 的 GPU buffer 共享
- **Wayland 原生**：`startplasma-wayland`，`WAYLAND_DISPLAY=wayland-0`
- **GPU 加速**：Mesa + kgsl 驱动 + Turnip Vulkan（Adreno GPU）
- **补丁版 KWin/XWayland**：通过 `droidspaces-overlay` 管理（priority 50，屏蔽 `::gentoo` 原版）
- **自启动**：`anland-daemon.service` → `plasma-wayland.service`

### 构建选项

| ARG | 默认值 | 说明 |
|-----|--------|------|
| `ENABLE_zh` | `true` | 中文locale + Noto CJK 字体 + Fcitx5 输入法 |
| `ENABLE_dev` | `true` | 开发工具（GCC, Clang, CMake, Python, pip） |
| `ENABLE_gpu` | `true` | Mesa/kgsl/Turnip GPU 环境变量 |
| `PulseAudio` | `socket` | 音频转发：`socket` / `tcp` / 空=不启用 |
| `USERNAME` | `luochen570` | 普通用户名（密码：`12345678`） |

### 包含的包

**基础系统**：bash, curl, ca-certificates, git, nano, sudo, openssh, net-tools, iptables, iputils, iproute2, htop, procps, Xorg+XWayland, PipeWire, Wayland 工具

**KDE Plasma**：plasma-desktop, konsole, dolphin, kate, ark, kinfocenter, powerdevil, kscreen, plasma-pa

**Anland**：anland-daemon（源码编译），补丁版 kwin/xwayland（通过 overlay）

### 安卓端启动

```bash
# 把脚本复制到 Termux
bash scripts/on_aaudio_socket.sh
```

### 本地构建

```bash
./build_rootfs-native.sh -i Gentoo-KDE-Anland.Dockerfile -v dev
```

## 环境要求

- 内核 5.10+（安卓 aarch64 内核）
- Droidspaces 容器运行时
- KDE X11 版本：Termux:X11
- KDE Anland 版本：支持 Anland 的安卓端 App

## GitHub Actions

推送分支触发自动构建（`ubuntu-24.04-arm`），每周定时更新，产物发布为 GitHub Release。

## Overlay

补丁版 KWin/XWayland ebuild 维护在 [droidspaces-overlay](https://github.com/luochen88/droidspaces-overlay)（priority 50）。

## 致谢

基于 [Droidspaces-rootfs-builder](https://github.com/Droidspaces/Droidspaces-rootfs-builder)。
KDE 方案及 `on_aaudio` 启动脚本参考 [Droidspaces-rootfs-KDE-builder](https://github.com/Goldzxcbug/Droidspaces-rootfs-KDE-builder) — 感谢！
Anland 协议及补丁来自 [superturtlee/anland](https://github.com/superturtlee/anland)。
