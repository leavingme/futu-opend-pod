#!/bin/bash

# 从 Podman Secrets 读取账号信息
if [ -f "/run/secrets/futu_account_id" ]; then
    FUTU_ACCOUNT_ID=$(cat /run/secrets/futu_account_id)
    echo "✓ 从 Podman Secret 读取账号 ID"
fi

if [ -f "/run/secrets/futu_account_pwd" ]; then
    FUTU_ACCOUNT_PWD=$(cat /run/secrets/futu_account_pwd)
    echo "✓ 从 Podman Secret 读取密码"
fi

# 检查必要的配置
if [ -z "$FUTU_ACCOUNT_ID" ] || [ -z "$FUTU_ACCOUNT_PWD" ]; then
    echo "错误: 未找到富途账号配置!"
    echo "请先创建 Podman Secrets:"
    echo "  echo 'your_account_id' | podman secret create futu_account_id -"
    echo "  echo 'your_password' | podman secret create futu_account_pwd -"
    exit 1
fi

# 替换配置文件中的占位符
sed -i "s/\${FUTU_ACCOUNT_ID}/$FUTU_ACCOUNT_ID/g" /app/FutuOpenD.xml
sed -i "s/\${FUTU_ACCOUNT_PWD}/$FUTU_ACCOUNT_PWD/g" /app/FutuOpenD.xml

# 检查 RSA 密钥文件是否存在
if [ ! -f "/app/config/futu.pem" ]; then
    echo "警告: RSA 密钥文件不存在,正在生成..."
    openssl genrsa -out /app/config/futu.pem 1024
    chmod 600 /app/config/futu.pem
fi

# 显示启动信息
# 检查 OpenD 可执行文件是否存在
if [ ! -f "/app/FutuOpenD" ]; then
    echo "错误: /app/FutuOpenD 可执行文件不存在!"
    echo "当前目录结构:"
    ls -R /app
    exit 1
fi

echo "========================================="
echo "Futu OpenD 容器启动中..."
echo "========================================="
echo "账号: $FUTU_ACCOUNT_ID"
echo "API 端口: 11111"
echo "Telnet 端口: 22222 (用于输入验证码)"
echo ""
echo "正在启动: /app/FutuOpenD"
echo "配置文件: /app/FutuOpenD.xml"
echo ""

# 启动 FTOpenD
exec /app/FutuOpenD
