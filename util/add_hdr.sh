add_header() {
  echo Adding header to $1
  mv $1 $1.old
  (
  echo '--###############################################################################'
  echo "--# $1  - DESCRIPTION_NEEDED"
  echo '--#'
  echo '--# Part of the simple-riscv project. A simple three-stage RISC-V compatible CPU.'
  echo '--#'
  echo '--# See https://github.com/hamsternz/simple-riscv'
  echo '--#'
  echo '--# MIT License'
  echo '--#'
  echo '--###############################################################################'
  echo '--#'
  echo '--# Copyright (c) 2020 Mike Field'
  echo '--#'
  echo '--# Permission is hereby granted, free of charge, to any person obtaining a copy'
  echo '--# of this software and associated documentation files (the "Software"), to deal'
  echo '--# in the Software without restriction, including without limitation the rights'
  echo '--# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell'
  echo '--# copies of the Software, and to permit persons to whom the Software is'
  echo '--# furnished to do so, subject to the following conditions:'
  echo '--#'
  echo '--# The above copyright notice and this permission notice shall be included in all'
  echo '--# copies or substantial portions of the Software.'
  echo '--#'
  echo '--# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR'
  echo '--# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,'
  echo '--# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE'
  echo '--# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER'
  echo '--# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,'
  echo '--# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE'
  echo '--# SOFTWARE.'
  echo '--#'
  echo '--############################################################################### '
  cat $1.old
  ) > $1
}

for fname in `find . -type f -name '*.vhd'`
do
  if [ "`grep 'MIT License' $fname`" = "" ]
  then
     add_header $fname
  
  fi
done
