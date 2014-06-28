

Instructions:

There are 2 phases:

1. build an EPUB
1. build a single HTML file

## Build an EPUB

1. download [Connexions/rhaptos.cnxmlutils](https://github.com/Connexions/rhaptos.cnxmlutils) and place it in `./`
1. download a complete ZIP from cnx.org
1. unzip it into a directory (`./test-book`)
1. run `sh cnx2epub.sh 'col1234@5.6' ./test-book ./test-epub-dir`

## Build a single HTML file

1. `npm install`
1. `node ./src/assembler.js -i ./test-epub-dir > ./single-file.xhtml`

You can now run `./single-file.xhtml` through a PDF generation tool to create a PDF.

## Notes:

1. once we switch to EPUBs for the transforms **Build an EPUB** can be skipped (please do not try to maintain that shell script)
1. you can run `./single-file.xhtml` through [philschatz/css-polyfills.js](https://github.com/philschatz/css-polyfills.js) to do things like:
     - move the glossaries to the back of the book
     - add wrapper elements using `::outside::before::after` for styling features
     - add an index
     - collate sections/solutions to the end of a chapter
     - collate the module abstracts to the start of a chapter (requires more code)
