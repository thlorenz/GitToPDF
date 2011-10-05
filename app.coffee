_ = require 'underscore'
express = require("express")
app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session(secret: "your secret here")
  app.use require("stylus").middleware(src: __dirname + "/public")
  app.use app.router
  app.use express.static(__dirname + "/public")

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

app.get "/", (req, res) ->
  res.render "index", title: "Git to PDFifier"

app.get "/convert", (req, res) ->
  query = req.query

  console.log "req.query: ", query
  refresh = (progress) -> res.render "convert", { title: "Git to PDFifier", repo: query.repo, progress }

  reportSuccess = (progress) ->
    lastMessage = progress.pop()
    progress.push "#{lastMessage} OK"
    console.log progress
  reportFailure = (progress) -> _(progress).last().concat "FAILED"

  progress = []
  progress.push "Locating git repository ... "
  refresh progress
  #reportProgress progress



app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
