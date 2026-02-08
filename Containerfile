FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    wget \
    telnet \
    ca-certificates \
    libssl3 \
    libxml2 \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /app

# 下载并安装 Futu OpenD (自动获取最新版本)
RUN wget -O FTOpenD.tar.gz "https://www.futunn.com/download/fetch-lasted-link?name=opend-ubuntu" && \
    tar -xzf FTOpenD.tar.gz && \
    rm FTOpenD.tar.gz && \
    # 查找并进入解压后的目录
    OPEND_DIR=$(ls -d Futu_OpenD_*_Ubuntu* | head -n 1) && \
    # 删除 GUI 版本 (容器中不需要)
    rm -rf "$OPEND_DIR/Futu_OpenD-GUI_"* && \
    # 移动 OpenD 命令行版本到工作目录
    mv "$OPEND_DIR/Futu_OpenD_"*_Ubuntu*/* /app/ && \
    # 清理解压的临时目录
    rm -rf "$OPEND_DIR" && \
    chmod +x /app/FutuOpenD

# 创建配置和数据目录
RUN mkdir -p /app/config /app/data /app/logs

# 复制配置文件
COPY FutuOpenD.xml /app/FutuOpenD.xml
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 暴露端口
# 11111: API 端口
# 22222: Telnet 端口 (用于输入验证码)
EXPOSE 11111 22222

# 设置入口点
ENTRYPOINT ["/app/entrypoint.sh"]
