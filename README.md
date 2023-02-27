# suds
A Sudoku Solver

This program, suds.rb, expects a command line option which is the name of a file containing a Sudoku puzzle in JSON format. It
then attempts to solve the puzzle. It uses 5 deterministic algorithms that make no guesses. It also employs a 6th algorithm,
called a Forcing Chain (or Swordfish), which finds a single cell containing only 2 possible candidate values and guesses one.
The last algorithm could turn into a brute force in the worst case but often is able to solve tough puzzles in only one guess.
In addition, in the html/ directory, there is another program, puzzle_parser.rb, which contacts the websudoku.com
site, pulls a puzzle from their site, and creates a correctly formatted JSON puzzle file.
