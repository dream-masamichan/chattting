class DeviseOverrides::ConfirmationsController < Devise::ConfirmationsController
    include AuthHelper
    skip_before_action :require_no_authentication, raise: false
    skip_before_action :authenticate_user!, raise: false

    def create
        @confirmable = User.confirm_by_token(params[:confirmation_token])

        if @confirmation.errors.empty?
            render_confirmation_success
        else
            render_confirmation_error(@confirmation)
        end
    end

    private

    def render_confirmation_success
        if @confirmable.confirmed?
            send_auth_headers(@confirmable)
            render json: {message: "無事にメール確認できました", user: @confirmable}, status: :ok
        else
            render json: {"確認が取れませんでした", errors: @confirmable.errors.full_message}, status: :unprocessable_entity
        end
    end
end



