require "json"
require_relative "grid"
require_relative "unit"
require_relative "cell"
require_relative "algorithms"

class Puzzle
  attr_reader :def, :block, :width, :height, :max_value, :grid, :num
  
  def initialize(file)
    @puzzle_def = JSON.load(file)
    @puzzle_block = @puzzle_def["puzzle"]
    @width = @puzzle_block["width"]
    @height = @puzzle_block["height"]
    @max_value = @width  # Assumes square puzzle with square blocks
    puts "#{@width}:#{@height}"
    @grid = Grid.new(@width, @height)
    # @grid.print_grid
    grid_ary = @puzzle_block["rows"]
    @num = @puzzle_block["number"]
    row_data = nil
    (0..@height - 1).each do |y|
      row_data = Array.new(grid_ary[y])
      # puts row_data.to_s
      initial_len = row_data.length
      (0..@width - 1).each do |x|
        n = row_data[x]
        # puts "#{x},#{y}=#{n}"
        @grid.add_ref_to_queue(x, y, n) if n > 0
      end
    end
    @algorithms = Algorithms.new(@grid)
  end
  
  def print_original_puzzle
    puts "Websudoku puzzle number = #{@num}."
    puts "Dimensions of grid: #{width}X#{height}"
    grid_ary = @puzzle_block["rows"]
    (0..@height - 1).each do |row|
      puts "  -------------------"
      print "  "
      (0..@width - 1).each do |cell|
        print "|#{grid_ary[row][cell]}" if grid_ary[row][cell] > 0
        print "| "                      if grid_ary[row][cell] == 0
      end
      puts "|"
    end
  end

  def solve
    start_count = @grid.un_fixed_count
    @grid.process_queue
    end_count = @grid.un_fixed_count
    # puts "Start=#{start_count}; End=#{end_count}"
    while start_count != end_count && end_count != 0
      start_count = @grid.un_fixed_count
      @grid.foreach_unit { |unit| @algorithms.find_singular_value(unit, @max_value) }
      @grid.process_queue
      # puts "Count=#{@grid.un_fixed_count}"
      @grid.foreach_unit { |unit| @algorithms.find_pair(unit) }
      @grid.process_queue
      end_count = @grid.un_fixed_count
      # puts "Start=#{start_count}; End=#{end_count}"
    end
  end

  def print_puzzle
    @grid.print_grid
  end
end

##############################################
if ARGV.length > 0
  filename = ARGV.at(0).chomp
else
  filename = "puzzle1.json"
end

$infile = File.open(filename, "r")

$puzzle = Puzzle.new($infile)

$puzzle.print_original_puzzle

$puzzle.solve

$puzzle.print_puzzle
