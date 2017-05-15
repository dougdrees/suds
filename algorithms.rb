require_relative "cell"
require_relative "unit"
require_relative "grid"

# Algorithms for reducing candidates for cells
# The algorthms should be run on a unit at a time. After running an algorithm on a unit,
# process the queue.

class Algorithms

  def initialize(grid)
    @grid = grid
  end

  # Looks across a unit to see if a specific value only exists in one cell's candidates.
  def find_singular_value(unit, max_value)
    # First look for a value that has is in only one cell's candidate list. Do this by
    # sequencing though the possible values (perhaps ignoring any fixed values) and for
    # each, count how many cells in the unit have that value. If the count is one, then
    # that is a singular value.
    # If found, add the cell to the queue with the singular value.
    (1..max_value).each do |candidate|
      count = 0
      unit.cells.each { |_,c| count += 1 if c.candidates.include?(candidate) }
      if count == 1
        unit.cells.each do |_,c|
          @grid.add_cell_to_queue(c, candidate) if c.candidates.include?(candidate)
        end
      end
    end
  end

  # Looks for pairs of cells in a unit that each contain 2 candidates and they are the
  # same ones.
  def find_pair(unit)
    # Build a hash with a key that is the candidate set for a cell and a value that is an
    # array of cells with the equal sets.
    h = {}
    unit.foreach_cell do |cell|
      key = cell.candidates
      if h.include? key
        h[key] << cell
      else
        h[key] = [ cell ]
      end
    end

    # Next, scan the hash looking first for candidate sets containing only 2 candidates
    # and then check the array associated with the set to see if it contains exactly 2
    # cells. If so, for each candidate in the set, mark all cells in the unit except those
    # in the array.
    h.each_pair do | candidate_set, cell_ary |
      if candidate_set.size == 2 && cell_ary.size == 2 
        candidate_set.each { |value| unit.mark_except(value, cell_ary) }
      end
    end

    # Follow this with a scan of the unit for cells with one candidate and add those to
    # the queue.
    unit.scan_for_cells_to_fix()
  end

  # Looks at intersections of units. For each such intersection, it looks if there is a value
  # found in the intersection that is not found in any other cells in one unit 
  # in the intersection. If so, then mark that value in the other cells in the other unit.
  # Note that this can only happen if one of the units is a block because rows and columns
  # intersect at a single cell.
  def intersecting_units(block)
    # create set of cells in the block
    block_set = Set.new(block.cell_ary)
    intersection_values = Set.new
    remainder_values = Set.new

    # find the columns & rows that intersect
    rows = Set.new
    cols = Set.new
    block.foreach_cell do |cell|
      rows.add(block.grid.rows[cell.ref.row])
      cols.add(block.grid.columns[cell.ref.col])
    end
    rows.each do |row|
      intersection_values.clear
      intersection = block.intersection(row)
      intersection.each do |cell|
        intersection_values.merge(cell.candidates)
      end
      remainder_set = block_set - intersection
      remainder_values.clear
      remainder_set.each do |cell|
        remainder_values.merge(cell.candidates)
      end
      values = intersection_values - remainder_values
      # DPD - here we walk through the row remainder cells and mark any values
      # in the values set.
      # Next, we subtract the intersection from the rows set to create a new
      # remainder_set and then mark any values in the block set.:w
      #
    end
    # DPD - do the same as above for columns
  end

  # Looks for hidden pairs (or triplets, quadruplets) of cells in a unit that are the only
  # ones with 2 (or 3 or 4) specific candidates. For example, if cells 3 and 8 are the
  # only cells in the unit that have the values 4 & 7 in their candidate sets, then they
  # become a pair with only those candidates.
  kef hidden_pair
    # Create bit maps of the unit (one bit per cell in the unit) for each candidate value.
    # Build a hash with a key that is the bitmap for a candidate value and a value that
    # is an array of values with that same bitmap.
    # Next, scan the hash looking first for arrays of 2 values and see if the bitmap has two
    # ones.  Follow by looking for arrays of 3 cells and see if the first has 3
    # candidates. Finally, do the same for arrays of 4 with 4 candidates.
    # Are there two bit maps that are identical and have exactly two 1's in the maps?
    # Are there three bit maps that are identical and have exactly three 1's in the maps?
    # Are there four bit maps that are identical and have exactly four 1's in the maps?
    # These are hidden pairs. The cells involved are represented by the 1's in the maps.
    # The values are those in the matching maps.
    # For each pair, mark any other values in those two cells and mark the two values in
    # the other cells in the unit.
    # Do similar for triplets and quadruplets.
    # Follow this with a scan of the unit for cells with one candidate and add those to
    # the queue.
  end

end
