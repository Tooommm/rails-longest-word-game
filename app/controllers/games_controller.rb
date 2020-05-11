require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = generate_grid(10).join
    @start_time = Time.now
  end

  def score
    grid = params[:grid].split('')
    @attempt = params[:attempt]
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    @result = run_game(@attempt, grid, start_time, end_time)
  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def included?(guess, grid)
    guess.split('').all? { |letter| grid.include? letter }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    time_count = (end_time - start_time).round
    result = { time: time_count }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])
    result
  end

  def score_and_message(attempt, translation, grid, time)
    if translation
      if included?(attempt.upcase, grid)
        score = compute_score(attempt, time).round
        [score, 'well done']
      else
        [0, 'not in the grid']
      end
    else
      [0, 'not an english word']
    end
  end

  def get_translation(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word.downcase}")
    json = JSON.parse(response.read.to_s)
    json
  end
end
