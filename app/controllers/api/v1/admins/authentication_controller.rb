class Api::V1::Admins::AuthenticationController < ApiAdminController
  skip_before_action :authenticate_request

  def authenticate
    options = {
      email: params[:email],
      password: params[:password],
      expires_at: 7.days.from_now
    }
    command = AuthenticateAdmin.call(options)

    if command.success?
      admin = command.current_admin
      admin.auth_token = command.result
      admin.expires_at = options[:expires_at]

      render json: AdminSerializer.new(admin).serialized_json
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end

  def current_admin
    @current_admin ||= current_user
  end
end
