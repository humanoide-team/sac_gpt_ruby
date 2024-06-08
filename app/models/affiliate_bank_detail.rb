class AffiliateBankDetail < ApplicationRecord
  belongs_to :affiliate

  enum account_type: {
    conta_corrente: 0,
    conta_poupanca: 1,
    conta_corrente_conjunta: 2,
    conta_poupanca_conjunta: 3
  }

  validates :responsible, :document_number, :bank_code, :agency, :account, :account_type, presence: true
end
