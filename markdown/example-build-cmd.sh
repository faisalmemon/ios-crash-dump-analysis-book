#!/bin/bash

pandoc Introduction.md -f markdown+smart --standalone --bibliography ../bibliography.bib  -o foo.pdf
