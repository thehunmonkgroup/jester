#!/bin/bash

# This script will byte-compile all code files listed in 'jester/compile.txt'.
# By default this would be all non-config and non-sequence code.
#
# The script takes one argument, the destination folder to write the files to.
# It first makes a complete copy of the entire jester folder to that new
# folder, then individually byte-compiles files that are listed in
# 'jester/compile.txt', writing them to the appropriate location in the
# specified directory.
#
# You must be in the main jester directory when you execute the script.
#
# So, if you wanted the byte-compiled version of the code at
# '/tmp/jester.compiled', you would cd into the main jester directory, and run:
#
#  ./scripts/compile.sh "/tmp/jester.compiled"

dest_dir=$1

mkdir -p $dest_dir
cp -a . $dest_dir

for file in `cat scripts/compile.txt`
do
  echo "byte-compiling $file to $dest_dir/$file"
  luac -o $dest_dir/$file $file 
done
