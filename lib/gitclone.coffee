exec = require('child_process').exec

clone = (url, targetFolder, callback) ->
  exec "git clone #{url} #{targetFolder}", callback

module.exports = { clone }

return
# Testing

clone "git://github.com/chetan51/ni.git", "gittemp", (err, res) ->
  console.log "Cloned"
  console.log "Error", err
  console.log "Result", res
