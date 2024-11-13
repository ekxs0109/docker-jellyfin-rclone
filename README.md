# Jellyfin with Rclone Mount

一个基于 Docker 的项目，用于将 Jellyfin 媒体服务器与 Rclone 云存储挂载集成。支持 Google Drive、OneDrive、阿里云盘、AList WebDAV 等多种云存储服务。

## 功能特点

- 自动挂载云存储作为 Jellyfin 媒体库
- 支持多种云存储服务
- 基于 Docker 容器化部署
- 支持缓存配置，提升访问速度

## 快速开始

### 1. 准备 rclone 配置

首先需要配置 rclone 以连接你的云存储：

1. 在本地安装并配置 rclone：
   ```bash
   rclone config
   ```

2. 配置完成后，将生成的配置文件复制到项目目录：
   ```bash
   cp ~/.config/rclone/rclone.conf ./rclone.conf
   ```

### 2. 启动服务

```bash
docker compose up -d
```

### 3. 配置 Jellyfin

1. 访问 http://localhost:8096
2. 按照设置向导完成初始配置
3. 添加媒体库时，选择 `/media` 目录下的相应文件夹

## 目录结构

```
.
├── config/         # Jellyfin 配置文件
├── cache/         # Jellyfin 和 Rclone 缓存
├── media/         # Rclone 挂载点
└── rclone.conf    # Rclone 配置文件
```

## 注意事项

- 确保 `rclone.conf` 文件包含正确的远程存储配置
- 首次启动时，需要等待几秒钟让 rclone 完成挂载
- 建议配置适当的缓存参数以提升访问速度
- 确保 Docker 主机有足够的存储空间用于缓存

## 故障排除

如果遇到问题：

1. 检查容器日志：
   ```bash
   docker compose logs
   ```

2. 确认 rclone 挂载状态：
   ```bash
   docker compose exec jellyfin mount | grep rclone
   ```

## License

MIT License

## 贡献指南

欢迎提交 Issue 和 Pull Request！
