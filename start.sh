#!/bin/bash

# 启用错误检查
set -e

# 如果传入了参数，直接执行命令
if [ $# -gt 0 ]; then
    exec "$@"
fi

# 检查必要的目录和权限
echo "检查目录和权限..."
for dir in "/media" "/cache" "/config" "/root/.config/rclone"; do
    if [ ! -d "$dir" ]; then
        echo "创建目录: $dir"
        mkdir -p "$dir"
    fi
done

# 检查并复制 rclone 配置
RCLONE_CONF="/root/.config/rclone/rclone.conf"
if [ ! -f "$RCLONE_CONF" ]; then
    echo "错误: rclone 配置文件不存在: $RCLONE_CONF"
    ls -la /root/.config/rclone/
    exit 1
fi

echo "rclone 配置文件内容:"
cat "$RCLONE_CONF"

# 确保 FUSE 设备可用
if [ ! -e "/dev/fuse" ]; then
    echo "错误: FUSE 设备不可用"
    exit 1
fi

# 检查 rclone 是否可执行
if ! command -v rclone &> /dev/null; then
    echo "错误: rclone 命令不可用"
    exit 1
fi

echo "启动 rclone 挂载..."
rclone mount webdav:/ /media \
    --daemon \
    --allow-other \
    --vfs-cache-mode full \
    --cache-dir=/cache/rclone \
    --log-file=/config/rclone.log \
    --log-level INFO \
    --vfs-read-chunk-size 10M \
    --vfs-read-chunk-size-limit 100M \
    --buffer-size 32M \
    --config "$RCLONE_CONF"

# 等待 rclone 挂载完成
echo "等待 rclone 挂载就绪..."
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    if mountpoint -q /media; then
        echo "Rclone 挂载成功"
        break
    fi
    echo "等待挂载... ($attempt/$max_attempts)"
    sleep 1
    attempt=$((attempt + 1))
done

if ! mountpoint -q /media; then
    echo "Rclone 挂载失败，查看日志:"
    cat /config/rclone.log
    exit 1
fi

# 启动 Jellyfin
echo "启动 Jellyfin..."
exec /jellyfin/jellyfin \
    --datadir /config \
    --cachedir /cache \
    --ffmpeg /usr/lib/jellyfin-ffmpeg/ffmpeg