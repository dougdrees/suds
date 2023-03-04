require_relative "cell"

class Unit
  attr_reader :unit_index, :cells, :grid

  def initialize(grid, index)
    @cells = Array.new(9) # replace this 9 with information from the puzzle that was read.
    @grid = grid
    @unit_index = index
  end

  def add(cell, index_in_unit)
    #puts "Add: #{cell.ref} at #{index_in_unit} in #{@unit_index}"
    #cell.print_candidates
    #puts
    @cells[index_in_unit] = cell
  end

  def mark(value)
    # self.print_unit
    foreach_cell { |cell| cell.mark(value) }
    # self.print_unit
  end

  def mark_except(value, cell_ary)
    ref_set = Set.new
    cell_ary.each { |cell| ref_set.add cell.ref }
    self.foreach_cell do |cell|
      cell.mark(value) unless ref_set.include? cell.ref
    end
    # self.print_unit
  end

  def scan_for_cells_to_fix()
    self.foreach_cell do |cell|
      # cell.print_candidates
      # puts "#{cell.has_one_candidate?}:#{cell.fixed}:#{cell.value}"
      @grid.add_cell_to_queue(cell, cell.get_last_candidate) if cell.has_one_candidate?
    end
  end

  def size
    @cells.size
  end

  def foreach_cell
    @cells.each { |cell| yield cell }
  end

  def contains_all?(some_cells)
    has_all = true
    some_cells.each { |input_cell| has_all = false unless contains?(input_cell) }
    has_all
  end

  def contains?(cell)
    has_it = false
    self.foreach_cell { |unit_cell| has_it = true if cell == unit_cell }
    has_it
  end

  def [](index)
    @cells[index]
  end

  def print_unit
    print "#{@cells.length} "    
    self.foreach_cell { |cell| cell.print_candidates }
    puts "|"
  end
end

class Row < Unit
  def initialize(grid, index)
    super(grid, index)
  end

  def add_cell(cell)
    self.add(cell, cell.ref.x)
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
    self.add(cell, cell.ref.y)
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
    col = cell.ref.x % 3
    row = cell.ref.y % 3
    blk_index = col + 3 * row
    self.add(cell, blk_index)
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
  cells = {}
  rows = Array.new(9)
  columns = Array.new(9)
  blocks = Array.new(9)
  NUM_CELLS = 81

def print_puzzle(c, r, b)
  (0..8).each do |col_index|
    col = c[col_index]
    (0..8).each do |cell_index|
      entry = col[cell_index]
      puts "Column #{col_index} at #{cell_index} is nil." if entry == nil
      puts "Column #{col_index} at #{cell_index} ref is #{entry.ref} r=#{entry.row} c=#{entry.col} b=#{entry.block}." if col[cell_index]
    end
  end

  (0..8).each do |row_index|
    row = r[row_index]
    (0..8).each do |cell_index|
    entry = row[cell_index]
      puts "Row #{row_index} at #{cell_index} is nil." if entry == nil
      puts "Row #{row_index} at #{cell_index} ref is #{entry.ref} r=#{entry.row} c=#{entry.col} b=#{entry.block}." if row[cell_index]
    end
  end  

  (0..8).each do |blk_index|
    blk = b[blk_index]
    (0..8).each do |cell_index|
      entry = blk[cell_index]
      puts "Block #{blk_index} at #{cell_index} is nil." if entry == nil
      puts "Block #{blk_index} at #{cell_index} ref is #{entry.ref} r=#{entry.row} c=#{entry.col} b=#{entry.block}." if blk[cell_index]
    end
  end
end
    
  (0..8).each do |index|
    rows[index] = Row.new(nil, index)
    columns[index] = Column.new(nil, index)
    blocks[index] = Block.new(nil, index)
  end
  
  (0..8).each do |index|
    print "#{rows[index].cells.size} " 
    print "#{columns[index].cells.size} "
    print "#{blocks[index].cells.size} "
    puts
  end
  
  # create_grid  # this implementation assumes square grids
  (0..8).each do |y| # once for each row
    row_factor = (y)/3
    (0..8).each do |x|
      col_factor = (x)/3
      ref = CellRef.new(x, y)
      block = col_factor+row_factor*3
      # puts "New Cell (#{x},#{y}) in #{block}"
      cell = Cell.new(ref, block, 9)
      cells[ref] = cell
      columns[x].add_cell(cell)
      rows[y].add_cell(cell)
      blocks[block].add_cell(cell)
      #print_puzzle(columns, rows, blocks)
    end
  end
  
  puts "number of cells added = #{cells.size}"
  puts "ERROR: wrong number of cells added, should be #{NUM_CELLS}." if NUM_CELLS != cells.size
  
print_puzzle(columns, rows, blocks)

end
