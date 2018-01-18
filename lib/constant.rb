#Zawiera stałe wykorzystywane w programie
class Const
  puts("Podaj długość boku pola do gry")
  $bok = gets.chomp.to_i
  SIZE = $bok
  literky = ('A'..'CV').to_a
  AXE_LETTERS = ((literky[0]..literky[$bok-1]).to_a).freeze
  AXE_DIGITS = ("1".."#{$bok}").to_a
  #SIZE = 10
  #AXE_LETTERS = %w( A B C D E F G H I J ).freeze
  #AXE_DIGITS = %w( 1 2 3 4 5 6 7 8 9 10 ).freeze
  HIT_CHAR = 'X'.freeze
  MISS_CHAR = '-'.freeze
  NO_SHOT_CHAR = '·'.freeze
  HISTORY_LENGTH = 8
end
