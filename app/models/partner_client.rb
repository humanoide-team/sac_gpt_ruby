class PartnerClient < ApplicationRecord

  belongs_to :partner
  has_one :conversation_thread, dependent: :destroy
  has_many :partner_client_messages, dependent: :destroy
  has_many :partner_client_leads, dependent: :destroy
  has_many :partner_client_conversation_infos, dependent: :destroy
  has_many :schedules, dependent: :destroy
end

# rails g model PartnerAssistent open_ai_assistent_id:string partner:references

# rails g model PromptFile open_ai_file_id:string partner_detail:references partner_assistent:references

# rails g model ConversationThread open_ai_thread_id:string partner:references partner_client:references partner_assistent:references

# rails g migration addFieldPartnerIdToPartnerClient partner:references

# rails g migration addFieldConversationThreadIdToPartnerClientMessage conversation_thread:references
