class TalksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:import]

  def index
    @talks = Talk.all

    render json: @talks
  end

  def import
    file_data = File.read('TT: 5 - proposals.txt') # Lê o conteúdo do arquivo
    organized_talks = Business.organize_talks(file_data)

    Talk.destroy_all # Limpa todas as palestras existentes

    organized_talks.each do |talk_data|
      Talk.create(
        name: talk_data[:name],
        duration: talk_data[:duration],
        day: talk_data[:day],
        start_time: talk_data[:start_time]
      )
    end

    render json: { message: 'Palestras importadas e organizadas com sucesso' }
  end
end
