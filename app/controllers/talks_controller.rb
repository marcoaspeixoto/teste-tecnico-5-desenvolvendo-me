class TalksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:import]

  def index
    @talks = Talk.all

    render json: @talks
  end

  def import
    file_data = File.read('TT: 5 - proposals.txt') # Lê o conteúdo do arquivo
    organized_talks = organize_talks(file_data)

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

  private

  def organize_talks(file_data)
    organized_talks_day_a = []
    organized_talks_day_b = []
    current_time_day_a = Time.new(Time.now.year, Time.now.month, Time.now.day, 9, 0) # Começa às 9h no Dia A
    current_time_day_b = Time.new(Time.now.year, Time.now.month, Time.now.day, 9, 0) # Começa às 9h no Dia B

    file_data.each_line do |line|
      next if line.strip.empty? # Ignora linhas em branco

      match_data = line.match(/^(.+?) (\d+min|lightning)$/)

      if match_data
        name, duration = match_data.captures

        if duration == 'lightning'
          duration_minutes = 5
        else
          duration_minutes = duration.to_i
        end

        if current_time_day_a < Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 0)
          organized_talks_day_a << { name: name, duration: duration_minutes, day: 'Dia A', start_time: current_time_day_a }
          current_time_day_a += duration_minutes * 60
        elsif current_time_day_b < Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 0)
          organized_talks_day_b << { name: name, duration: duration_minutes, day: 'Dia B', start_time: current_time_day_b }
          current_time_day_b += duration_minutes * 60
        end
      else
        # Lidar com linhas que não correspondem ao padrão esperado
        # Por exemplo, você pode registrar essas linhas em um arquivo de log ou tratá-las de outra forma adequada
      end
    end

    # Adiciona o evento de almoço no meio do dia
    lunch_start_time_day_a = Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 0)
    lunch_start_time_day_b = Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 0)

    organized_talks_day_a << { name: 'Almoço', duration: 60, day: 'Dia A', start_time: lunch_start_time_day_a }
    organized_talks_day_b << { name: 'Almoço', duration: 60, day: 'Dia B', start_time: lunch_start_time_day_b }

    current_time_day_a = lunch_start_time_day_a + 60 * 60 # Continue após o almoço no Dia A
    current_time_day_b = lunch_start_time_day_b + 60 * 60 # Continue após o almoço no Dia B

    # Adiciona o evento de networking no final da tarde do Dia A
    networking_start_time_day_a = [current_time_day_a, Time.new(Time.now.year, Time.now.month, Time.now.day, 16, 0)].max

    organized_talks_day_a << { name: 'Evento de Networking', duration: 60, day: 'Dia A', start_time: networking_start_time_day_a }

    # Adiciona o evento de networking no final da tarde do Dia B
    networking_start_time_day_b = [current_time_day_b, Time.new(Time.now.year, Time.now.month, Time.now.day, 16, 0)].max

    organized_talks_day_b << { name: 'Evento de Networking', duration: 60, day: 'Dia B', start_time: networking_start_time_day_b }

    organized_talks_day_a + organized_talks_day_b
  end
end
