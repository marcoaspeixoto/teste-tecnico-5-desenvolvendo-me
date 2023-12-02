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

    organized_talks.each do |day, talks|
      talks.each do |talk_data|
        Talk.create(
          name: talk_data[:name],
          duration: talk_data[:duration],
          day: talk_data[:day],
          start_time: talk_data[:start_time]
        )
      end
    end

    render json: { message: 'Palestras importadas e organizadas com sucesso' }
  end

  private

  def organize_talks(file_data)
    organized_talks_by_day = initialize_organized_talks_by_day
    current_time_by_day = initialize_current_times

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

        day = current_time_by_day.keys.find { |d| current_time_by_day[d][:time] <= Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 0) }

        if current_time_by_day[day][:time] + duration_minutes * 60 <= Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 0)
          organized_talks_by_day[day] << { name: name, duration: duration_minutes, day: "Dia #{day}", start_time: current_time_by_day[day][:time] }
          current_time_by_day[day][:time] += duration_minutes * 60
        else
          organized_talks_by_day[day] << { name: 'Almoço', duration: 60, day: "Dia #{day}", start_time: Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 0) }
          current_time_by_day[day][:time] = Time.new(Time.now.year, Time.now.month, Time.now.day, 13, 0)
          organized_talks_by_day[day] << { name: name, duration: duration_minutes, day: "Dia #{day}", start_time: current_time_by_day[day][:time] }
          current_time_by_day[day][:time] += duration_minutes * 60
        end

        # Adiciona evento de networking se for a última linha
        if last_line
          day = current_time_by_day.keys.find { |d| current_time_by_day[d][:time] < Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 0) }
          organized_talks_by_day[day] << { name: 'Evento de Networking', duration: 60, day: "Dia #{day}", start_time: current_time_by_day[day][:time] }
        end
      else
        # Lidar com linhas que não correspondem ao padrão esperado
        # Por exemplo, você pode registrar essas linhas em um arquivo de log ou tratá-las de outra forma adequada
      end
    end

    organized_talks_by_day.values.flatten
  end

  def initialize_current_times
    { time: Time.new(Time.now.year, Time.now.month, Time.now.day, 9, 0), letter: 'A' }
  end

  def next_day(day)
    (day.ord + 1).chr
  end

end
