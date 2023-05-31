# 使用 alpine-arm64 作为基础镜像
FROM alpine:3.14.2 AS builder

# 设置工作目录
WORKDIR /app

# 安装必要的依赖
RUN apk --no-cache add \
    git \
    build-base \
    cmake \
    openssl-dev

# 克隆 ttyd 仓库并编译
RUN git clone --depth=1 https://github.com/tsl0922/ttyd.git . && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install

# 构建最终的镜像
FROM alpine:3.14.2

# 安装运行时依赖
RUN apk --no-cache add \
    libstdc++ \
    openssl

# 从构建镜像复制编译好的二进制文件
COPY --from=builder /usr/local/bin/ttyd /usr/local/bin/ttyd

# 设置容器监听的端口
EXPOSE 80

# 启动 ttyd
CMD ["ttyd", "--port", "80", "--credential", "username:password", "bash"]
