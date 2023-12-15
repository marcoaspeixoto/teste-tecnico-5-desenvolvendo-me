class TalksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:import]

  def index
    @talks = Talk.all

    respond_to do |format|
      format.html
      format.json { render json: @talks }
    end
  end

  def schedule
    @scheduled_talks = Talk.order(:day, :start_time)
  end

  def home
    @import_success_message = flash[:import_success_message]
  end

  def import
    # Verifica se o parâmetro 'file' está presente na requisição
    unless params[:file].present? && params[:file].respond_to?(:read)
      respond_to do |format|
        format.html do
          render plain: 'Arquivo não encontrado na requisição', status: :bad_request
        end
        format.json do
          render json: { error: 'Arquivo não encontrado na requisição' }, status: :bad_request
        end
      end
      return
    end

    file_data = params[:file].read.encode('UTF-8', 'ISO-8859-1') # Lê o conteúdo do arquivo da requisição
    organized_talks = Business.organize_talks(file_data)

    Talk.destroy_all # Limpa todas as palestras existentes

    organized_talks.each do |talk_data|
      Talk.create(talk_data)
    end

    flash[:import_success_message] = 'Palestras importadas e organizadas com sucesso'

    respond_to do |format|
      format.html do
        redirect_to root_path
      end
      format.json do
        render json: { message: 'Palestras importadas e organizadas com sucesso' }
      end
    end
  end
end
