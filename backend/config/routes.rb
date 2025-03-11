Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  namespace :api do
    namespace :v1 do
      get "dashboard/index", to: "dashboard#index"
    end
  end

  # 📌 Swagger API ドキュメント
  mount SwaggerUiEngine::Engine, at: "/api-docs"  # ✅ Swagger UI を追加

  # 📌 認証関連
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    confirmations: 'devise_overrides/confirmations',
    passwords: 'devise_overrides/passwords',
    sessions: 'devise_overrides/sessions',
    token_validations: 'devise_overrides/token_validations',
    omniauth_callbacks: 'devise_overrides/omniauth_callbacks',
    registrations: 'devise_overrides/registrations'
  }, via: [:get, :post]

  # ユーザー登録エンドポイント
  post 'auth/sign_up', to: 'devise_overrides/registrations#create'

  # 📌 フロントエンドのルーティング
  if ActiveModel::Type::Boolean.new.cast(ENV.fetch('CW_API_ONLY_SERVER', false))
    root to: 'api#index'
  else
    root to: 'dashboard#index'

    get '/app', to: 'dashboard#index'
    get '/app/*params', to: 'dashboard#index'
    get '/app/accounts/:account_id/settings/inboxes/new/twitter', to: 'dashboard#index', as: 'app_new_twitter_inbox'
    get '/app/accounts/:account_id/settings/inboxes/new/microsoft', to: 'dashboard#index', as: 'app_new_microsoft_inbox'

    # 📌 重複を修正
    get '/app/accounts/:account_id/settings/inboxes/new/:inbox_id/twitter_agents', to: 'dashboard#index', as: 'app_twitter_inbox_agents'
    get '/app/accounts/:account_id/settings/inboxes/new/:inbox_id/email_agents', to: 'dashboard#index', as: 'app_email_inbox_agents'

    get '/app/accounts/:account_id/settings/inboxes/:inbox_id', to: 'dashboard#index', as: 'app_email_inbox_settings'

    resource :widget, only: [:show]
    
    namespace :survey do
      resources :responses, only: [:show]
    end
    
    resource :slack_uploads, only: [:show]
  end

  # 📌 API ルート
  get '/api', to: 'api#index'
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      # ------------------------------
      # アカウント関連
      resources :accounts, only: [:create, :show, :update] do
        member do
          post :update_active_at
          get :cache_keys
        end

        scope module: :accounts do
          resources :agents, only: [:index, :create, :update, :destroy]
          resources :conversations, only: [:index, :create, :show, :update]
          resources :contacts, only: [:index, :show, :update, :create, :destroy]
          resources :notifications, only: [:index, :update, :destroy]

          namespace :captain do
            resources :assistants
            resources :documents, only: [:index, :show, :create, :destroy]
            resources :assistant_responses
          end

          namespace :integrations do
            resources :apps, only: [:index, :show]
            resources :hooks, only: [:show, :create, :update, :destroy]
          end
        end
      end
    end
  end

  # 📌 管理者用ルート
  devise_for :super_admins, path: 'super_admin', controllers: { sessions: 'super_admin/devise/sessions' }
  devise_scope :super_admin do
    get 'super_admin/logout', to: 'super_admin/devise/sessions#destroy'

    namespace :super_admin do
      root to: 'dashboard#index'
      resources :accounts, only: [:index, :new, :create, :show, :edit, :update, :destroy]
      resources :users, only: [:index, :new, :create, :show, :edit, :update, :destroy]
      resources :platform_apps, only: [:index, :new, :create, :show, :edit, :update]
      resource :instance_status, only: [:show]
    end
  end

  # 📌 Webhook エンドポイント
  post 'webhooks/stripe', to: 'webhooks/stripe#process_payload'
  post 'webhooks/firecrawl', to: 'webhooks/firecrawl#process_payload'

  # 📌 公開 API
  namespace :public, defaults: { format: 'json' } do
    namespace :api do
      namespace :v1 do
        resources :inboxes do
          scope module: :inboxes do
            resources :contacts, only: [:create, :show, :update]
          end
        end
      end
    end
  end

  # 📌 外部サービスの認証用エンドポイント
  namespace :twitter do
    resource :callback, only: [:show]
  end

  namespace :twilio do
    resources :callback, only: [:create]
    resources :delivery_status, only: [:create]
  end

  get 'microsoft/callback', to: 'microsoft/callbacks#show'
  get 'google/callback', to: 'google/callbacks#show'

  # 📌 Sidekiq モニタリング
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  authenticated :super_admin do
    mount Sidekiq::Web => '/monitoring/sidekiq'
  end

  # 📌 Swagger API ドキュメント
  get '/swagger/*path', to: 'swagger#respond'
  get '/swagger', to: 'swagger#respond'
end
