# ==============================
# 1️⃣ Build Stage (builder) - 依存パッケージをインストール
# ==============================
FROM ruby:3.3.0 AS builder

# 環境変数の設定
ENV RAILS_ENV=production \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/gems \
    NODE_ENV=production \
    YARN_CACHE_FOLDER=/yarn_cache

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  imagemagick \
  tzdata \
  redis-tools \
  postgresql-client \
  netcat \
  && apt-get clean && rm -rf /var/lib/apt/lists/* || true

# 作業ディレクトリを作成
WORKDIR /app

# Bundler を最新化
RUN gem install bundler -v 2.5.11

# Gemfile を先にコピーし、キャッシュを活用
COPY Gemfile Gemfile.lock ./

# `bundle install` (キャッシュを活用)
RUN bundle config set without 'development test' && bundle install --jobs=${BUNDLE_JOBS} --retry=${BUNDLE_RETRY}

# ==============================
# 2️⃣ Runtime Stage (Final) - 本番環境用のコンテナを作成
# ==============================
FROM ruby:3.3.0-slim

# `non-root` ユーザーを作成 (セキュリティ強化)
RUN useradd -m appuser

# 環境変数の設定 (実行環境向け)
ENV RAILS_ENV=production \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/gems \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    NODE_ENV=production

# 作業ディレクトリを設定
WORKDIR /app

# 必要なパッケージを最小限インストール
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libpq-dev \
  imagemagick \
  tzdata \
  redis-tools \
  postgresql-client \
  netcat \
  && apt-get clean && rm -rf /var/lib/apt/lists/* || true

# `builder` ステージから gem をコピー (軽量化)
COPY --from=builder /gems /gems

# アプリケーションコードをコピー
COPY . .

# SHELL を `bash -c` に変更 (より安定したスクリプト実行)
SHELL ["/bin/bash", "-c"]

# ✅ `entrypoint.sh` を `/app/` に配置
COPY docker/entrypoint.sh /app/entrypoint.sh

# ✅ 実行権限を付与 (root 権限の間に実行)
RUN chmod +x /app/entrypoint.sh

# ✅ `non-root` ユーザーに変更 (セキュリティ向上)
USER appuser

# ✅ エントリーポイントを設定
ENTRYPOINT ["/app/entrypoint.sh"]

# デフォルトの Rails サーバー起動コマンド
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
