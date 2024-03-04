class Api::V1::Partners::PromptFilesController < ApiPartnerController
  before_action :set_prompt_file, only: %i[destroy]

  def index
    @prompt_files = @current_partner.partner_detail.prompt_files
    render json: PromptFileSerializer.new(@prompt_files).serialized_json, status: :ok
  end

  def create
    partner_detail = @current_partner.partner_detail
    partner_assistent = @current_partner.partner_assistent

    if partner_detail.nil? || partner_assistent.nil?
      return render json: { error: 'Necessario criar as configuracoes do prompt primeiro' },
                    status: :unprocessable_entity
    end

    @prompt_file = PromptFile.new(partner_detail:, partner_assistent:,
                                  open_ai_file_id: prompt_file_params[:open_ai_file_id], file_name: prompt_file_params[:file_name])

    if @prompt_file.save
      render json: PromptFileSerializer.new(@prompt_file).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@prompt_file.errors), status: :unprocessable_entity
    end
  end

  def destroy
    if @prompt_file.destroy
      render json: PromptFileSerializer.new(@prompt_file).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@prompt_file.errors), status: :unprocessable_entity
    end
  end

  private

  def prompt_file_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:prompt_file])
  end

  def set_prompt_file
    @prompt_file = PromptFile.find(params[:id])
  end
end
