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
      unit.foreach_cell { |cell| count += 1 if cell.candidates.include?(candidate) }
      if count == 1
        unit.foreach_cell do |cell|
          @grid.add_cell_to_queue(cell, candidate) if cell.candidates.include?(candidate)
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

    # find the units (columns & rows) that intersect
    unit_set = Set.new
    block.foreach_cell do |cell|
      unit_set.add(block.grid.rows[cell.ref.row])
      unit_set.add(block.grid.columns[cell.ref.col])
    end

    # For each intersecting unit, we create a Set that is the cells in the intersection of
    # the block and the intersecting unit. Using Set operations, we can then find hidden pairs.
    unit_set.each do |unit|
      # Create the intersection set.
      intersection_values.clear
      intersection = block.intersection(unit)

      # Create a set of all candidates that are in the intersection cells
      intersection.each do |cell|
        intersection_values.merge(cell.candidates)
      end

      # Create a set of the cells in the block that are not in the intersection - call it the
      # remainder set
      remainder_set = block_set - intersection

      # Create the set of all candidates that are in the remainder set
      remainder_values.clear
      remainder_set.each do |cell|
        remainder_values.merge(cell.candidates)
      end

      # Now, subtract the remainder value set from the intersection value set. Any cells in the
      # resulting set are hidden in the intersection.
      hidden_candidates = intersection_values - remainder_values

      # Here we walk through the cells in the intersecting unit that are not in the intersection
      # and mark the hidden candidates.
      # puts "line 109 algorithms.rb"
      unit = Set.new(unit.cell_ary)
      remainder_set = unit - intersection
      remainder_set.each do |cell|
        hidden_candidates.each do |candidate|
          cell.mark(candidate)
        end
      end

      # Next, we reverse the process by finding hidden values in the intersection that are not
      # in the unit remainder set.
      remainder_set = unit_set - intersection

      # Create the set of all candidates that are in the remainder set
      remainder_values.clear
      remainder_set.each do |cell|
        remainder_values.merge(cell.candidates)
      end

      # Now, subtract the remainder value set from the intersection value set. Any cells in the
      # resulting set are hidden in the intersection.
      hidden_candidates = intersection_values - remainder_values

      # Here we walk through the cells in the block that are not in the intersection
      # and mark the hidden candidates.
      remainder_set = block - intersection
      remainder_set.each do |cell|
        hidden_candidates.each do |candidate|
          cell.mark(candidate)
        end
      end
    end
  end

  # Looks for hidden pairs (or triplets, quadruplets) of cells in a unit that are the only
  # ones with 2 (or 3 or 4) specific candidates. For example, if cells 3 and 8 are the
  # only cells in the unit that have the values 4 & 7 in their candidate sets, then they
  # become a pair with only those candidates.
  def hidden_pair
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

  # Does a simplified brute force to try to close out the puzzle. It makes an guess
  # to solve a single cell with only two remaining candidates and then propagates the impact
  # through the puzzle, looking for conflicts. If a conflict is found, then it undoes the changes
  # at picks the other value in the original cell. If there is no conflict and the puzzle is
  # completely solved, then we're done. If there is no conflict but there are cells still unsolved,
  # then we undo the changes and try a different cell. Undoing changes is done by saving away a
  # snapshot (copy) of the grid state and restoring it to undo changes.
  def forcing_chain
    # Find a cell with two candidates
    # Take a snapshot of the grid
    # Pick one of the values and add it to the queue for that cell
    # Call grid.process_queue
    # Check for conflicts in the grid
    # If conflicts, restore snapshot, pick the other value and repeat
    # If solved, return
    # Else, restore snapshot, pick another cell, and repeat
  end

end
