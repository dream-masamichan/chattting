# ==============================
# 1️⃣ Build Stage (builder) - 依存関係をインストール & ビルド
# ==============================
FROM node:18 AS builder

# 環境変数の設定
ENV NODE_ENV=production

# 作業ディレクトリの作成
WORKDIR /app

# package.json と package-lock.json をコピー（キャッシュ最適化）
COPY package.json package-lock.json ./

# 依存関係をインストール
RUN npm ci

# 残りのアプリコードをコピー
COPY . .

# Vite アプリをビルド（dist フォルダが作成される）
RUN npm run build

# ==============================
# 2️⃣ Production Stage - nginx を使用して軽量な本番環境を構築
# ==============================
FROM nginx:alpine AS production

# `nginx.conf` をコピー（最適化された設定）
COPY docker/nginx.conf /etc/nginx/nginx.conf

# builder ステージからビルド済みの `dist` フォルダをコピー
COPY --from=builder /app/dist /usr/share/nginx/html

# ポート 80 を公開
EXPOSE 80

# `nginx` を起動
CMD ["nginx", "-g", "daemon off;"]
