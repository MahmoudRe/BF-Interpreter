# Brainfuck Interpreter Project

## Files discription:
 - main.s:
    This file contains the main function.
    It reads a file from a command line argument and passes it to your brainfuck implementation.

 - read_file.s:
    Holds a subroutine for reading the contents of a file.
    This subroutine is used by the main function in main.s.

 - brainfuck.s:
    In it there is a `brainfuck` subroutine that takes
    a single argument: a string holding the code to execute.

 - Makefile:
    A file containing compilation information. Simply run the command `make`.

## How to run the interpreter?
  1. On terminal, run `make`
  2. Then just run `./brainfuck`
  - Make sure to have `make` installed on your linux system, to do so run the following commands
  - `$ sudo apt-get update`
  - `$ sudo apt-get install build-essential`
