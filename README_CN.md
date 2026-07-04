# Gentoo Droidspaces RootFS 构建器

为 [Droidspaces](https://github.com/Droidspaces) 构建 Gentoo Linux rootfs tarball，在 Android 上运行 Linux 容器。

[English](README.md)

## 版本

| 版本 | 说明 |
|------|------|
| **Minimal** | 最小化 systemd 系统，含核心工具、SSH、网络 |
| **Base** | Minimal + 开发工具（GCC, Clang, CMake, Python）+ Docker |

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

## 本地构建

```bash
# aarch64 原生构建
./build_rootfs-native.sh -i Gentoo-Minimal.Dockerfile -v dev

# Base 版本
./build_rootfs-native.sh -i Gentoo-base.Dockerfile -v dev
```

## CI/CD

推送 `main` 分支或每周定时触发，通过 `ubuntu-24.04-arm` 原生运行器自动构建，产物发布为 GitHub Release。

## 致谢

基于 [Droidspaces-rootfs-builder](https://github.com/Droidspaces/Droidspaces-rootfs-builder)。
