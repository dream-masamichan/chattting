# 1️⃣ Ruby 3.2 の公式イメージをベースにする
FROM ruby:3.2

# 2️⃣ 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
  nodejs yarn postgresql-client

# 3️⃣ 作業ディレクトリを `/app` に設定
WORKDIR /app

# 4️⃣ Bundler を最新バージョンに更新
RUN gem install bundler

# 5️⃣ Gemfile と Gemfile.lock をコピー（キャッシュ最適化のため）
COPY Gemfile Gemfile.lock ./

# 6️⃣ `bundle install` を実行
RUN bundle install

# 7️⃣ アプリケーションのソースコードをコピー
COPY . .

# 8️⃣ デフォルトのエントリーポイント（シェル起動）
CMD ["sh"]
