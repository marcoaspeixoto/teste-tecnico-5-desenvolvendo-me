class TalksController < ApplicationController
  before_action :set_talk, only: [:show, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:import_from_txt]

  def index
    @talks = Talk.all
    render json: @talks
  end

  def show
    render json: @talk
  end

  def create
    @talk = Talk.new(talk_params)

    if @talk.save
      render json: @talk, status: :created
    else
      render json: @talk.errors, status: :unprocessable_entity
    end
  end

  def update
    if @talk.update(talk_params)
      render json: @talk
    else
      render json: @talk.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @talk.destroy
  end

  private

  def import_from_txt
    file_path = 'TT: 5 - proposals.txt'

    File.open(file_path, 'r').each_line do |line|
      # Use uma expressão regular para identificar linhas com "lightning" no final
      if line =~ /^(.+?) (\d+)min$|(.*?)lightning$/
        name = Regexp.last_match(1) || Regexp.last_match(3)
        duration = Regexp.last_match(2) || 5

        # Crie um novo registro no banco de dados
        Talk.create(name: name.strip, duration: duration.to_i)
      end
    end

    redirect_to talks_path, notice: 'Importação concluída com sucesso.'
  end

  def set_talk
    @talk = Talk.find(params[:id])
  end

  def talk_params
    params.require(:talk).permit(:name, :duration)
  end
end
