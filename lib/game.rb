require_relative '../lib/grid.rb'
require_relative '../lib/ship.rb'
require_relative '../lib/constant.rb'
# Game class. Main program class.
class Game < Const
  attr_reader :state

  STATES = %i(initialized ready error terminated game_over).freeze

  SHIPS_DEFS = [
    { size: 4, type: 'Battleship' },
    { size: 4, type: 'Battleship' },
    { size: 5, type: 'Aircraft carrier' }
  ].freeze

  STATES.each { |state| define_method("#{state}?") { @state == state } }

  def initialize

    @state = :initialized
    @command_line = nil
    @shots = Array.new
    @inputs = Array.new
    @fleet = Array.new
    play
  end

  def play
    loop do
      @matrix = Array.new(Grid::SIZE) { Array.new(Grid::SIZE, ' ') }
      @matrix_opponent = Array.new(Grid::SIZE) { Array.new(Grid::SIZE, Grid::NO_SHOT_CHAR) }
      @grid_opponent = Grid.new(@matrix_opponent, @inputs)
      @hits_counter = 0
      @debug = false
      create_fleet! && control_loop
      break if !initialized? || ENV['RACK_ENV'] == 'test'
    end
    self
  end

  def control_loop #zmieniono
    ready!
    loop do
      show
      @inputs.push console
      case @command_line
      when 'D' then @debug = !@debug
      when 'Q' then terminate!
      when 'I' then initialize!
      when key_validation then shoot
      else @grid_opponent.status_line = "Incorrect input #{@command_line}"
      end
      break if game_over? || terminated? || initialized? || ENV['RACK_ENV'] == 'test'
    end
  end

def key_validation #stworzono
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


  def show
    @grid_opponent.show
    #print (@shots) #do sprawdzania
    if @debug
      @grid = Grid.new(@matrix, @inputs, @fleet)
      @grid.status_line = 'DEBUG MODE'
      @grid.debug
    end
  end

  # just some user input validations_line
  def <<(str)
    return unless str
    @command_line = str.upcase
  end



  private

  def create_fleet!
    @fleet = Array.new
    SHIPS_DEFS.each do |ship_definition|
      ship = Ship.new(@matrix, ship_definition).build
      @fleet.push ship
      @hits_counter += ship_definition.fetch(:size) # need for game over check
      ship.location.each { |coordinates| @matrix[coordinates[0]][coordinates[1]] = true }
    end
  end



  def console
    return nil if ENV['RACK_ENV'] == 'test'
    self << [(print 'Enter coordinates (row, col), e.g. A5 (I - initialize, Q to quit): '), gets.rstrip][1]
  end

  def shoot
    return unless xy = convert(@command_line)
    if @shots.include? xy
      @grid_opponent.status_line = 'You repeat yourself'
      return
    end
    @shots.push xy
    mark_shoot xy
  end

  def mark_shoot(xy)
    @matrix_opponent[xy[0]][xy[1]] = Grid::MISS_CHAR
    @grid_opponent.status_line = 'Sorry, you missed'
    @fleet.each do |ship|
      if ship.location.include? xy
        @matrix_opponent[xy[0]][xy[1]] = Grid::HIT_CHAR
        hit(ship) && break
      end
    end
  end

  def hit(ship)
    @hits_counter -= 1
    if fleet_detroyed?
      game_over!
    elsif (ship.location - @shots).empty?
      @grid_opponent.status_line = "You sank my #{ship.type}!"
    else
      @grid_opponent.status_line = 'HIT!'
    end
  end

  def fleet_detroyed?
    @hits_counter.zero?
  end

  def convert(format_a1) ##zmieniono
    return unless format_a1
    if (format_a1[1] =~ /[[:alpha:]]/) == 0
    x = format_a1[0..1]
    y = format_a1[2..-1]
    else
    x = format_a1[0]
    y = format_a1[1..-1]
  end
    if (format_a1[1] =~ /[[:alpha:]]/) == 0
[((x[0].ord - 64)*26-1 + (x[1].ord - 64)) ,y.to_i - 1]
    else
    [x.ord - 65, y.to_i - 1]
  end
  end



  def ready!
    @state = :ready
    @grid_opponent.status_line = @state.to_s
  end

  def initialize!
    @state = :initialized
    @grid_opponent.status_line = 'Initialized'
  end

  def terminate!
    @state = :terminated
    @grid_opponent.status_line =
      "Terminated by user after #{@shots.size} shots!"
    show
  end

  def game_over!
    @state = :game_over
    @grid_opponent.status_line =
      "Well done! You completed the game in #{@shots.size} shots"
    show
  end
end
