### solid-new-team


Wykorzystany gem:: [Battleship](https://github.com/szymon33/battleship/)


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
  check = false
  while check == false do
    puts "\nWybierz wersje gry\nA. Gra klasyczna (pole 10x10)\nB. Gra z wyborem pola (Podana wartosc x Podana wartosc)."
    input = gets.chomp.rstrip.upcase
    if input == "A"
      @wybrana_gra = ClassicGame
      check = true
      $board_size = 10
    elsif input == "B"
      @wybrana_gra = ExtraGame
      puts("Podaj długość boku pola do gry")
      $board_size = gets.chomp.to_i
      check = true
    else
      puts "Aby wybrać podaj A lub B"
    end
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
Otwartość kodu została uzyskana dzięki dziedziczeniu.
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
