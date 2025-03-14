class DashboardController < ApplicationController
  def index
    account_id = params[:account_id] # URL から `:account_id` を取得

    render json: {
      message: "Twitter Inbox 設定ページ",
      account_id: account_id
    }
  end
end
