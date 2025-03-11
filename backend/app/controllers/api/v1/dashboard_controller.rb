class Api::V1::DashboardController < ApplicationController
    def index
        render json: {message:"ダッシュボードへようこそ！", status:200}
    end
end
