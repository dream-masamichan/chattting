# Node.js の公式イメージを使用
FROM node:18

# 作業ディレクトリを設定
WORKDIR /app

# package.json と package-lock.json をコピー
COPY package.json package-lock.json ./

# 必要な依存関係をインストール
RUN npm install

# アプリケーションコードをコピー
COPY . .

# 開発用サーバーを起動
CMD ["npm", "run", "dev"]