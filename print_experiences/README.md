# Print Experiences

This directory is for storing any files, errors or other materials relating to actually generating a print ready version of the book.

## Gutter Issues

I find that the gutter is entered on [page 172](./gutterIssue.png).  We have 6 extra characters.
We got to this place by using `fold -s60 -w72`.  So we need to be narrower to 66.  Maybe `fold -s54 -w 66`

# Bibliography Issues

I don't have the ARM Breakpoint Instruction or the Exception Syndrome Register setup properly.
I have some if{csl - hanging} spurious text at the top of the bibliography.  See [bibliographyIssue.png](./bibliographyIssue.png)
