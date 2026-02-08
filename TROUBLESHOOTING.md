# 故障排除指南

## 网络连接问题 - 无法拉取 Docker 镜像

### 问题描述

构建容器时出现以下错误:
```
Error: initializing source docker://ubuntu:22.04: pinging container registry registry-1.docker.io: 
Get "https://registry-1.docker.io/v2/": dial tcp 103.42.176.244:443: connect: connection refused
```

### 解决方案

#### 方案 1: 配置 Podman 镜像加速器(推荐)

在无法直接访问 Docker Hub 的环境中,配置国内镜像源。

##### 🚀 腾讯云服务器专用配置(推荐)

如果您在**腾讯云服务器**上运行,可以直接运行我们提供的配置脚本:

```bash
# 一键配置腾讯云镜像源
chmod +x config_tencent_mirror.sh
./config_tencent_mirror.sh
```

或者手动配置:

1. **创建配置目录**:
```bash
mkdir -p ~/.config/containers
```

2. **创建腾讯云镜像加速配置**:
```bash
cat > ~/.config/containers/registries.conf << 'EOF'
# 腾讯云镜像加速器配置
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"

# 腾讯云镜像(在腾讯云服务器上速度最快)
[[registry.mirror]]
location = "mirror.ccs.tencentyun.com"

# 备用镜像源
[[registry.mirror]]
location = "docker.mirrors.ustc.edu.cn"

[[registry.mirror]]
location = "hub-mirror.c.163.com"
EOF
```

##### 📦 通用配置(其他云服务商或本地)

如果您在其他环境,使用以下通用配置:

1. **创建配置目录**:
```bash
mkdir -p ~/.config/containers
```

2. **创建镜像加速配置文件**:
```bash
cat > ~/.config/containers/registries.conf << 'EOF'
# 配置镜像加速器
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"

[[registry.mirror]]
location = "docker.mirrors.ustc.edu.cn"

[[registry.mirror]]
location = "hub-mirror.c.163.com"

[[registry.mirror]]
location = "mirror.baidubce.com"
EOF
```

3. **验证配置**:
```bash
cat ~/.config/containers/registries.conf
```

4. **重新运行构建**:
```bash
./run.sh
```

#### 方案 2: 手动拉取镜像

如果镜像加速器仍然无法工作,可以尝试手动拉取镜像:

```bash
# 腾讯云服务器推荐使用腾讯云镜像
podman pull mirror.ccs.tencentyun.com/library/ubuntu:22.04
podman tag mirror.ccs.tencentyun.com/library/ubuntu:22.04 ubuntu:22.04

# 或者使用中科大镜像
podman pull docker.mirrors.ustc.edu.cn/library/ubuntu:22.04
podman tag docker.mirrors.ustc.edu.cn/library/ubuntu:22.04 ubuntu:22.04

# 或者使用阿里云镜像
podman pull registry.cn-hangzhou.aliyuncs.com/library/ubuntu:22.04
podman tag registry.cn-hangzhou.aliyuncs.com/library/ubuntu:22.04 ubuntu:22.04
```

#### 方案 3: 修改 Containerfile 使用国内镜像源

直接在 `Containerfile` 中指定镜像源:

```dockerfile
# 腾讯云服务器推荐:
FROM mirror.ccs.tencentyun.com/library/ubuntu:22.04

# 或使用中科大镜像:
FROM docker.mirrors.ustc.edu.cn/library/ubuntu:22.04

# 或使用阿里云镜像:
FROM registry.cn-hangzhou.aliyuncs.com/library/ubuntu:22.04
```

#### 方案 4: 使用代理

如果您有可用的代理服务器:

```bash
# 设置代理环境变量
export HTTP_PROXY=http://your-proxy:port
export HTTPS_PROXY=http://your-proxy:port

# 然后运行构建
./run.sh
```

### 可用的国内镜像源

根据您的云服务商选择对应的镜像源,速度最快:

- **腾讯云**: `mirror.ccs.tencentyun.com` ⭐ 腾讯云服务器首选
- **阿里云**: `registry.cn-hangzhou.aliyuncs.com` ⭐ 阿里云服务器首选
- **中国科技大学**: `docker.mirrors.ustc.edu.cn` 📚 教育网和通用场景
- **网易**: `hub-mirror.c.163.com` 🌐 通用场景
- **百度云**: `mirror.baidubce.com` ☁️ 百度云服务器首选

### 验证镜像源是否可用

```bash
# 腾讯云服务器测试腾讯云镜像源
curl -I https://mirror.ccs.tencentyun.com/v2/
podman pull mirror.ccs.tencentyun.com/library/hello-world:latest

# 测试中科大镜像源
curl -I https://docker.mirrors.ustc.edu.cn/v2/
podman pull docker.mirrors.ustc.edu.cn/library/hello-world:latest
```

## 其他常见问题

### Podman Secrets 未配置

如果看到错误:
```
错误: Podman Secrets 未配置
请先运行: ./setup-secrets.sh
```

**解决方法**:
```bash
./setup-secrets.sh
```

按照提示输入您的富途账号和密码。

### 容器无法启动

1. **检查日志**:
```bash
podman logs futu-opend
```

2. **检查容器状态**:
```bash
podman ps -a
```

3. **重新启动容器**:
```bash
podman-compose down
podman-compose up -d
```

### 端口已被占用

如果端口 11111 或 22222 已被占用,修改 `podman-compose.yml` 中的端口映射:

```yaml
ports:
  - "11111:11111"  # 改为 "11112:11111"
  - "22222:22222"  # 改为 "22223:22222"
```
