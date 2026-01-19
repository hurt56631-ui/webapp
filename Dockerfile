# ========= Stage 1: build =========
FROM node:18-bullseye AS builder

WORKDIR /app

# 1. 安装系统级依赖
RUN apt-get update && apt-get install -y python3 make g++

# 2. 复制依赖文件
COPY package*.json ./

# 3. 安装所有依赖
RUN npm install

# 4. 复制源码
COPY . .

# 5. 执行构建 (已修正语法错误)
RUN NODE_OPTIONS="--max-old-space-size=2048" npm run build:prod

# ========= Stage 2: nginx =========
FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 拷贝生产环境产物
COPY --from=builder /app/umd /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
