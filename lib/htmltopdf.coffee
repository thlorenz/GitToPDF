exec = require('child_process').exec

htmlToPdf = (fullSourcePath, fullTargetPath, callback) ->
  exec "wkhtmltopdf #{fullSourcePath} #{fullTargetPath}", callback

module.exports = { htmlToPdf }

return

# Testing
htmlToPdf "public/index.html", "public/pdfs/index.pdf", (err, res) ->
  console.log "Pdfified"
  console.log "Error", err
  console.log "Result", res
