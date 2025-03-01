#!/bin/sh
set -e

# データベースが起動するまで待機
echo "Waiting for database..."
while ! nc -z db 5432; do
  sleep 1
done
echo "Database is up!"

# `tmp/pids/server.pid` を削除（再起動時の問題を防ぐ）
rm -f tmp/pids/server.pid

# アプリケーションを実行
exec "$@"
