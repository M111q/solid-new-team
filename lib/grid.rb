require_relative '../lib/constant.rb'

# Grid class
class Grid < Const
attr_reader :status_line

def initialize(matrix, inputs, fleet = nil)
  @status_line = :initialized
  @matrix = matrix
  @inputs = inputs
  @fleet = fleet
end

def status_line=(val)
  @status_line = val
end

def show
  (system('clear') || system('cls')) unless ENV['RACK_ENV'] == 'test'
  welcome
  status
  board
  history
end

def debug
  Grid.row 'DEBUG MODE'
  setup_with_fleet if @fleet
  board
  Grid.row
end

# separate presentation layer
def self.row(txt = nil)
  txt ? puts(txt) : puts('')
end

  private

def status
  Grid.row status_line
  Grid.row
end
# :reek:DuplicateMethodCall { max_calls: 2 }

def digits_writer
  minilacznik = "  "
  lacznik = "   "
  print("      ")
  AXE_DIGITS.each do | a |
    if a.to_i < 10
       print ("#{a}#{lacznik}")
       else
         print ("#{a}#{minilacznik}")
     end
   end
end


def board
  Grid.row
  #Grid.row '       ' + AXE_DIGITS.join(lacznik)
  digits_writer
    Grid.row
  @matrix.each_with_index do |grow, index|
    if index <26
    Grid.row(" #{AXE_LETTERS[index]}   #{grow.join(' ')}  #{AXE_LETTERS[index]}")
  else
    Grid.row(" #{AXE_LETTERS[index]}  #{grow.join(' ')}  #{AXE_LETTERS[index]}")
  end
end
  digits_writer
#  Grid.row '    ' + AXE_DIGITS.join(' ')
end

def history
  puts ''
  Grid.row input_tail.join(' ')
  Grid.row
end

def input_tail
  if not_longer
    adding_move_to_history
  else @inputs
  end
end

def adding_move_to_history
  trimed_input = ['..']
  trimed_input.push(*@inputs[(@inputs.length - HISTORY_LENGTH)..-1])
end

def not_longer
  @inputs.length > HISTORY_LENGTH
end

def setup_with_fleet
  if @fleet
    @fleet.each do |ship|
      insert_hit_char(ship)
    end
  end
  @matrix
end

def insert_hit_char(ship)
  ship.location.each { |coordinates| @matrix[coordinates.first][coordinates[1]] = HIT_CHAR } # TO DO
end
end
