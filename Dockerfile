# ========= Stage 1: build =========
FROM node:18-alpine AS builder

WORKDIR /app

# 先复制依赖文件，提高缓存命中率
COPY package*.json ./
RUN npm install

# 再复制源码
COPY . .

# 构建前端（Tinode webapp 默认输出到 dist）
RUN npm run build

# ========= Stage 2: nginx =========
FROM nginx:alpine

# 删除默认配置
RUN rm /etc/nginx/conf.d/default.conf

# 拷贝我们自己的 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 拷贝前端构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
