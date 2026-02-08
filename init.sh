#!/bin/bash

# 创建配置目录
mkdir -p config data logs

# 生成 RSA 私钥
echo "正在生成 RSA 私钥..."
openssl genrsa -out config/futu.pem 1024
chmod 600 config/futu.pem

echo "✓ RSA 私钥已生成: config/futu.pem"
echo ""
echo "下一步: 配置 Podman Secrets"
echo "运行: ./setup-secrets.sh"
