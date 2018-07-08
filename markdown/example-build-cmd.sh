#!/bin/bash

pandoc $(cat pageOrder.txt) -f markdown+smart --standalone --bibliography ../bibliography.bib  -o foo.pdf
