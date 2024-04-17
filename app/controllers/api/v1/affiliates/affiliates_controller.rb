class Api::V1::Affiliates::AffiliatesController < ApiAffiliateController
  before_action :set_affiliate, only: %i[show destroy update]
  skip_before_action :authenticate_request, only: %i[create]

  def show
    render json: AffiliateSerializer.new(@affiliate).serialized_json
  end

  def create
    @affiliate = Affiliate.new(affiliate_params)

    if @affiliate.save
      options = {
        email: affiliate_params[:email],
        password: affiliate_params[:password],
        expires_at: 7.days.from_now
      }

      command = AuthenticateAffiliate.call(options)

      if command.success?
        affiliate = command.current_affiliate
        affiliate.auth_token = command.result
        affiliate.expires_at = options[:expires_at]
      end

      render json: AffiliateSerializer.new(affiliate).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@affiliate.errors), status: :unprocessable_entity
    end
  end

  def destroy
    if @affiliate.destroy
      render json: AffiliateSerializer.new(@affiliate).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@affiliate.errors), status: :unprocessable_entity
    end
  end

  def update
    if @affiliate.update(affiliate_params)
      render json: AffiliateSerializer.new(@affiliate).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@affiliate.errors), status: :unprocessable_entity
    end
  end

  private

  def affiliate_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:affiliate])
  end

  def set_affiliate
    @affiliate = @current_affiliate
  end
end
