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
  attr_reader :candidates, :value, :fixed, :ref, :row, :col, :block, :max_value
  attr_writer :value, :fixed

  def initialize(reference, block, max=9)
    @ref = reference
    @row = reference.y
    @col = reference.x
    @block = block
    @fixed = false
    @value = nil
    @max_value = max
    @candidates = Set.new
    (1..max).each { |n| @candidates.add(n) }
  end
  
  def clone()
    cln = Cell.new(self.ref, self.block, self.max_value)
    cln.candidates.clear
    cln.fixed = @fixed
    cln.value = @value
    @candidates.each{ |n| cln.candidates.add(n) }
    cln.freeze if @fixed
    cln
  end
  
  def isEqual?(other)
    false if @ref != other.ref
    false if @row != other.row
    false if @col != other.col
    false if @block != other.block
    false if @fixed != other.fixed
    false if @value != other.value
    false if @max_value != other.max_value
    @candidates.each { |n| false if !other.candidates.include?(n) }
    true
  end

  def fix(value)
    @value = value
    @fixed = true
    @candidates.clear
    self.freeze
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
    output << "in (#{@row}, #{@col}, #{@block})"
    output
  end

  def print_candidates
    if @fixed
      print "|#{value}"
    else
    print "|"
      @candidates.each { |v| print "#{v}" }
    end
  end

  def print_ref
    print("#{@ref.to_s} ")
  end
end

if __FILE__ == $0

class Cell_TestUnit
  attr_reader :name

  def initialize(a_name)
    @name = a_name
  end

  def to_s
    @name
  end
end

  # test code

  cell_aRef = CellRef.new(2,3)
  puts cell_aRef.to_s

  cell_aBlk = 8
  cell_aCell = Cell.new(cell_aRef, cell_aBlk)
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
  
  new_cell = cell_aCell.clone
  puts "ERROR: clone method did not return exact copy of cell." if !cell_aCell.isEqual?(new_cell)
  
end
