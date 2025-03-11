# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # 📌 Swagger JSON/YAML ファイルの出力先を指定
  config.openapi_root = Rails.root.join('swagger').to_s

  # 📌 OpenAPI ドキュメントの設定
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.1.0', # 最新バージョンに更新
      info: {
        title: 'Chatting API V1', # API のタイトルを明示
        description: 'Chatting アプリの API ドキュメント',
        version: 'v1'
      },
      paths: {}, # エンドポイントはテストで追加
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'ローカル開発環境'
        },
        {
          url: 'https://{defaultHost}',
          description: '本番環境 (動的ホスト対応)',
          variables: {
            defaultHost: {
              default: 'api.chatting.com'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          BearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        }
      },
      security: [
        {
          BearerAuth: []
        }
      ]
    }
  }

  # 📌 Swagger の出力形式を YAML に設定
  config.openapi_format = :yaml
end
