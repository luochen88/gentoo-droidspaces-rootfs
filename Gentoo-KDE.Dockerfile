# Dockerfile (Gentoo Linux KDE Plasma — systemd, X11)
# Stage 1: Build and customize the rootfs for Droidspaces with KDE
ARG TARGETPLATFORM
FROM gentoo/stage3:systemd AS customizer

# Build options
ARG BUILD_KDE=min
ARG PulseAudio=socket
ARG ENABLE_zh=true
ARG ENABLE_dev=true
ARG USERNAME=luochen570

# Update Portage, configure for source build
RUN emerge --sync && \
    emerge --oneshot sys-apps/portage && \
    echo 'FEATURES="${FEATURES} -ipc-sandbox -network-sandbox -pid-sandbox noman noinfo nodoc"' >> /etc/portage/make.conf && \
    echo 'EMERGE_DEFAULT_OPTS="--jobs=$(nproc) --load-average=$(nproc) --quiet-build=y"' >> /etc/portage/make.conf

# Accept KDE licenses and set USE flags
RUN echo 'kde-plasma/* QPL-2.0 GPL-2 GPL-3 LGPL-2.1 LGPL-3' >> /etc/portage/package.license && \
    echo 'x11-libs/* QPL-2.0 GPL-2 GPL-3 LGPL-2.1 LGPL-3' >> /etc/portage/package.license && \
    echo 'kde-apps/* QPL-2.0 GPL-2 GPL-3 LGPL-2.1 LGPL-3' >> /etc/portage/package.license && \
    echo 'kde-frameworks/* QPL-2.0 GPL-2 GPL-3 LGPL-2.1 LGPL-3' >> /etc/portage/package.license && \
    # KDE needs X, wayland, opengl
    echo 'media-libs/mesa X wayland' >> /etc/portage/package.use/mesa && \
    echo 'x11-base/xorg-server xorg' >> /etc/portage/package.use/xorg && \
    echo 'media-video/pipewire sound-server' >> /etc/portage/package.use/pipewire

# Install base system packages (shell, network, tools)
RUN --mount=type=cache,target=/var/cache/distfiles,sharing=locked \
    emerge \
    app-shells/bash \
    net-misc/curl \
    app-misc/ca-certificates \
    dev-vcs/git \
    app-editors/nano \
    app-admin/sudo \
    net-misc/openssh \
    sys-apps/net-tools \
    net-firewall/iptables \
    net-misc/iputils \
    sys-apps/iproute2 \
    sys-process/htop \
    sys-process/procps \
    app-shells/bash-completion \
    # X11 + fonts
    x11-base/xorg-server \
    x11-apps/xrandr \
    x11-apps/xset \
    x11-apps/xrdb \
    media-fonts/noto \
    media-fonts/noto-cjk \
    media-fonts/noto-emoji \
    # Audio (PipeWire)
    media-video/pipewire \
    media-video/wireplumber \
    media-libs/libpulse \
    # Clean up distfiles
    && rm -rf /var/cache/distfiles/*

# Install KDE desktop
RUN --mount=type=cache,target=/var/cache/distfiles,sharing=locked \
    if [ "$BUILD_KDE" = "min" ] || [ "$BUILD_KDE" = "full" ]; then \
        emerge \
        kde-plasma/plasma-desktop \
        kde-apps/konsole \
        kde-apps/dolphin \
        kde-plasma/powerdevil \
        kde-plasma/kscreen \
        kde-plasma/plasma-pa \
        kde-apps/ark \
        kde-apps/kate \
        kde-plasma/kinfocenter \
        sys-power/upower \
        app-arch/xz \
        app-arch/gzip \
        app-arch/tar \
        app-arch/unzip \
        app-arch/zip \
        && rm -rf /var/cache/distfiles/*; \
    fi

# Install full KDE suite
RUN --mount=type=cache,target=/var/cache/distfiles,sharing=locked \
    if [ "$BUILD_KDE" = "full" ]; then \
        emerge \
        kde-plasma/plasma-meta \
        kde-apps/kde-apps-meta \
        kde-apps/gwenview \
        kde-apps/okular \
        kde-apps/spectacle \
        kde-apps/kcalc \
        kde-apps/kfind \
        kde-apps/filelight \
        kde-plasma/plasma-browser-integration \
        dev-util/vulkan-tools \
        && rm -rf /var/cache/distfiles/*; \
    fi

# Install Chinese locale and input method
RUN --mount=type=cache,target=/var/cache/distfiles,sharing=locked \
    if [ "$ENABLE_zh" = "true" ]; then \
        emerge \
        app-i18n/fcitx5 \
        app-i18n/fcitx5-chinese-addons \
        app-i18n/fcitx5-configtool \
        && rm -rf /var/cache/distfiles/*; \
    fi

# Install dev tools
RUN --mount=type=cache,target=/var/cache/distfiles,sharing=locked \
    if [ "$ENABLE_dev" = "true" ]; then \
        emerge \
        sys-devel/gcc \
        dev-build/cmake \
        llvm-core/clang \
        llvm-core/llvm \
        dev-lang/python \
        dev-python/pip \
        dev-debug/strace \
        && rm -rf /var/cache/distfiles/*; \
    fi

# Copy our bashrc script to the rootfs
COPY scripts/bashrc.sh /etc/profile.d/ds-aliases.sh
RUN chmod +x /etc/profile.d/ds-aliases.sh

# Configure legacy iptables (MANDATORY for Android compatibility)
RUN ln -sf /sbin/iptables-legacy /sbin/iptables && \
    ln -sf /sbin/ip6tables-legacy /sbin/ip6tables && \
    ln -sf /sbin/arptables-legacy /sbin/arptables && \
    ln -sf /sbin/ebtables-legacy /sbin/ebtables || true

# Configure locales
RUN if [ "$ENABLE_zh" = "true" ]; then \
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
        echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
        locale-gen && \
        eselect locale set zh_CN.UTF-8; \
    else \
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
        locale-gen && \
        eselect locale set en_US.UTF-8; \
    fi && \
    # Configure SSH
    mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create normal user
RUN useradd -m -s /bin/bash ${USERNAME} && \
    echo "${USERNAME}:1234" | chpasswd && \
    usermod -aG wheel,audio,video,input ${USERNAME} && \
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Environment variables
RUN cat <<'EOF' > /etc/profile.d/custom_env.sh
export XCURSOR_SIZE=48
export DISPLAY=:5
EOF

# PulseAudio config
RUN if [ "$PulseAudio" = "socket" ]; then \
        echo "export PULSE_SERVER=unix:/tmp/.pulse-socket" >> /etc/profile.d/custom_env.sh; \
    elif [ "$PulseAudio" = "tcp" ]; then \
        echo "export PULSE_SERVER=tcp:127.0.0.1:4713" >> /etc/profile.d/custom_env.sh; \
    fi && \
    chmod +x /etc/profile.d/custom_env.sh

# Fcitx5 autostart
RUN if [ "$ENABLE_zh" = "true" ]; then \
        mkdir -p /home/${USERNAME}/.config/autostart && \
        cat <<'EOD' > /home/${USERNAME}/.config/autostart/fcitx5.desktop
[Desktop Entry]
Name=Fcitx5
GenericName=Input Method
Comment=Start Input Method
Exec=fcitx5 -d
Icon=fcitx
Terminal=false
Type=Application
Categories=System;Utility;
StartupNotify=false
NoDisplay=true
EOD
        cat <<'EOD' >> /etc/profile.d/custom_env.sh
export XMODIFIERS=@im=fcitx5
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export SDL_IM_MODULE=fcitx5
export GLFW_IM_MODULE=fcitx
EOD
    fi

# Fix DHCP in the container
RUN mkdir -p /etc/systemd/network && \
    cat <<'EOF' > /etc/systemd/network/10-eth-dhcp.network
[Match]
Name=eth*

[Network]
DHCP=yes
IPv6AcceptRA=yes

[DHCPv4]
UseDNS=yes
UseDomains=yes
RouteMetric=100
EOF

# Apply Android compatibility fixes (Systemd and Udev)
RUN <<EOF_RUN
# --- 1. General Fixes ---
grep -q '^aid_inet:' /etc/group    || echo 'aid_inet:x:3003:'    >> /etc/group
grep -q '^aid_net_raw:' /etc/group || echo 'aid_net_raw:x:3004:' >> /etc/group
grep -q '^aid_net_admin:' /etc/group || echo 'aid_net_admin:x:3005:' >> /etc/group
usermod -a -G aid_inet,aid_net_raw,input,video,tty root || true

# --- 2. Systemd-Specific Fixes ---
ln -sf /dev/null /etc/systemd/system/systemd-networkd-wait-online.service
ln -sf /dev/null /etc/systemd/system/systemd-journald-audit.socket

cat >> /etc/systemd/journald.conf << 'EOT'
[Journal]
ReadKMsg=no
Audit=no
Storage=volatile
EOT

mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/ds-logging.conf << 'EOT'
[Journal]
SystemMaxUse=200M
RuntimeMaxUse=200M
MaxRetentionSec=7day
MaxLevelStore=info
EOT

# Enable essential services
mkdir -p /etc/systemd/system/multi-user.target.wants
GUEST_SYSTEMD_PATH="/usr/lib/systemd/system"
for service in dbus.service systemd-udevd.service systemd-resolved.service systemd-networkd.service NetworkManager.service; do
    if [ -f "$GUEST_SYSTEMD_PATH/$service" ]; then
        ln -sf "$GUEST_SYSTEMD_PATH/$service" "/etc/systemd/system/multi-user.target.wants/$service"
    fi
done

# Disable power button handling
mkdir -p /etc/systemd/logind.conf.d
cat > /etc/systemd/logind.conf.d/99-power-key.conf << 'EOF'
[Login]
HandlePowerKey=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandlePowerKeyLongPress=ignore
HandlePowerKeyLongPressHibernate=ignore
EOF

# Apply udev overrides
mkdir -p /etc/systemd/system/systemd-udev-trigger.service.d
cat > /etc/systemd/system/systemd-udev-trigger.service.d/override.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/usr/bin/udevadm trigger --subsystem-match=usb --subsystem-match=block --subsystem-match=input --subsystem-match=tty --subsystem-match=net
EOF

for unit in systemd-udevd.service systemd-udev-trigger.service systemd-udev-settle.service systemd-udevd-kernel.socket systemd-udevd-control.socket; do
    mkdir -p "/etc/systemd/system/${unit}.d"
    printf "[Unit]\nConditionPathIsReadWrite=\n" > "/etc/systemd/system/${unit}.d/99-readonly-fix.conf"
done

# Limit network services
for unit in NetworkManager.service dhcpcd.service systemd-resolved.service systemd-networkd.service; do
    if [ -f "$GUEST_SYSTEMD_PATH/$unit" ] || [ -f "/etc/systemd/system/multi-user.target.wants/$unit" ]; then
        mkdir -p "/etc/systemd/system/${unit}.d"
        cat > "/etc/systemd/system/${unit}.d/99-netmode-limit.conf" << 'EOF'
[Service]
ExecCondition=
ExecCondition=/bin/sh -c "grep -qE 'net_mode=(nat|gateway)' /run/droidspaces/container.config"
EOF
    fi
done

# Mark fixes as completed
echo "Post-extraction fixes applied on $(date)" > /etc/droidspaces
EOF_RUN

# KWin customization: disable compositing for better performance on Android
RUN if [ "$BUILD_KDE" = "min" ] || [ "$BUILD_KDE" = "full" ]; then \
        mkdir -p /home/${USERNAME}/.config && \
        cat <<'EOF' > /home/${USERNAME}/.config/kwinrc
[Compositing]
Enabled=false
EOF
    fi

# Create plasma-x11 systemd service (autostart KDE on boot)
RUN if [ "$BUILD_KDE" = "min" ] || [ "$BUILD_KDE" = "full" ]; then \
    cat <<EOF > /etc/systemd/system/plasma-x11.service
[Unit]
Description=Start Plasma X11
After=network.target dbus.service

[Service]
Type=simple
User=${USERNAME}
EnvironmentFile=-/etc/environment
ExecStart=/bin/bash -lc 'DISPLAY=:5 startplasma-x11'
Restart=no
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
    mkdir -p /etc/systemd/system/multi-user.target.wants && \
    ln -sf /etc/systemd/system/plasma-x11.service /etc/systemd/system/multi-user.target.wants/plasma-x11.service; \
    fi

# Set ownership of home directory
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Final cleanup — remove distfiles and portage tree to save space
RUN rm -rf /var/cache/distfiles/* /var/db/repos/gentoo /usr/portage

# Stage 2: Export to scratch for extraction
FROM scratch AS export

# Copy the entire filesystem from the customizer stage
COPY --from=customizer / /
