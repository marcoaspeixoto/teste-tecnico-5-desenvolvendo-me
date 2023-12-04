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
    organized_talks = []
    current_time = Time.new(Time.now.year, Time.now.month, Time.now.day, 9, 0)
    day = 'A'

    file_data.each_line.with_index do |line, index|
      last_line = index == file_data.each_line.count - 1

      next if line.strip.empty?

      match_data = line.match(/^(.+?) (\d+min|lightning)$/)

      if match_data
        name, duration = match_data.captures

        if duration == 'lightning'
          duration_minutes = 5
        else
          duration_minutes = duration.to_i
        end

        if current_time <= Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 0)
          if current_time + duration_minutes * 60 <= Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 0)
            organized_talks << { name: name, duration: duration_minutes, day: "#{day}", start_time: current_time }
            current_time += duration_minutes * 60
          else
            # Adiciona o almoço
            organized_talks << { name: 'Almoço', duration: 60, day: "#{day}",
                                       start_time: Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 0) }
            current_time = Time.new(Time.now.year, Time.now.month, Time.now.day, 13, 0) # Inicia a tarde às 13h
            # Adiciona a palestra após o almoço
            organized_talks << { name: name, duration: duration_minutes, day: "#{day}", start_time: current_time}
            current_time += duration_minutes * 60
          end
        elsif current_time < Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 0)
          # Verifica se a próxima palestra cabe no tempo restante do dia atual antes das 17h
          if current_time + duration_minutes * 60 <= Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 0)
            organized_talks << { name: name, duration: duration_minutes, day: "#{day}", start_time: current_time }
            current_time += duration_minutes * 60
            if last_line
              organized_talks << { name: 'Evento de Networking', duration: 60, day: "#{day}", start_time: current_time }
            end
          else
            # Adiciona o evento de networking
            organized_talks << { name: 'Evento de Networking', duration: 60, day: "#{day}", start_time: current_time }
            # Adiciona palestra no dia seguinte
            day.next!
            current_time = Time.new(Time.now.year, Time.now.month, Time.now.day, 9, 0) # Começa às 9h no Dia A
            organized_talks << { name: name, duration: duration_minutes, day: "#{day}", start_time: current_time }
            current_time += duration_minutes * 60
          end
        end

      else
        # Lidar com linhas que não correspondem ao padrão esperado
        # Por exemplo, você pode registrar essas linhas em um arquivo de log ou tratá-las de outra forma adequada
      end
    end

    organized_talks
  end
end
