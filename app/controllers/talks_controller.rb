class TalksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:import]
  before_action :set_talk, only: [:show, :update, :destroy]

  def index
    @talks = Talk.all

    render json: @talks
  end

  def import
    file_data = File.read('TT: 5 - proposals.txt') # Lê o conteúdo do arquivo
    organized_talks = Business.organize_talks(file_data)

    Talk.destroy_all # Limpa todas as palestras existentes

    organized_talks.each do |talk_data|
      Talk.create(talk_data)
    end

    render json: { message: 'Palestras importadas e organizadas com sucesso' }
  end
end
