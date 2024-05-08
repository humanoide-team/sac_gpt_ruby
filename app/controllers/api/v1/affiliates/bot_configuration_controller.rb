class Api::V1::Affiliates::BotConfigurationController < ApiAffiliateController

  def copy_from_prospect
    prospect_card = ProspectCard.includes(:prospect_detail).find_by(id: params[:id])
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
    {
      about: prospect_detail.about,
      service: prospect_detail.service,
      persona: prospect_detail.persona,
      name_attendant: prospect_detail.name_attendant,
      company_name: prospect_detail.company_name,
      company_niche: prospect_detail.company_niche,
      served_region: prospect_detail.served_region,
      company_services: prospect_detail.company_services,
      company_products: prospect_detail.company_products,
      company_contact: prospect_detail.company_contact,
      company_objectives: prospect_detail.company_objectives,
      marketing_channels: prospect_detail.marketing_channels,
      key_differentials: prospect_detail.key_differentials,
      tone_voice: prospect_detail.tone_voice,
      preferential_language: prospect_detail.preferential_language,
      catalog_link: prospect_detail.catalog_link,
      token_count: 0
    }
  end
end