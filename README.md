# iOS Crash Dump Analysis Book

The HTML version of the book, "iOS Crash Dump Analysis" is available at the link:
https://faisalmemon.github.io/ios-crash-dump-analysis-book/  

Accompanying the book is an Analytic Troubleshooting worksheet.
[Download the Analytic Troubleshooting worksheet pdf](./examples/worksheets/analytic_troubleshooting_worksheet.pdf)

The Kindle version is available for purchase at: [Amazon.com](https://www.amazon.com/iOS-Crash-Dump-Analysis-application-ebook/dp/B07HG7RXM6),
[Amazon.co.uk](https://www.amazon.co.uk/iOS-Crash-Dump-Analysis-application-ebook/dp/B07HG7RXM6), and other geographic regions of Amazon.

A print edition is available from Amazon, and also from traditional book sellers.  The release date is 22nd September, 2018.

The purpose of this repository is to provide the source code, and other resources, supporting the iOS crash dump analysis book.  

The rationale for providing the source freely, in addition to the commercial offering, is to make it easy to collaborate, share, and build upon the ideas of the book.  Buying a print, or electronic, version of the book helps support the author to create further text books.  If you feel this content has helped you, please consider making a purchase.

## Why write this book?

When I look around at colleagues I notice that we all come to app programming from different career paths.  It seemed like everyone else found crash dump fixing burdensome apart from myself.
I came to app programming from the bottom upwards.  I started off as a device driver and kernel engineer and took subsequent jobs in the middleware layer and then lastly in the app layer.
This less trodden route has given me a perspective which I would like to share with other developers and engineers.

## It's already documented right?

1. There are lots of documents on the specifics of exploring crash dumps, but they exist in a knowledge bubble not connected to the normal app developer experience; they feel alien.  The knowledge is generally scattered around without a definitive guide.  I would like collect the information together into one place.

1. Software engineering concepts can be employed to avoid crashes, and to lessen the pain in finding and resolving them.  I would like shine a light on this aspect of engineering so you can improve your codebase proactively.

1. Step-by-step guides often seem to make large logical jumps to derive the answer to why an app crashed.  But crash dump analysis is just problem-solving in a specific domain.  There are systematic problem solving approaches that can be applied here.  I have found these helpful in my own work and want to share the insights more widely.

It's my opinion that when you put these three approaches together: software engineering, systematic problem solving, and crash dump exploration you end up with a powerful toolbox you can take with you to any iOS app project.
You will be able to spend less time fixing crashes, and more time writing valuable functionality.  That's something we all want!

# Project Details

## Directory Structure

Directory | Purpose
----------| -------
external | Downloaded resources
topics | Topic specific writing
source | Parent directory of compilable source code
markdown | Markdown files for the body text of the book
examples | Examples of crashes
automation | Not yet used
screenshots | Screenshots

## Branch Policy

The software configuration management plan (SCM plan) is very simple.
- All development is done on the master branch.
- When a version of the book is published a numbered release branch is made, e.g. `release/1.0`

## Authoring Methodology

I followed an approach similar approach to http://rtalbert.org/how-i-wrote-my-book/ and Ben Watson at [Philosophical Geek](http://www.philosophicalgeek.com/2014/11/10/tips-for-writing-a-programming-book/) with a few amendments.  The process turned out to be:

- Write the content of the book in markdown
- Use pandoc to convert the markdown into MS Word `docx` format, `.epub`, `.latex`, and `.html`
- Use BibDesk to track biliographic references
- Use latex `\index` to create index links in the main body of the work
- Use `pdflatex` to convert latex files into a PDF because it allows auto section numbering and index generation

The output file formats were used as follows:
- `.docx` version to do grammar and spell checking
- `.pdf` version used to prepare the print version of the book via Kindle KDP web site
- `.epub` version used to create the Kindle E-book via the Kindle KDP web substitute
- `.html` version used to create the GitHub pages version

The writing was done on a per chapter basis, with separate markdown files for examples and their discussion.  This allowed me to merge and move around the smaller level items into parent chapters to form a logical grouping.

Each chapter was done in phases:
- Write the content, marking obvious index items, but generally focussing on content
- Do needed digressions for research, and write sample code to justify statements made
- Review the `.docx` version and run the spell and grammar checker, fixing any faults in the markdown
- Review the markdown and insert latex index entries, cross referencing prior indexed items for uniformity and grouping

The aim was to leave each chapter in a near-publishable state, to avoid accumulating a large backlog of work.  I resisted placing any TODO work items in the markdown text.  I maintained a `ideas.txt` file for chapter and content ideas as I went through.  I also did a `grep` for forward topic references in the book so that I covered later on what was promised earlier on.  The main benefit was I had a good idea of my progress on the book as I went along.

In terms of writing style, I used first person singular for the preface.  I used second person plural for the Introduction, and used first person plural elsewhere.  I had a script to check not to use "you" when a "we" should have been used in the main body of the text.

Once all chapters were done, the whole book was read through using VoiceOver (Option-Escape) because this catches proof reading errors (like swapping around words or duplicating words).

I also hand wrote the back page text directly in `.docx` and then pruned it to fit the back of the book and the marketing materials.

I had a special index mark for trademark terms and a custom script to collate those and inject them into the text as a list of acknowledged trademarks.  The entire book building process was automated from a command line script.

I had a special `.css` file for the E-book to make the tables look nicer (a simple outline border).
I also used a github styled `.css` file for the HTML edition.

The last phase was upload to the KDP website to generate the e-book and print versions.  I had to re-size my example code blocks to fit the Extended Distribution in Print requirements (6 inches by 9 inches is the biggest) as only standard book sizes are distributable via Extended Distribution (regular book shops).

## Progress and Effort

The hardest part was learning about the appropriate tooling to do the job and deploy for the relevant target formats, and working out what formats and platforms to use.  This consumed two weeks.

The tail portion of the work was quick.  It took 1 day to re-base my code on the newly released Xcode 10 Gold Master.  I just needed to re-work one chapter due to a behavior change in iOS 12.  It took 1 day to proof read my work using VoiceOver.  It took 1 day to re-format the code and report examples to change to 6 x 9 inch book format needed for Extended Distribution of the text in print format to physical book sellers, as well as the time to fix up the print ready PDF since Amazon has stricter gutter requirements (going into the margin) than I had anticipated.  I also had to do the book cover text.  I was overall pleased it was 3 days of final processing.

The chapters of the book were the most effort.  Each chapter took about 0.5 days to fix spelling and grammar, and add index entries.  The rest of the time was spent roughly 60% research, 40% writing but I am not sure as I didn't pay so much attention to the balance.

I wrote over a period of 3 months but had other tasks and duties during that time.  So it was 7 weeks of full time work spread across 3 months.  I worked normal business hours, roughly 40 hours per week.  For 170 pages of text, it works out at 1.6 hours per page.  If I were to write a second book, using the same technology and approach, I think it would be 5 weeks effort, and 1.2 hours per page.  This is because in my first book I had to do 2 weeks research, and setup, of my build system to generate the book in the appropriate formats.

I planned to write more but I had some work opportunities that came up that were potentially going to limit my time to spend on the book and wasn't sure if it was going to pass the "moonlighting" test for private work.  I would have written chapters explaining about Operating Systems architecture, assembly programming basics, and performance analysis with Instruments.

## Supporting software

### Essential Software

You need:
- Brew Package manager
- Various Brew packages
- Latex packages
- Class dump

#### Brew Software

I used the Brew package manager on MacOS and used the Brew packages:

Brew Package | Purpose
--|--
`pandoc` | Document translator to get from .markdown format to other formats
`pandoc-citeproc` | Biliography Citation Helper for pandoc

#### Latex Support

Latex support appears not to be available directly in brew so I used the recommended [MacTex](https://www.tug.org/mactex/) and this was installed via a brew cask install
`brew cask install mactex`

#### Class Dump

For analysing binaries I used `class-dump`.  Whilst previously this was available from Brew, it seems now you have to directly download it.

[Download class-dump](http://stevenygard.com/projects/class-dump/)


### Recommended Software

Package | Purpose
--|--
Atom|Edits and understands markdown and can preview render it
BibDesk | Eases the definition of Citations for the Biliography

## Essential Mac Configuration

#### Screenshots

I have discovered the standard screenshot on Mac only does low resolution (screen resolution) images.  Print books need to have higher resolution.

I saw an answer at: https://apple.stackexchange.com/a/110206

I need to experiment in this area.  Maybe putting my screen in large scale mode will give me screenshots with effectively a higher ppi when shrunk down for print.

## Build System

The book is built using `buildBook.sh`

The build outputs are:

File | Purpose
--|--
`foo.html` | Intermediate used for GitHub Pages documentation
`foo.pdf` | For the Hard Copy Paper Edition
`foo.docx` | For further conversion into EPUB, and internally for spelling and grammar checking
`foo.epub` | For E-book readers (Apple and Amazon) directly from pandoc
`docs/*` | Final destination for GitHub Pages documentation

The output are `foo.*` files locally for ease of inspection.  They are ignored by version control.

For github pages, the GitHub documentation facility, the HTML documentation and supporting resources is copied into the `docs` directory and then they are checked in (the branch is required to be master).

The build system also checks for uses of "you" - they should be "we" in all cases apart from the Introduction.
