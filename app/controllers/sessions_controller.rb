class SessionsController < ApplicationController
  def create
    user_data = request.env['omniauth.auth']
    session[:token] = user_data['credentials']['token']

    @partner = Partner.find(params['partnerId'])

    unless @partner.nil?
      @partner.access_token = user_data.credentials.token
      @partner.expires_at = user_data.credentials.expires_at
      @partner.refresh_token = user_data.credentials.refresh_token
      @partner.save!

      return render json: { message: 'Conta conectada' }, status: 200
    end
    render json: { error: 'Usuário não existe' }, status: 401
  end
end