# ===========================
# 🔹 1. ビルド環境 (builder)
# ===========================
FROM ruby:3.3.0 AS builder

# 環境変数を設定
ENV RAILS_ENV=production \
    BUNDLE_PATH=/gems \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

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

# 依存関係を先にコピー (キャッシュを利用)
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.5.11 && bundle install --jobs 4 --retry 3

# Node.js パッケージをインストール
COPY package.json yarn.lock ./
RUN yarn install --check-files

# ===========================
# 🔹 2. ランタイム環境 (runtime)
# ===========================
FROM ruby:3.3.0 AS runtime

# 環境変数を設定
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    SECRET_KEY_BASE=your_secret_key_here

# 必要なパッケージのみをインストール
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libpq-dev \
  nodejs \
  yarn \
  imagemagick \
  tzdata \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを作成
WORKDIR /app

# `builder` ステージから Gem をコピー
COPY --from=builder /gems /gems
ENV BUNDLE_PATH=/gems

# アプリケーションコードをコピー
COPY . .

# `builder` ステージで Yarn でインストールしたパッケージもコピー
COPY --from=builder /app/node_modules /app/node_modules

# アセットをプリコンパイル (本番環境)
RUN bundle exec rails assets:precompile

# エントリーポイントを設定
COPY docker/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Web サーバーを起動
ENTRYPOINT ["entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
