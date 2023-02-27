require "set"
require_relative "cell"
require_relative "unit"

class CellValuePair
  attr_reader :cell, :value

  def initialize(cell, value)
    @cell = cell
    @value = value
  end
end

class CellQueue
  attr_reader :q, :set

  def initialize
    @q = Queue.new
    @set = Set.new
  end

  def add(cell, value)
    if !@set.include?(cell)
      @q << CellValuePair.new(cell, value)
      @set.add(cell)
    end
  end

  def pop
    pair = @q.pop
    @set.delete(pair.cell)
    return pair.cell, pair.value
  end

  def empty?
    q.empty?
  end
end

class Grid
  attr_reader :xDim, :yDim, :cells, :rows, :columns, :blocks, :un_fixed_count, :fix_queue

  def create_grid  # this implementation assumes square grids
    @un_fixed_count = @xDim * @yDim
    (0..@yDim-1).each do |y|
      yBlk = (y)/3
      (0..@xDim-1).each do |x|
        xBlk = (x)/3
        ref = CellRef.new(x, y)
        blk = xBlk+yBlk*3
        # puts "New Cell (#{x},#{y}) in #{blk}"
        cell = Cell.new(ref, @rows[y], @columns[x], @blocks[blk], @yDim)
        @cells[ref] = cell
        @rows[y].add_cell(cell)
        @columns[x].add_cell(cell)
        @blocks[blk].add_cell(cell)
      end
    end
  end
  
  def duplicate(other)  # this implementation assumes square grids and it doesn't copy the fix_queue
    # modify each cell to match the cell in other
    @un_fixed_count = other.un_fixed.count
    other.cells.foreach do | other_cell |
      y = other_cell.ref.y
      x = other_cell.ref.x
      blk = (x/3)+3*(y/3)
      new_cell = other_cell.clone(@rows[y], @columns[x], @blocks[blk])
      
      # puts "New Cell (#{x},#{y}) in #{blk}"
      @cells[new_cell.ref] = new_cell
      @rows[y].add_cell(new_cell)
      @columns[x].add_cell(new_cell)
      @blocks[blk].add_cell(new_cell)
    end
  end

  def initialize(x_dim, y_dim, other = nil)
    @xDim = x_dim
    @yDim = y_dim
    @cells = {}
    @rows = []
    @columns = []
    @blocks = []
    (0..@yDim-1).each { |y| @rows    << Row.new(self, y) }
    (0..@xDim-1).each { |x| @columns << Column.new(self, x) }
    (0..@xDim-1).each { |x| @blocks  << Block.new(self, x) }
    @fix_queue = CellQueue.new
    if other 
      duplicate_grid(other)
    else
      create_grid
    end
  end

  def fix_cell(cell, value)
    return if cell.fixed
    @un_fixed_count -= 1
    cell.fix(value)
    cell.row.mark(value)
    cell.col.mark(value)
    cell.block.mark(value)
    cell.row.scan_for_cells_to_fix()
    cell.col.scan_for_cells_to_fix()
    cell.block.scan_for_cells_to_fix()
  end

  def add_ref_to_queue(x, y, value)
    ref = CellRef.new(x, y)
    cell = @cells[ref]
    @fix_queue.add(cell, value)
  end

  def add_cell_to_queue(cell, value)
    @fix_queue.add(cell, value)
  end

  def process_queue
    # puts "process_queue: #{@fix_queue.q.length},#{@un_fixed_count}"
    until @fix_queue.empty? || @un_fixed_count == 0
      cell, value = @fix_queue.pop
      # puts "fixing #{cell.ref} to #{value}"
      self.fix_cell(cell, value)
    end
  end

  def foreach_unit
    @rows.each    { |r| yield(r) }
    @columns.each { |c| yield(c) }
    @blocks.each  { |b| yield(b) }
  end

  def print_grid
    puts "Dimensions of grid: #{@xDim}X#{yDim}"
    @rows.each { |row| row.print_unit }
    puts "Unsolved cell count = #{@un_fixed_count}"
  end
end

if __FILE__ == $0
  # test

  grid_aGrid = Grid.new(9, 9)

  grid_aGrid.print_grid

end
