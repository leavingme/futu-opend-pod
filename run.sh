#!/bin/bash

# 检查 Podman Secrets 是否存在
check_secret() {
    podman secret ls --format "{{.Name}}" | grep -q "^$1$"
}

if ! check_secret "futu_account_id" || ! check_secret "futu_account_pwd"; then
    echo "错误: Podman Secrets 未配置"
    echo "请先运行: ./setup-secrets.sh"
    exit 1
fi

# 检查 RSA 密钥是否存在
if [ ! -f "config/futu.pem" ]; then
    echo "错误: RSA 密钥不存在"
    echo "请先运行: ./init.sh"
    exit 1
fi

# 构建镜像
echo "正在构建 Futu OpenD 镜像..."
podman-compose build

# 启动容器
echo "正在启动 Futu OpenD 容器..."
podman-compose up -d --force-recreate

echo ""
echo "========================================="
echo "Futu OpenD 容器已启动!"
echo "========================================="
echo "API 端口: 11111"
echo "Telnet 端口: 22222"
echo ""
echo "查看日志: podman-compose logs -f"
echo "停止容器: podman-compose down"
echo ""
echo "如需输入验证码:"
echo "  podman exec -it futu-opend telnet localhost 22222"
echo "  然后输入: input_phone_verify_code -code=<你的验证码>"
echo "========================================="
