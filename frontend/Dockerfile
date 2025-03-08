# 1️⃣ Node.js の公式イメージを使用
FROM node:18 AS builder

# 2️⃣ 作業ディレクトリを設定
WORKDIR /app

# 3️⃣ package.json と package-lock.json をコピー（キャッシュ最適化）
COPY package.json package-lock.json ./

# 4️⃣ 依存関係をインストール
RUN npm ci

# 5️⃣ 残りのアプリコードをコピー
COPY . .

# 6️⃣ Vite アプリをビルド（dist フォルダが作成される）
RUN npm run build

# 7️⃣ nginx を使用して軽量な本番環境を構築
FROM nginx:alpine AS production

# 8️⃣ `nginx.conf` を適切な場所にコピー（`frontend/nginx/` にある場合）
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# 9️⃣ builder ステージからビルド済みの `dist` フォルダをコピー
COPY --from=builder /app/dist /usr/share/nginx/html

# 🔟 ポート 80 を公開
EXPOSE 80

# ⓫ `nginx` を起動
CMD ["nginx", "-g", "daemon off;"]
