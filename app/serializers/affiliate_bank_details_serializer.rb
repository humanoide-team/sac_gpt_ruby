class AffiliateBankDetailsSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :responsible, :document_number, :bank_code, :agency, :account, :account_type, :created_at, :updated_at
end