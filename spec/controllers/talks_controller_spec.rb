# spec/controllers/talks_controller_spec.rb

require 'rails_helper'

RSpec.describe TalksController, type: :controller do
  describe 'POST #import' do
    it 'imports and organizes talks successfully' do
      file_path = Rails.root.join('TT: 5 - proposals.txt')
      file_data = File.read(file_path)

      allow(File).to receive(:read).with('TT: 5 - proposals.txt').and_return(file_data)

      expect(Business).to receive(:organize_talks).with(file_data).and_call_original
      expect(Talk).to receive(:destroy_all)
      expect(Talk).to receive(:create).exactly(23).times # Ajuste conforme necessário com base no seu caso

      post :import

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq({ message: 'Palestras importadas e organizadas com sucesso' }.to_json)
    end
  end
end
