# ========= Stage 1: build =========
FROM node:18-bullseye AS builder

WORKDIR /app

# 1. 安装系统级依赖（解决 postcss 等工具报错）
RUN apt-get update && apt-get install -y python3 make g++

# 2. 复制依赖文件
COPY package*.json ./

# 3. 安装所有依赖（包含开发依赖）
RUN npm install

# 4. 复制源码
COPY . .

# 5. 执行构建（增加内存限制，防止 OOM 崩溃）
NODE_OPTIONS="--max-old-space-size=2048" RUN npm run build:prod

# ========= Stage 2: nginx =========
FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 根据 Tinode 官方逻辑，生产环境编译输出通常在 ./umd/ 文件夹
# 如果 ./umd/ 报错，请尝试改成 ./ (根目录) 或 ./dist/
COPY --from=builder /app/umd /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
