path = require 'path'
fs = require 'fs'
fu = require './fileutils.coffee'
temp = require './temp.coffee'
_ = require 'underscore'

wrapInsert = "\n.... "

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
    
wrapContent = (content, columns) ->
  lines = content
    .split('\n')
    .map((x) -> wrapLine x, columns)

  changed = _(lines).any((x) -> x.changed)

  if changed
    content = lines
      .map((x) -> x.line)
      .join('\n')

  { changed, content }

wrapFile = (fullPath, columns, callback) ->

  # Writes Content to tempfile and returns its full path
  writeToTempFile = (extension, content, callback) ->
    temp.open { suffix: extension }, (err, info) ->
      fs.write info.fd, content
      fs.close info.fd, (err) -> callback(err, info.path)
  
  fs.readFile fullPath, (err, data) ->

    wrap = wrapContent(data.toString(), columns)

    if (wrap.changed)
      extension = path.extname fullPath
      writeToTempFile(extension, wrap.content, callback)
    else
      # Use the original file as is
      callback(null, fullPath)

module.exports = { wrapInsert, wrapLine, wrapContent, wrapFile }
