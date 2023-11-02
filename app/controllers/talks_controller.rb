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

  def set_talk
    @talk = Talk.find(params[:id])
  end

  def talk_params
    params.require(:talk).permit(:name, :duration)
  end
end
