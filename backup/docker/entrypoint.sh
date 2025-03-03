#!/bin/sh
set -e

# データベースが起動するまで待機
echo "Waiting for database..."
while ! nc -z postgres 5432; do
  sleep 1
done
echo "Database started"

# Rails のセットアップ
bundle exec rails db:migrate

# サーバー起動
exec "$@"
