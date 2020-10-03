# Tools

## `markdown_fold` Tool

The `markdown_fold` tool is built from `sources/markdown_fold`.  Its purpose is to ensure that the verbatim portions of markdown files are not overlong for the purposes of printing in a 6x9 inch book.

## `clean_gutter.sh` Tool

This tool uses `markdown_fold` as part of the book building script to keep all the markdown and example files within the gutter limits; the errors we used to get were text going too far into the right hand side margin.

## `commatrademark.sh` Tool

The manuscript indexes all items referencing a trademark upon their first instance.  We have this tool to pick up such references and make a complete list of trademark references, so that later on in the text, we do not need to announce the word as trademarked.

## `get_markdown_for_lang.sh` Tool

This tool works out if there is a localised version of the given file and emits that as the path, otherwise it emits the en (English) version of the file.  This means that the localised copy should have a safe fallback whenever new files are added which have not yet been localised.
