class Api::V1::Admins::PartnersController < ApiAdminController
  before_action :set_partner, only: %i[show]

  def index
    @partners = Partner.all
    render json: CleanerSerializer.new(@partners).serialized_json
  end

  def show
    render json: CleanerSerializer.new(@partner).serialized_json
  end

  private

  def cleaner_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:cleaner, :cities, :regions])
  end

  def supervisor_note_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:supervisor_note])
  end

  def set_partner
    @partner = Partner.find(params[:id])
  end
end
