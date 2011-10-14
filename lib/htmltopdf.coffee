exec = require('child_process').exec

convert = (fullSourcePath, fullTargetPath, callback) ->
  exec "wkhtmltopdf #{fullSourcePath} #{fullTargetPath}", callback

module.exports = { convert }

return

# Testing
convert "public/index.html", "public/pdfs/index.pdf", (err, res) ->
  console.log "Pdfified"
  console.log "Error", err
  console.log "Result", res
