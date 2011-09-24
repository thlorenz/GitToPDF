path = require 'path'
exec = require('child_process').exec

inlinecss = (input_file, rubyscriptdir, cb) ->
  rubyscript = path.join rubyscriptdir, "inlinecss.rb"
  exec "ruby #{rubyscript} #{input_file}", (err, stdout, stderr) ->
    if (err or stderr)
      console.log "Error: ", err
      console.log "Stderr: ", stderr
      cb err, null
    else
      cb null, stdout

module.exports = inlinecss
