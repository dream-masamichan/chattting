# Node.js の公式イメージを使用
FROM node:18

# 作業ディレクトリを作成
WORKDIR /app

# `package.json` がある場合はコピー
COPY package.json ./
COPY package-lock.json ./ || true

# 依存関係をインストール
RUN if [ -f package.json ]; then npm install; fi

# アプリケーションコードをコピー
COPY . .

# 開発サーバーを起動 (Vite, React, Vue, Next.js など)
CMD ["npm", "run", "dev"]
