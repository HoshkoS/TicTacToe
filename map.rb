
class Map
  attr_reader :id

  def initialize(id)
    @id = id
    @data = Array.new(3) { Array.new(3, 0) }
  end

  def [](x, y)
    @data[x][y]
  end

  def []=(x, y, value)
    @data[x][y] = value
  end

  def dot_empty?(dot)
    @data[(dot.to_i-1)/3][(dot.to_i-1)%3].zero?
  end

  def output
    (0..2).each do |i|
      (0..2).each do |j|
        print "#{@data[i][j]} "
      end
      print "\n"
    end
  end

  def check_game_status
    (0..2).each do |i|
      return 'Crosses won!' if @data[0][i] == 1 && @data[1][i] == 1 && @data[2][i] == 1
      return 'Noughts won!' if @data[0][i] == 2 && @data[1][i] == 2 && @data[2][i] == 2
      return 'Noughts won!' if @data[i][0] == 2 && @data[i][1] == 2 && @data[i][2] == 2
      return 'Crosses won!' if @data[i][0] == 1 && @data[i][1] == 1 && @data[i][2] == 1
    end

    return 'Crosses won!' if @data[0][0] == 1 && @data[1][1] == 1 && @data[2][2] == 1
    return 'Noughts won!' if @data[0][0] == 2 && @data[1][1] == 2 && @data[2][2] == 2
    return 'Crosses won!' if @data[0][2] == 1 && @data[1][1] == 1 && @data[2][0] == 1
    return 'Noughts won!' if @data[0][2] == 2 && @data[1][1] == 2 && @data[2][0] == 2

    (0..2).each do |i|
      (0..2).each do |j|
        return 'Game continue...' if @data[i][j].zero?
      end
    end
    'No space'
  end
end
