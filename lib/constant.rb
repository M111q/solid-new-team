#Zawiera stałe wykorzystywane w programie
require_relative '../lib/game.rb'
class Constants #zmieniono
  #$board_size = 15 #zmeinic
  HIT_CHAR = 'X'.freeze
  MISS_CHAR = '-'.freeze
  NO_SHOT_CHAR = '·'.freeze
  HISTORY_LENGTH = 8

  STATES = %i(initialized ready error terminated game_over).freeze

  SHIPS_DEFS = [
    { size: 4, type: 'Battleship' },
    { size: 4, type: 'Battleship' },
    { size: 5, type: 'Aircraft carrier' }
  ].freeze
end

class TypeOfGame
def key_validation(selected_game = ClassicGame)
  game = selected_game.new
  game.key_validation
end
end

class ExtraGame < TypeOfGame
  def key_validation #changeable_size_board_key_validation
    decimal_number = $board_size/10
    digit = $board_size%10
  if $board_size < 10
    /^[A-#{($board_size + 64).chr}]([1-#{$board_size}])$/
  elsif ($board_size >= 10 && $board_size < 27) #pojedyncze litery
    /^([A-#{($board_size + 64).chr}])([1-9]|[1-#{decimal_number}][0-#{digit}])$/
  else #podwojne litery np 30 = 26 + 4 = [A][A - D] = 30 - 26 = 4
    first_letter = ((($board_size / 26.3).to_i) + 64).chr
    second_letter = ((($board_size % 26.3).round) + 64).chr
    /^([A-Z]|[A-#{first_letter}][A-#{second_letter}])([1-9]|[1-#{decimal_number}][0-#{digit}])$/
  end
  end
end

class ClassicGame < TypeOfGame
def key_validation#standard_board_size_key_validation
  /^[A-J]([1-9]|10)$/
end
end
