exec = require('child_process').exec

inlinecss = (input_file, cb) ->
  exec "ruby inlinecss.rb #{input_file}", (err, stdout, stderr) ->
    if (err or stderr)
      console.log "Error: ", err
      console.log "Stderr: ", stderr
      throw err
    cb null, stdout

module.exports = inlinecss
