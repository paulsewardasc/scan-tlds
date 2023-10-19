#!/usr/bin/python3

import os.path
import sys

def read_increment_and_write_number(filename):
  # Check if the file exists.
  if not os.path.exists(filename):
    # Create the file and write the number 1 to it.
    with open(filename, 'w') as f:
      f.write('0')

  # Open the file for reading and writing.
  with open(filename, 'r+') as f:
    # Read the first line of the file.
    number = int(f.readline())

    # Increment the number.
    if len(sys.argv) == 1:
      number += 1

    # Write the incremented number back to the file.
    f.seek(0)
    f.write(str(number))

    # Truncate the file to the current position.
    f.truncate()

    return(number)

def print_to_stdout(*a):
  print(*a, file=sys.stdout)

if __name__ == '__main__':
  # Get the filename from the user.
  indfilename = 'ips.ind'

  # Read, increment, and write the number in the file.
  lineno = read_increment_and_write_number(indfilename) - 1
  with open("ips.txt", "r") as f:
    lines = f.readlines()
  try:
    line = lines[lineno].rstrip()
  except:
    lineno = 0
    os.remove(indfilename)
    line = lines[lineno].rstrip()
  print_to_stdout(line)


