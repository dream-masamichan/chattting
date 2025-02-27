set -e  # エラーが発生したら即終了

echo "🚀 chattting の Rails コンテナ起動スクリプト開始..."

rm -f /app/tmp/pids/server.pid

echo "🔄 データベースを確認..."
bundle exec rails db:prepare  # `db:create`, `db:migrate` を自動実行

echo "🚀 Rails サーバーを起動中..."
exec "$@"