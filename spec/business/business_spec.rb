require 'rails_helper'

RSpec.describe Business, type: :model do
  describe '#organize_talks' do
    it 'organizes talks correctly' do
      file_data = "Talk 1 30min\nTalk 2 45min\n"

      organized_talks = Business.organize_talks(file_data)

      # Verifica se as palestras foram organizadas corretamente
      expect(organized_talks).to eq([
                                      { name: 'Talk 1', duration: 30, day: 'A', start_time:
                                        Time.new(Time.now.year, Time.now.month, Time.now.day, 9, 0) },
                                      { name: 'Talk 2', duration: 45, day: 'A', start_time:
                                        Time.new(Time.now.year, Time.now.month, Time.now.day, 9, 30) }
                                    ])
    end
  end
end
