FROM rclone/rclone:latest AS rclone

FROM jellyfin/jellyfin:latest

# 从 rclone 镜像复制二进制文件
COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone

# 安装必要的包
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fuse3 \
    ca-certificates \
    curl \
    fonts-noto-cjk-extra \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# 创建必要的目录和设置权限
RUN mkdir -p /media /cache /config /root/.config/rclone /var/lib/jellyfin

# 设置环境变量
ENV JELLYFIN_PublishedServerUrl=http://localhost
ENV JELLYFIN_FFmpeg__PathToProbePath=/usr/lib/jellyfin-ffmpeg/ffprobe
ENV JELLYFIN_FFmpeg__PathToFFmpegPath=/usr/lib/jellyfin-ffmpeg/ffmpeg

# 设置工作目录
WORKDIR /

# 添加启动脚本
COPY ./start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
