#!/bin/sh

### ===== 用户可修改参数 =====
WEBDAV_DIR="/mnt/data_sda1"
WEBDAV_PORT="8081"
WEBDAV_USER="root"
WEBDAV_PASS="root"
GOWEBDAV_URL="https://github.com/1715173329/gowebdav/releases/download/v0.0.6/gowebdav-linux-aarch64"
BIN_PATH="/usr/bin/gowebdav"
INIT_PATH="/etc/init.d/gowebdav"
### ==========================

echo "==> Gowebdav OpenWrt 一键安装脚本"
echo "==> 检测系统架构..."

ARCH="$(uname -m)"
if [ "$ARCH" != "aarch64" ]; then
    echo "❌ 当前架构: $ARCH"
    echo "❌ 仅支持 aarch64 (ARM64)，安装终止"
    exit 1
fi

echo "✅ 架构正确: aarch64"

echo "==> 下载 gowebdav..."
wget -O /tmp/gowebdav "$GOWEBDAV_URL" || {
    echo "❌ 下载失败"
    exit 1
}

chmod +x /tmp/gowebdav

echo "==> 安装到 $BIN_PATH"
mv /tmp/gowebdav "$BIN_PATH"

echo "==> 创建 WebDAV 目录: $WEBDAV_DIR"
mkdir -p "$WEBDAV_DIR"

echo "==> 创建 procd 启动脚本"

cat << EOF > "$INIT_PATH"
#!/bin/sh /etc/rc.common

START=99
STOP=10
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command $BIN_PATH \\
        -dir $WEBDAV_DIR \\
        -http :$WEBDAV_PORT \\
        -user $WEBDAV_USER \\
        -password $WEBDAV_PASS
    procd_set_param respawn
    procd_close_instance
}
EOF

chmod +x "$INIT_PATH"

echo "==> 设置开机自启"
/etc/init.d/gowebdav enable

echo "==> 启动 gowebdav 服务"
/etc/init.d/gowebdav start

echo
echo "🎉 安装完成！"
echo "======================================"
echo "WebDAV 地址: http://路由器IP:$WEBDAV_PORT"
echo "用户名: $WEBDAV_USER"
echo "密码: $WEBDAV_PASS"
echo "共享目录: $WEBDAV_DIR"
echo "======================================"
