class PartnerSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :avatar, :name, :company_name, :email, :service_number, :contact_number, :document, :partner_detail_id, :active, :wpp_connected, :connected_with_google,
             :created_at, :updated_at
  attributes :auth_token, :expires_at, if: proc { |record| record.auth_token.present? }

  attribute :avatar do |object|
    object.avatar.attached? ? object.avatar&.service_url : nil
  end

  attribute :currentPlan do |partner|
    partner.current_plan || 'Nenhum plano ativo'
  end

  attribute :montlyTokensConsumed do |partner|
    partner.montly_tokens_consumed
  end

  attribute :monthlyTokensLeft do |partner|
    partner.montly_remaining_tokens
  end

  attribute :status do |partner|
    partner.customer_status
  end

  attribute :profile_filled do |partner|
    partner.profile_filled?
  end

  attribute :partner_details_filled do |partner|
    partner.partner_details_filled?
  end

  attribute :active_plan do |partner|
    partner.active_plan?
  end

  attribute :connected_with_google do |o|
    o.connected_with_google
  end
end
