# ========= Stage 1: build =========
FROM node:18-alpine AS builder

WORKDIR /app

# 先复制依赖文件，利用 Docker 缓存
COPY package*.json ./
# 安装编译依赖
RUN npm install

# 复制前端所有源码
COPY . .

# 执行构建逻辑（Tinode 源码通常产出到 build 文件夹）
RUN npm run build

# ========= Stage 2: nginx =========
FROM nginx:alpine

# 删除 Nginx 默认的欢迎页配置
RUN rm /etc/nginx/conf.d/default.conf

# 拷贝你之前创建的 nginx.conf 到容器
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 【核心修正】将路径从 /app/dist 改为 /app/build
# 如果构建依然报错找不到路径，请运行 ls -F 确认输出文件夹名称
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
