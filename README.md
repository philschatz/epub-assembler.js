

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

# Bake the CSS into an HTML file

At this point you can use CSS Polyfills to do things like:

- move the glossaries to the back of the book
- add wrapper elements using `::outside::before::after` for styling features
- add an index
- collate sections/solutions to the end of a chapter
- collate the module abstracts to the start of a chapter (requires more code)

Here's how:

Install [philschatz/css-bake.js](https://github.com/philschatz/css-bake.js) globally or use the locally installed version (from `npm install`):

    ./node_modules/css-bake/bin/css-bake --input-html ./single-file.xhtml --input-css /path/to/css/file.less --output-html ./baked.xhtml --output-css ./baked.css

Now you can run `./baked.html` and `./baked.css` through a PDF-generation tool like `prince`.



## Notes:

1. once we switch to EPUBs for the transforms **Build an EPUB** can be skipped (please do not try to maintain that shell script)
