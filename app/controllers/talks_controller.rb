class TalksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:import]

  def index
    @talks = Talk.all

    render json: @talks
  end

  def import
    file_path = File.expand_path('TT: 5 - proposals.txt', Rails.root) # Caminho para o arquivo na pasta raiz

    if File.exist?(file_path)
      file_data = File.read(file_path)
      organized_talks = organize_talks(file_data)

      # Salvar as palestras organizadas no banco de dados
      Talk.delete_all # Limpa as palestras existentes, se houver

      lines = file_data.split("\n")
      lines.each do |line|
        match_data = line.match(/^(.+?) (\d+min|lightning)$/)
        if match_data
          name, duration = match_data.captures
          Talk.create(name: name, duration: duration, day: nil) # Substitua nil pelo dia correto
        else
          # Lidar com linhas que não correspondem à expressão regular, se necessário
        end
      end

      render json: { message: 'Palestras importadas e organizadas com sucesso' }
    else
      render json: { error: 'Arquivo não encontrado' }, status: :not_found
    end
  end

  private

  def organize_talks(file_data)
    # Implemente a organização das palestras a partir dos dados do arquivo
  end
end
