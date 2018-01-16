#
# This is code sample how to launch program in console mode
#

# example from readme file, use secret 'D' command to enter debug mode

require_relative '../lib/game.rb'


def welcome

  Grid.row '>> Welcome to Battleship'
  Grid.row
end
Game.new
