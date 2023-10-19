class SessionsController < ApplicationController
  def create
    user_data = request.env['omniauth.auth']
    session[:token] = user_data['credentials']['token']

    @partner = Partner.find_by(email: auth.info.email)

    unless @partner.nil?
      @partner.update(calendar_token: session[:token])

      return render json: { error: 'Conta conectada' }, status: 200
    end
    render json: { error: 'Usuário não existe' }, status: 401
  end
end