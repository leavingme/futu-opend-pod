# Futu OpenD Podman 容器

这是一个用于运行富途 OpenD 的 Podman 容器项目,支持通过 Podman Compose 快速部署和管理。

## 📋 前置要求

### 必需软件

- **Podman**: 容器运行时
- **podman-compose**: 容器编排工具
- **有效的富途证券账号**

### 安装 Podman 和 podman-compose

#### macOS

```bash
# 使用 Homebrew 安装 Podman
brew install podman

# 初始化 Podman 虚拟机
podman machine init
podman machine start

# 安装 podman-compose
brew install podman-compose
```

#### Ubuntu/Debian

```bash
# 安装 Podman
sudo apt-get update
sudo apt-get install -y podman

# 安装 podman-compose
sudo apt-get install -y podman-compose

# 或使用 pip 安装最新版本
pip3 install podman-compose
```

#### CentOS/RHEL/Fedora

```bash
# 安装 Podman (通常已预装)
sudo dnf install -y podman

# 安装 podman-compose
sudo dnf install -y podman-compose

# 或使用 pip 安装
pip3 install podman-compose
```

#### 验证安装

```bash
# 检查 Podman 版本
podman --version

# 检查 podman-compose 版本
podman-compose --version
```

## ⚠️ 重要安全须知

### Podman Secrets 的安全限制

虽然本项目使用 Podman Secrets 存储密码,但需要了解以下**重要安全事实**:

> **🔴 关键风险**: Podman Secrets 通过文件权限保护,但**同一用户下运行的其他程序可以读取 secrets**!

**具体风险**:
- Podman Secrets 存储在 `~/.local/share/containers/storage/secrets/`
- 文件权限为 `600` (仅所有者可读)
- **但同一用户的任何程序都可以读取**

**示例场景**:
```bash
# 如果你以 ubuntu 用户运行 OpenD 容器
# 同时以 ubuntu 用户运行其他程序(如 OpenClaw)
# 那么其他程序可以执行:
cat ~/.local/share/containers/storage/secrets/*
# 读取到你的富途账号密码!
```

### 🛡️ 安全建议

#### 个人开发环境
- ✅ 确保系统中只运行可信任的软件
- ✅ 定期检查运行的进程
- ✅ 使用富途子账号(权限受限)

#### 生产环境或多程序环境 (强烈推荐)
**必须使用专用用户运行容器**:

```bash
# 创建专用用户
sudo useradd -m -s /bin/bash futu-opend

# 切换到专用用户
sudo su - futu-opend

# 在专用用户下配置和运行
cd ~
git clone <项目地址>
cd futu-opend-pod
./init.sh
./setup-secrets.sh
./run.sh
```

这样其他用户运行的程序**完全无法访问** `futu-opend` 用户的 secrets!

> **💡 最佳实践**: 如果你的系统上运行了其他不完全信任的程序,**强烈建议**使用专用用户运行 OpenD 容器。

## 🚀 快速开始

### 1. 初始化项目

```bash
# 生成 RSA 密钥和创建必要目录
chmod +x init.sh
./init.sh
```

### 2. 配置 Podman Secrets (安全方式)

```bash
# 交互式配置账号和密码
chmod +x setup-secrets.sh
./setup-secrets.sh
```

> **🔐 安全优势**: Podman Secrets 将密码加密存储,不会以明文形式保存在文件系统中,比 `.env` 文件更安全!

### 3. 启动容器

```bash
# 构建并启动容器
chmod +x run.sh
./run.sh
```

## 🏭 生产环境最佳实践

### 创建专用用户(必须!)

> **🔴 重要**: 如果你的系统上运行了其他程序,**必须**使用专用用户运行容器,否则其他程序可以读取你的富途账号密码!

在生产服务器或多程序环境中,创建专用用户运行容器:

```bash
# 1. 创建专用用户
sudo useradd -m -s /bin/bash futu-opend

# 2. 切换到该用户
sudo su - futu-opend

# 3. 克隆项目
cd ~
git clone <项目地址>
cd futu-opend-pod

# 4. 按照快速开始步骤配置和运行
./init.sh
./setup-secrets.sh
./run.sh
```

### 安全加固建议

1. **用户隔离**: 使用专用用户运行,遵循最小权限原则
2. **防火墙配置**: 只开放必要的端口(11111, 22222)
3. **定期更新**: 定期更新 OpenD 版本和系统补丁
4. **日志监控**: 监控 `logs/` 目录中的日志文件
5. **备份策略**: 定期备份 `config/` 和 `data/` 目录
6. **网络限制**: 如果只在本地使用,将 `FutuOpenD.xml` 中的 `listen_ip` 改为 `127.0.0.1`

### 系统服务配置(可选)

使用 systemd 管理容器自动启动:

```bash
# 创建 systemd 服务文件
sudo tee /etc/systemd/system/futu-opend.service << EOF
[Unit]
Description=Futu OpenD Container
After=network.target

[Service]
Type=forking
User=futu-opend
WorkingDirectory=/home/futu-opend/futu-opend-pod
ExecStart=/home/futu-opend/futu-opend-pod/run.sh
ExecStop=/usr/bin/podman-compose down
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动服务
sudo systemctl enable futu-opend
sudo systemctl start futu-opend
```

## 📝 验证码输入

首次登录或特定情况下需要输入手机验证码:

```bash
# 进入容器的 Telnet 服务
podman exec -it futu-opend telnet localhost 22222

# 输入验证码(将 123456 替换为你收到的验证码)
input_phone_verify_code -code=123456
```

## 🔧 常用命令

```bash
# 查看容器日志
podman-compose logs -f

# 停止容器
podman-compose down

# 重启容器
podman-compose restart

# 查看容器状态
podman-compose ps

# 进入容器
podman exec -it futu-opend /bin/bash
```

## 📂 目录结构

```
futu-opend-pod/
├── Containerfile          # 容器构建文件
├── podman-compose.yml     # Podman Compose 配置
├── FutuOpenD.xml          # OpenD 配置模板
├── entrypoint.sh          # 容器启动脚本
├── init.sh                # 初始化脚本
├── setup-secrets.sh       # Podman Secrets 配置脚本
├── run.sh                 # 运行脚本
├── config/                # 配置文件目录
│   └── futu.pem          # RSA 私钥
├── data/                  # 数据目录
└── logs/                  # 日志目录
```

## ⚙️ 配置说明

### FutuOpenD.xml 主要配置项

#### 基础参数
- `ip`: 监听 IP,默认 `127.0.0.1`,容器中设置为 `0.0.0.0` 允许外部访问
- `api_port`: API 端口,默认 `11111`
- `telnet_port`: Telnet 端口,默认 `22222`
- `login_account`: 登录账号(从 Podman Secrets 读取)
- `login_pwd_md5`: 登录密码,支持明文或 MD5(从 Podman Secrets 读取)
- `lang`: 语言设置(`en`=英文, `chs`=简体中文)

#### 进阶参数
- `log_level`: 日志级别(`no`, `debug`, `info`, `warning`, `error`, `fatal`)
- `push_proto_type`: API 推送协议格式(`0`=Protobuf, `1`=JSON)
- `rsa_private_key`: RSA 私钥路径,用于 API 协议加密
- `price_reminder_push`: 是否接收到价提醒推送(`0`=否, `1`=是)
- `auto_hold_quote_right`: 被踢后是否自动抢权限(`0`=否, `1`=是)
- `future_trade_api_time_zone`: 期货交易 API 时区(如 `UTC+8`)

#### 美股交易保护参数
- `pdt_protection`: 防止被标记为日内交易者(`0`=否, `1`=是)
- `dtcall_confirmation`: 日内交易保证金追缴预警(`0`=否, `1`=是)

### Podman Secrets

项目使用 Podman Secrets 安全存储敏感信息:

- `futu_account_id`: 富途账号 ID
- `futu_account_pwd`: 富途账号密码(明文或MD5)

**管理 Secrets**:
```bash
# 查看已创建的 secrets
podman secret ls

# 删除 secret
podman secret rm futu_account_id
podman secret rm futu_account_pwd

# 重新配置
./setup-secrets.sh
```

## 🔐 安全特性

### 1. Podman Secrets (推荐)

✅ **已默认启用**: 项目使用 Podman Secrets 加密存储敏感信息
- 密码不会以明文形式存储在文件系统
- 自动加密,防止泄露
- 符合生产环境安全标准

### 2. 其他安全措施

1. **密码加密**: 可以使用 MD5 加密后的密码
   ```bash
   echo -n "your_password" | md5
   ```

2. **网络隔离**: 如果只在本地使用,可以将 `listen_ip` 改为 `127.0.0.1`

3. **密钥保护**: RSA 私钥自动设置权限为 600

4. **容器隔离**: OpenD 运行在容器内,无法访问宿主机敏感文件

## 🐛 故障排查

### 容器无法启动

1. 检查 `.env` 文件是否存在且配置正确
2. 检查 `config/futu.pem` 是否存在
3. 查看容器日志: `podman-compose logs`

### 无法连接 API

1. 确认容器正在运行: `podman-compose ps`
2. 检查端口映射是否正确
3. 检查防火墙设置

### 验证码输入失败

1. 确保使用 Telnet 连接到端口 22222
2. 验证码格式: `input_phone_verify_code -code=123456`
3. 验证码有时效性,请及时输入

## 📚 参考资料

- [富途 OpenAPI 文档](https://openapi.futunn.com/)
- [Podman 官方文档](https://podman.io/)
- [podman-compose GitHub](https://github.com/containers/podman-compose)

## 📄 许可证

本项目仅供学习和研究使用,请遵守富途证券的服务条款。

## ⚠️ 免责声明

本项目为非官方实现,使用前请确保了解相关风险。作者不对使用本项目造成的任何损失负责。
