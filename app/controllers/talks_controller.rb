class TalksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:import]

  def index
    @talks = Talk.all

    render json: @talks
  end

  def home

  end

  def import
    # Verifica se o parâmetro 'file' está presente na requisição
    unless params[:file].present? && params[:file].respond_to?(:read)
      render json: { error: 'Arquivo não encontrado na requisição' }, status: :bad_request
      return
    end

    file_data = File.read('TT: 5 - proposals.txt', encoding: 'ISO-8859-1') # Lê o conteúdo do arquivo da requisição
    organized_talks = Business.organize_talks(file_data)

    Talk.destroy_all # Limpa todas as palestras existentes

    organized_talks.each do |talk_data|
      Talk.create(talk_data)
    end

    render json: { message: 'Palestras importadas e organizadas com sucesso' }
  end
end
