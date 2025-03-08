# Build Stage
FROM node:18 AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production Stage
FROM nginx:alpine AS production
COPY ../docker/nginx.conf /etc/nginx/nginx.conf  
COPY --from=builder /app/dist /usr/share/nginx/html
COPY ../swagger/swagger.json /usr/share/nginx/html/swagger.json  
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
