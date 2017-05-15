# suds
A Sudoku Solver

This program, suds.rb, expects a command line option which is the name of a file containing a Sudoku puzzle in JSON format. It
then attempts to solve the puzzle. It never uses a brute force method, and therefore so far I have not been able to solve all puzzles.
But I am working on it. In addition, in the html/ directory, there is another program, puzzle_parser.rb, which contacts the websudoku.com
site, pulls a puzzle from their site, and creates a correctly formatted JSON puzzle file.
