# ベースイメージ
FROM ruby:3.3.0

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

# 作業ディレクトリ
WORKDIR /app

# 依存関係をインストール
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.5.11 && bundle install --jobs 4 --retry 3

# アプリケーションコードをコピー
COPY . .

# entrypoint.sh をコピーして実行可能にする
COPY docker/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# エントリーポイントを設定
ENTRYPOINT ["entrypoint.sh"]

# Rails サーバーをデフォルトで実行
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
