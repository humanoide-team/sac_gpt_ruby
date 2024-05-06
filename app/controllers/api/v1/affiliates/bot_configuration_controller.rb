class Api::V1::Affiliates::BotConfigurationController < ApiAffiliateController
  skip_before_action :authenticate_request, only: %i[copy_from_prospect]


  def copy_from_prospect
    prospect_card = ProspectCard.includes(:prospect_detail).find_by(id: params[:prospect_card_id])
    if prospect_card.nil?
      render json: { error: "Prospect card not found" }, status: :not_found
      return
    end

    if prospect_card.prospect_detail.nil?
      render json: { error: "No details available for this prospect card." }, status: :not_found
      return
    end

    bot_config = BotConfiguration.new(bot_config_params(prospect_card.prospect_detail))
    bot_config.affiliate_id = prospect_card.affiliate_id

    if bot_config.save
      render json: bot_config, status: :created
    else
      render json: { errors: bot_config.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def bot_config_params(prospect_detail)
    deserialized_data = ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [
      :about, :service, :persona, :name_attendant, :company_name, :company_niche,
      :served_region, :company_services, :company_products, :company_contact,
      :company_objectives, :marketing_channels, :key_differentials,
      :tone_voice, :preferential_language, :catalog_link
    ])
    deserialized_data.merge(token_count: 0)
  end
end