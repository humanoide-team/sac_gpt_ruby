class PasswordsController < ActionController::Base
  layout 'password'

  def update
    @resource = if params[:resource] == 'admin'
      Admin.find_by(email: params[:email], reset_password_token: params[:reset_password_token])
    else
      Partner.find_by(email: params[:email], reset_password_token: params[:reset_password_token])
    end

    if params[:password] == params[:password_confirmation]
      if @resource && @resource.send(resource_update_method, password_resource_params)
        @resource.allow_password_change = false
        return redirect_to 'https://test.app/' #alterar o link
      elsif @resource
        @error_message = 'Erro ao alterar a senha'
      else
        @error_message = 'Token inválido'
      end
    else
      @error_message = 'Senha e confirmação de senha não são iguais'
    end

    render :edit
  end

  protected

  def resource_update_method
    if (DeviseTokenAuth.check_current_password_before_update == false) || (@resource.allow_password_change == true)
      'update_attributes'
    else
      'update_with_password'
    end
  end

  def password_resource_params
    params.permit(:password, :password_confirmation)
  end
end
