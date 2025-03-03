# ==============================
# 1️⃣ Ruby のベースイメージ
# ==============================
FROM ruby:3.3.0 AS base

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  curl \
  nodejs \
  yarn \
  postgresql-client \
  libpq-dev \
  netcat-openbsd \
  && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを `/app` に設定
WORKDIR /app

# Bundler を最新バージョンに更新
RUN gem install bundler

# ==============================
# 2️⃣ 依存関係のインストール
# ==============================
FROM base AS builder

# `Gemfile` と `Gemfile.lock` をコピー（キャッシュを最適化）
COPY Gemfile Gemfile.lock ./

# `bundle install` を実行（キャッシュを最大限活用）
RUN bundle config set without 'development test' && \
    bundle install --jobs=4 --retry=3 && \
    rm -rf /usr/local/bundle/cache

# ==============================
# 3️⃣ アプリケーションをコピー
# ==============================
FROM base

# `builder` ステージでインストールした gem をコピー
COPY --from=builder /usr/local/bundle /usr/local/bundle

# アプリケーションのソースコードをコピー
COPY . .

# `entrypoint.sh` に実行権限を付与
RUN chmod +x docker/entrypoint.sh

# `Rails` のエントリーポイント
ENTRYPOINT ["sh", "./docker/entrypoint.sh"]

# デフォルトのコマンド
CMD ["rails", "server", "-b", "0.0.0.0"]
