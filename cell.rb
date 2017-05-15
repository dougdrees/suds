require "set"

class CellRef
  attr_reader :x, :y

  def initialize(x_val, y_val)
    @x = x_val
    @y = y_val
    self.freeze
  end

  def ==(other)
    self.class === other && other.x == @x && other.y == @y
  end

  alias eql? ==

  def hash
    @x*100+@y
  end

  def to_s
    "(" + @x.to_s + "," + @y.to_s + ")"
  end
end

class Cell
  attr_reader :candidates, :value, :fixed, :ref, :row, :col, :block

  def initialize(reference, row, column, block, max_value=9)
    @ref = reference
    @row = row
    @col = column
    @block = block
    @fixed = false
    @value = nil
    @candidates = Set.new
    (1..max_value).each { |n| @candidates.add(n) }
  end

  def fix(value)
    @value = value
    @fixed = true
    @candidates.clear
    self.freeze
    @row.reduce_fix_count
    @col.reduce_fix_count
    @block.reduce_fix_count
  end

  def mark(value)
    @candidates.delete(value) unless @fixed
  end

  def has_one_candidate?
    @candidates.size == 1
  end

  def get_last_candidate
    if self.has_one_candidate?
      @candidates.to_a[0]
    else
      nil
    end
  end

  def to_s
    output = "#{@ref.to_s}"
    output << "= #{@value.to_s} " if @fixed
    output << "[#{@candidates.to_a.join(",")}] " if !@candidates.empty?
    output << "in (#{@row.to_s}, #{@col.to_s}, #{@block.to_s})"
    output
  end

  def print_candidates
    print " "
    if @fixed
      print "(#{value})"
    else
      @candidates.each { |v| print v}
    end
  end

  def print_ref
    print("#{@ref.to_s} ")
  end
end

class Cell_TestUnit
  attr_reader :name

  def initialize(a_name)
    @name = a_name
  end

  def to_s
    @name
  end
end

if __FILE__ == $0
  # test code

  cell_aRef = CellRef.new(2,3)
  puts cell_aRef.to_s

  cell_aRow = Cell_TestUnit.new("Row")
  cell_aCol = Cell_TestUnit.new("Column")
  cell_aBlk = Cell_TestUnit.new("Block")

  cell_aCell = Cell.new(cell_aRef, cell_aRow, cell_aCol, cell_aBlk)
  cell_aCell.print_ref
  puts
  puts cell_aCell.to_s

  cell_aCell.mark(1)
  cell_aCell.mark(2)
  cell_aCell.mark(3)
  cell_aCell.mark(4)
  puts cell_aCell.to_s
  cell_aCell.mark(6)
  cell_aCell.mark(7)
  cell_aCell.mark(8)
  cell_aCell.mark(9)
  if cell_aCell.has_one_candidate?
    value = cell_aCell.get_last_candidate
    puts value
  end

  cell_aCell.fix(value)
  puts cell_aCell.to_s

  cell_aCell.mark(3)
  puts cell_aCell.to_s
end
