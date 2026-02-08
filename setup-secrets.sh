#!/bin/bash

echo "=== 配置 Futu OpenD Podman Secrets ==="
echo ""

# 检查 secrets 是否已存在
check_secret() {
    podman secret ls --format "{{.Name}}" 2>/dev/null | grep -q "^$1$"
}

# 创建账号 ID secret
if check_secret "futu_account_id"; then
    echo "⚠️  Secret 'futu_account_id' 已存在"
    read -p "是否要重新创建? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        podman secret rm futu_account_id 2>/dev/null
        read -p "请输入富途账号 ID: " ACCOUNT_ID
        echo -n "$ACCOUNT_ID" | podman secret create futu_account_id -
        echo "✓ 账号 ID 已更新"
    fi
else
    read -p "请输入富途账号 ID: " ACCOUNT_ID
    echo -n "$ACCOUNT_ID" | podman secret create futu_account_id -
    echo "✓ 账号 ID 已创建"
fi

echo ""

# 创建密码 secret
if check_secret "futu_account_pwd"; then
    echo "⚠️  Secret 'futu_account_pwd' 已存在"
    read -p "是否要重新创建? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        podman secret rm futu_account_pwd 2>/dev/null
        read -sp "请输入富途账号密码 (输入不会显示): " ACCOUNT_PWD
        echo
        echo -n "$ACCOUNT_PWD" | podman secret create futu_account_pwd -
        echo "✓ 密码已更新"
    fi
else
    read -sp "请输入富途账号密码 (输入不会显示): " ACCOUNT_PWD
    echo
    echo -n "$ACCOUNT_PWD" | podman secret create futu_account_pwd -
    echo "✓ 密码已创建"
fi

echo ""
echo "========================================="
echo "✅ Podman Secrets 配置完成!"
echo "========================================="
echo ""
echo "查看已创建的 secrets:"
podman secret ls
echo ""
echo "下一步: 运行 ./run.sh 启动容器"
