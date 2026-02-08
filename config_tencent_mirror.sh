#!/bin/bash

# Podman 腾讯云镜像源配置脚本
# 可以直接运行此脚本来配置镜像源

set -e

CONFIG_DIR="$HOME/.config/containers"
CONFIG_FILE="$CONFIG_DIR/registries.conf"

echo "正在配置腾讯云 Podman 镜像加速器..."

# 1. 确保配置目录存在
if [ ! -d "$CONFIG_DIR" ]; then
    echo "创建配置目录: $CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
fi

# 2. 备份现有配置(如果存在)
if [ -f "$CONFIG_FILE" ]; then
    BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    echo "备份现有配置文件到: $BACKUP_FILE"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
fi

# 3. 写入新的配置
echo "写入配置文件: $CONFIG_FILE"
cat > "$CONFIG_FILE" << 'EOF'
# 腾讯云镜像加速器自动配置
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"

# 腾讯云内网镜像(速度极快)
[[registry.mirror]]
location = "mirror.ccs.tencentyun.com"

# 备用公网镜像源
[[registry.mirror]]
location = "docker.mirrors.ustc.edu.cn"

[[registry.mirror]]
location = "hub-mirror.c.163.com"
EOF

echo "✅ 配置完成!"
echo "配置内容如下:"
cat "$CONFIG_FILE"
echo ""
echo "您可以尝试运行 ./run.sh 重新构建容器。"
