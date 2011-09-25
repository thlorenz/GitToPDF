path = require 'path'
fs = require 'fs'
fu = require './fileutils.coffee'
temp = require './temp.coffee'
Seq = require 'Seq'
_ = require 'underscore'

wrapInsert = "\n⋄⋄⋄"

wrapLine = (line, columns) ->
  
  if line.length <= columns
    { line, changed: false }
  else
    splitChar = ' '

    lineParts = []
    remaining = line
    while (remaining.length > columns)

      # Find first splitChar before largest column
      splitPosition = (remaining.substring 0, columns).lastIndexOf splitChar
      if splitPosition < 0 then splitPosition = columns

      shortEnough = remaining.substring 0, splitPosition
      lineParts.push shortEnough

      remaining = remaining.substring splitPosition + 1

    if remaining.length > 0 then lineParts.push remaining

    { line: (lineParts.join wrapInsert), changed: true }
    
wrapFile = (fullPath, columns, callback) ->

  wrapFileContent = (data) ->
      data
        .toString()
        .split('\n')
        .map((x) -> wrapLine x, columns)

  # Writes Content to tempfile and returns its full path
  writeToTempFile = (extension, content, callback) ->
    Seq()
      .seq(-> temp.open({ suffix: extension }, this))
      .seq((info) ->
        fs.write info.fd, content
        fs.close info.fd, (err) -> callback(err, info.path)
      )
  
  Seq()
    .seq(-> fs.readFile fullPath, this)
    .seq((data) ->
      lines = wrapFileContent data
      
      contentChanged = _(lines).any((x) -> x.changed)
      if (contentChanged)
        extension = path.extname fullPath
        content = lines
          .map((x) -> x.line)
          .join('\n')

        writeToTempFile(extension, content, callback)
      else
        # We can use the original file
        this(null, fullPath)
    )
    .seq((res)-> callback(null, res))

module.exports = { wrapInsert, wrapLine }

# Scripting to test things

fullpath = fu.cleanPath "~/dev/js/node/sourcetopdf/test/inlinecss.coffee"
wrapFile fullpath, 50,(err, path) ->
  fs.readFile path, (err, data) -> console.log "Result", data.toString()
  console.log "\nDONE"


