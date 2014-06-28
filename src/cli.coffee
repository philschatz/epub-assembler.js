optimist = require 'optimist'
EpubAssembler = require './epub-assembler'
Q = require 'q'
path = require 'path'
fs            = require('./fs-helpers')

# Handle command line options

args = optimist
  .usage('Usage: $0')
  .options('h',
    alias     : 'help'
    boolean   : true
    describe  : 'Show this help info and exit'
  )
  .options('i',
    alias     : 'input-epub-dir'
    describe  : 'Root Directory for unzipped EPUB'
  )
  # .options('o',
  #   alias     : 'output-file'
  #   default   : 'single-file.xhtml'
  #   describe  : 'Single HTML file that is fed into a PDF generator'
  # )

argv = args.argv
console.error(argv)


class FileAssembler extends EpubAssembler
  constructor: (@rootPath) ->

  log: (msg) ->
    console.error(msg)
    return Q.delay(1)

  readFile: (filePath) ->
    return @log({msg:'Reading file', path:filePath})
    .then () =>
      return fs.readFile(path.join(@rootPath, decodeURIComponent(filePath)))

unless argv.i
  console.error('Missing argument. try -h')
  process.exit(1)

assembler = new FileAssembler(argv.i)
assembler.assemble()
.then(null, ((err) -> console.error(err)))
.then (buffer) ->
  # Write the buffer to stdout
  process.stdout.write(buffer)
  console.error('Done!')
