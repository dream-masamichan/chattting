# ==============================
# 1️⃣ Build Stage (builder)
# ==============================
FROM ruby:3.2.2 AS builder

# 環境変数の設定 (インストール最適化)
ENV RAILS_ENV=production \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/gems

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
  && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを作成
WORKDIR /app

# Bundler を最新化
RUN gem install bundler -v 2.5.11

# Gemfile をコピー (キャッシュ最適化)
COPY Gemfile Gemfile.lock ./

# `bundle install` を実行 (キャッシュ利用)
RUN bundle install --jobs=${BUNDLE_JOBS} --retry=${BUNDLE_RETRY} --without development test

# ==============================
# 2️⃣ Runtime Stage (Final)
# ==============================
FROM ruby:3.2.2-slim

# `non-root` ユーザーを作成 (セキュリティ強化)
RUN useradd -m appuser

# 環境変数の設定 (本番環境向け)
ENV RAILS_ENV=production \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/gems \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true

# 作業ディレクトリを作成
WORKDIR /app

# 必要なパッケージをインストール (最小限)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libpq-dev \
  imagemagick \
  tzdata \
  redis-tools \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/*

# `builder` ステージから gem をコピー
COPY --from=builder /gems /gems

# `non-root` ユーザーに変更
USER appuser

# アプリケーションコードをコピー
COPY . .

# エントリーポイントスクリプトを設定
COPY docker/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# エントリーポイントを設定
ENTRYPOINT ["entrypoint.sh"]

# デフォルトの Rails サーバー起動コマンド
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
