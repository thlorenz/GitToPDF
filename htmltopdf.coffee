PDF = require("node-wkhtml").pdf
  'margin-top': 10,
  'margin-bottom': 10,
  'margin-left': 10,
  'margin-right': 10 


new PDF( { url: "www.google.com" } ).convertAs "google.pdf", (err, stdout) ->
  if err
    console.log "Error", err
  else
    console.log "PDF Complete!", stdout



