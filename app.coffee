#!/usr/bin/env coffee

fs = require 'fs'
_ = require 'underscore'
url = require 'url'
http = require 'http'
sys = require 'sys'
path = require 'path'
colors = require 'colors'

port = 3000
log = (msg, params) -> console.log msg.blue, params or ""

handler = (req, res) ->
  reqUrl = url.parse req.url
  filename = if reqUrl.pathname == "/" then "index.html" else reqUrl.pathname

  extension = path.extname filename

  isHtml = extension == ".html"
  isJavaScript = extension == ".js"
  isCss = extension == ".css"
  isImage = extension == ".ico"

  publicFolder = path.join __dirname, "public"

  relPath = "NOTRESOLVED"
  if isHtml then relPath = path.join publicFolder, filename
  if isJavaScript then relPath = path.join publicFolder, "javascripts", filename
  if isCss then relPath = path.join publicFolder, "stylesheets", filename
  if isImage then relPath = path.join publicFolder, "images", filename

  fs.readFile relPath, (err, data) ->
    if err
      log "Could not find", relPath
      res.writeHead 500
      return res.end "Error loading #{relPath}"
    else
      log "Serving: ", relPath
      contentType = "text/plain"

      if isHtml then contentType = "text/html"
      if isJavaScript then contentType = "text/javascript"
      if isCss then contentType = "text/css"

      res.writeHead 200, { 'Content-Type': contentType }
      res.end data


app = http.createServer(handler)
io = require('socket.io').listen(app)

app.listen port
log "App listening on", port

io.sockets.on 'connection', (socket) ->
  socket.on 'convert', (args) ->
    log "Client requested to convert", args

  updateAction = (message) ->
    socket.emit 'action', { message }

  updateSuccess = (percent) ->
    socket.emit 'success', { percent }

  percent = 0
  setInterval ->
    updateAction "starting to work"
    percent += 5
  , 5000

  setInterval((-> updateSuccess percent), 3000)
