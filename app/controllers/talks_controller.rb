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
          if current_time_day_a + duration_minutes * 60 <= Time.new(Time.now.year, Time.now.month, Time.now.day, 13, 0)
            organized_talks_day_a << { name: name, duration: duration_minutes, day: 'Dia A', start_time: current_time_day_a }
            current_time_day_a += duration_minutes * 60
          else
            # Adiciona o almoço
            organized_talks_day_a << { name: 'Almoço', duration: 60, day: 'Dia A', start_time: current_time_day_a }
            current_time_day_a = Time.new(Time.now.year, Time.now.month, Time.now.day, 13, 0) # Inicia a tarde às 13h
          end
        elsif current_time_day_a < Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 0)
          # Verifica se a próxima palestra cabe no tempo restante do dia atual antes das 17h
          if current_time_day_a + duration_minutes * 60 <= Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 0)
            organized_talks_day_a << { name: name, duration: duration_minutes, day: 'Dia A', start_time: current_time_day_a }
            current_time_day_a += duration_minutes * 60
          else
            # Adiciona o evento de networking
            organized_talks_day_a << { name: 'Evento de Networking', duration: 60, day: 'Dia A', start_time: current_time_day_a }
            current_time_day_a = Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 0) # Inicia o networking entre 16h e 17h
          end
        end

      else
        # Lidar com linhas que não correspondem ao padrão esperado
        # Por exemplo, você pode registrar essas linhas em um arquivo de log ou tratá-las de outra forma adequada
      end
    end

    organized_talks_day_a
  end
end
