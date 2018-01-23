# solid-new-team
#### skład grupy:  
#### Kamil Bielski
#### Mikołaj Gierszewski

Wykorzystany gem:: [Battleship](https://github.com/szymon33/battleship/)
oraz [Battleship refaktoryzacja](https://github.com/ood2017/simplicity-M111q)

Battleship – implementacja w języku Ruby popularnej gry w okręty (statki) znaleziony
na Github.com. (/szymon33/battleship)
Aplikacja pozwala na grę dla jednej osoby przeciwko komputerowi, jednak jeszcze nie
daję możliwości rozstawienia własnych statków oraz nie posiada
zaimplementowanego komputerowego przeciwnika próbującego zatopić nasze statki.
Gra kończy się kiedy gracz zatopi wszystkie statki przeciwnika lub poprzez wyjście z
gry przy pomocy komendy 'Q'.

#### Dodana funkcjonalność / zmiana: Wybór wielkości obszaru do gry w statki. 


Zmiany w kodzie dające możliwość (otwartość) wprowadzenia funkcjonalności:  

przed:

```ruby
def control_loop
    ready!
    loop do
      show
      @inputs.push console
      case @command_line
      when 'D' then @debug = !@debug
      when 'Q' then terminate!
      when 'I' then initialize!
      when /^[A-J]([1-9]|10)$/ then shoot
      else @grid_opponent.status_line = "Incorrect input #{@command_line}"
      end
      break if game_over? || terminated? || initialized? || ENV['RACK_ENV'] == 'test'
    end
end
```

po:

Metoda pytająca gracza w jaką wersje statków chce zagrać:
```ruby
  def select_game
    return $board_size = 10, @wybrana_gra = ClassicGame if ENV['RACK_ENV'] == 'test'
    check = false
    while check == false
      puts "\nWybierz wersje gry\nA. Gra klasyczna (pole 10x10)
      \nB. Gra z wyborem pola (Podana wartosc x Podana wartosc)."
      input = gets.chomp.rstrip.upcase
      if input == 'A'
        create_classic_game
        check = true
      elsif input == 'B'
        create_extra_game
        check = true
      else
        puts 'Aby wybrać podaj A lub B'
      end
    end
  end

  def create_extra_game
    @wybrana_gra = ExtraGame
    board_size_validation
  end

  def create_classic_game
    @wybrana_gra = ClassicGame
    $board_size = 10
  end

  def board_size_validation
    $board_size = 1
    while $board_size < 5 || $board_size > 60
      puts('Podaj długość boku pola do gry (z przedzialu 5-60)')
      $board_size = gets.chomp.to_i
    end
  end
```
Extract Method - Wydzielono metodę która określa przyjmowane przez gre komendy ("celowanie") - key_validation
```ruby
def control_loop #zmieniono
    ready!
    input_condition = TypeOfGame.new
    loop do
      show
      @inputs.push console
      case @command_line
      when 'D' then @debug = !@debug
      when 'Q' then terminate!
      when 'I' then initialize!
      when input_condition.key_validation(@wybrana_gra) then shoot
      else @grid_opponent.status_line = "Incorrect input #{@command_line}"
      end
      break if game_over? || terminated? || initialized? || ENV['RACK_ENV'] == 'test'
    end
  end
  ```
Otwartość kodu została uzyskana dzięki polimorfizmowi.
```ruby
class TypeOfGame
def key_validation(selected_game = ClassicGame)
  game = selected_game.new
  game.key_validation
end
end
```
```ruby
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
```
```ruby
class ClassicGame < TypeOfGame
def key_validation#standard_board_size_key_validation
  /^[A-J]([1-9]|10)$/
end
end
```

Kod jest zamknięty na zmiany dzięki klasie TypeOfGame. Aby dopisać nowy typ gry nie musimy edytować naszych klas wystarczy utworzyć nową która bedzię dziedziczyć po klasie TypeOfGame.  

## Tests  
```
bundle install  
bundle exec rspec
```
  
## Play  
```
ruby lib/console.rb
```
