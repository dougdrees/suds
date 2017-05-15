require_relative "cell"

class Unit
  attr_reader :index, :un_fixed_count, :cells, :grid, :cell_ary

  def initialize(grid, index)
    @un_fixed_count = 0
    @cells = {}
    @cell_ary = []
    @grid = grid
    @index = index
  end

  def add_cell(cell)
    #puts "add_cell: #{cell.ref}"
    #cell.print_candidates
    #puts
    @cells[cell.ref] = cell
    @un_fixed_count += 1
  end

  def mark(value)
    foreach_cell { |cell| cell.mark(value) }
    #self.print_unit
  end

  def mark_except(value, cell_ary)
    ref_set = Set.new
    cell_ary.each { |cell| ref_set.add cell.ref }
    foreach_cell do |cell|
      cell.mark(value) unless ref_set.include? cell.ref
    end
    #self.print_unit
  end

  def reduce_fix_count
    @un_fixed_count -= 1
  end

  def scan_for_cells_to_fix()
    foreach_cell do |cell|
      #cell.print_candidates
      #puts "#{cell.has_one_candidate?}:#{cell.fixed}:#{cell.value}"
      @grid.add_cell_to_queue(cell, cell.get_last_candidate) if cell.has_one_candidate?
    end
  end

  def size
    @cells.size
  end

  def foreach_cell
    @cell_ary.each { |cell| yield cell }
  end

  def contains_all?(cells)
    has_all = true
    cells.each { |input_cell| has_all = false unless contains?(input_cell) }
    has_all
  end

  def contains?(cell)
    has_it = false
    foreach_cell { |unit_cell| has_it = true if cell == unit_cell }
    has_it
  end

  def [](index)
    @cell_ary[index]
  end

  def print_unit
    print "#{@index} #{@cells.length} <"
    foreach_cell { |cell| cell.print_candidates if cell }
    puts ">"
  end
end

class Row < Unit
  def initialize(grid, index)
    super(grid, index)
  end

  def add_cell(cell)
    super(cell)
    @cell_ary[cell.ref.y] = cell
  end

  def to_s
    "Row #{@index}: #{@cells.length}"
  end
end

class Column < Unit
  def initialize(grid, index)
    super(grid, index)
  end

  def add_cell(cell)
    super(cell)
    @cell_ary[cell.ref.x] = cell
  end

  def to_s
    "Column #{@index}: #{@cells.length}"
  end
end

class Block < Unit
  def initialize(grid, index)
    super(grid, index)
  end

  def add_cell(cell)
    super(cell)
    col = cell.ref.x % 3
    row = cell.ref.y % 3
    blk_index = row * 3 + col
    @cell_ary[blk_index] = cell
  end

  def intersection(unit)
    intersection = Set.new
    self.foreach_cell do |cell|
      intersection.add(cell) if self.contains?(cell)
    end
    intersection
  end

  def to_s
    "Block #{@index}: #{@cells.length}"
  end
end

if __FILE__ == $0
  # test code

  unit_aRow = Row.new(nil, 7)
  unit_aCol = Column.new(nil, 5)
  unit_aBlk = Block.new(nil, 7)

  (0..8).each do |x|
    unit_aRef = CellRef.new(x,7)
    unit_aCell = Cell.new(unit_aRef, unit_aRow, unit_aCol, unit_aBlk)
    unit_aRow.add_cell(unit_aCell)
    unit_aCell.fix(x)
  end

  unit_aRow.print_unit

  puts unit_aRow.un_fixed_count

  puts unit_aRow.index

  col = 0
  unit_aRow.foreach_cell do | cell |
    puts "#{col}: #{cell.to_s}"
    col += 1
  end

end
