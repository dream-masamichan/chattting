class Api::V1::AccountsController < Api::BaseController
    include AuthHelper
    include CacheKeysHelper
  
    skip_before_action :authenticate_user!, :set_current_user, :handle_with_exception, only: [:create], raise: false
    before_action :check_signup_enabled, only: [:create]
    before_action :ensure_account_name, only: [:create]
    before_action :validate_captcha, only: [:create]
    before_action :fetch_account, except: [:create]
    before_action :check_authorization, except: [:create]
  
    rescue_from CustomExceptions::Account::InvalidEmail,
                CustomExceptions::Account::InvalidParams,
                CustomExceptions::Account::UserExists,
                CustomExceptions::Account::UserErrors,
                with: :render_error_response
  
    # Swagger 設定
    swagger_controller :accounts, "Accounts Management"
  
    swagger_path "/api/v1/accounts/{id}" do
      operation :get do
        key :summary, "Get account details"
        key :description, "Fetches details of a specific account"
        key :operationId, "getAccountDetails"
        key :produces, ["application/json"]
        parameter name: :id, in: :path, required: true, type: :integer
        response 200 do
          key :description, "Account details retrieved successfully"
          schema do
            key :'$ref', :Account
          end
        end
        response 401 do
          key :description, "Unauthorized access"
        end
        response 404 do
          key :description, "Account not found"
        end
      end
    end
  
    def show
      @latest_chatwoot_version = ::Redis::Alfred.get(::Redis::Alfred::LATEST_CHATWOOT_VERSION)
      render json: { account: @account, latest_version: @latest_chatwoot_version }, status: :ok
    end
  
    swagger_path "/api/v1/accounts" do
      operation :post do
        key :summary, "Create an account"
        key :description, "Registers a new account"
        key :operationId, "createAccount"
        key :consumes, ["application/json"]
        parameter name: :account, in: :body, required: true, schema: { '$ref' => '#/definitions/AccountCreate' }
        response 201 do
          key :description, "Account created successfully"
          schema do
            key :'$ref', :Account
          end
        end
        response 400 do
          key :description, "Invalid parameters"
        end
      end
    end
  
    def create
      @user, @account = AccountBuilder.new(account_params).perform
      if @user
        send_auth_headers(@user)
        render json: { account: @account, user: @user }, status: :created
      else
        render_error_response(CustomExceptions::Account::SignupFailed.new({}))
      end
    end
  
    def update
      @account.update!(account_params.slice(:name, :locale, :domain, :support_email, :auto_resolve_duration))
      render json: { message: "Account updated successfully", account: @account }, status: :ok
    end
  
    def update_active_at
      @current_account_user.update!(active_at: Time.now.utc)
      head :ok
    end
  
    private
  
    def ensure_account_name
      unless account_params[:account_name].present? && account_params[:user_full_name].present?
        raise CustomExceptions::Account::InvalidParams.new({})
      end
    end
  
    def fetch_account
      @account = current_user.accounts.find(params[:id])
      @current_account_user = @account.account_users.find_by(user_id: current_user.id)
    end
  
    def account_params
      params.permit(:account_name, :email, :name, :password, :locale, :domain, :support_email, :auto_resolve_duration, :user_full_name)
    end
  
    def check_signup_enabled
      raise ActionController::RoutingError, 'Not Found' if GlobalConfigService.load('ENABLE_ACCOUNT_SIGNUP', 'false') == 'false'
    end
  end
  