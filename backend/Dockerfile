# Ruby 3.2 の公式イメージを使用
FROM ruby:3.3.0

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
  build-essential nodejs yarn postgresql-client libpq-dev

# 作業ディレクトリを `/app` に設定
WORKDIR /app

# Bundler を最新バージョンに更新
RUN gem install bundler

# `Gemfile` と `Gemfile.lock` をコピー
COPY Gemfile Gemfile.lock ./

# 依存関係をインストール
RUN bundle install --jobs=4 --retry=3

# アプリケーションのソースコードをコピー
COPY . .

# `entrypoint.sh` に実行権限を付与（ここで `chmod +x` を実行）
RUN chmod +x docker/entrypoint.sh

# `Rails` のエントリーポイント
ENTRYPOINT ["sh", "./docker/entrypoint.sh"]

# デフォルトのコマンド
CMD ["rails", "server", "-b", "0.0.0.0"]
