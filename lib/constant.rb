#Zawiera stałe wykorzystywane w programie
class Const #zmieniono
  puts("Podaj długość boku pola do gry")
  $board_size = gets.chomp.to_i
  SIZE = $board_size
  $array_of_letters = ('A'..'CV').to_a
  AXE_LETTERS = (($array_of_letters[0]..$array_of_letters[$board_size-1]).to_a).freeze
  AXE_DIGITS = ("1".."#{$board_size}").to_a
  HIT_CHAR = 'X'.freeze
  MISS_CHAR = '-'.freeze
  NO_SHOT_CHAR = '·'.freeze
  HISTORY_LENGTH = 8
end
