class PartnerSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name, :email, :service_number, :contact_number, :document, :partner_detail_id, :active, :created_at, :updated_at
  attributes :auth_token, :expires_at, if: Proc.new { |record| record.auth_token.present? }

  attribute :currentPlan do |partner|
    partner.current_plan || 'Nenhum plano ativo'
  end

  attribute :montlyTokensConsumed do |partner|
    partner.current_mothly_history.token_count
  end

  attribute :monthlyTokensLeft do |partner|
    token_limit = partner.current_plan&.max_token_count || 0
    token_limit - partner.current_mothly_history.token_count
  end

  attribute :status do |partner|
    partner.customer_status
  end

end