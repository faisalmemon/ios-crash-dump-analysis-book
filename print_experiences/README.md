# Print Experiences

This directory is for storing any files, errors or other materials relating to actually generating a print ready version of the book.

## Gutter Issues

I find that the gutter is entered on [page 172](./gutterIssue.png).  We have 6-7 extra characters.
We got to this place by using `fold -s60 -w72`.  So we need to be narrower to 65.
I wrote the tool `markdown_fold` which is a 65 width markdown aware version of fold.  I found 66 too big.  I've integrated this into the build system so we no longer need to tweak the verbatim output unless we have >65 essential characters in which case we'll need to use elipses to truncate uninteresting content.  We had to do that form the poisoned memory dumps.

# Bibliography Issues

I don't have the ARM Breakpoint Instruction or the Exception Syndrome Register setup properly.  I fixed that by adding a Url in addition to the BSD Url, and also adding a Year.

I have some if{csl - hanging} spurious text at the top of the bibliography.  See [bibliographyIssue.png](./bibliographyIssue.png)  I need to study this.

# Photograph Issue

My portrait picture has a white background but the cover art would suit a black background.  See [faisal-portrait-25-6-2020.jpg](./faisal-portrait-25-6-2020.jpg)
