#!/usr/bin/env coffee

fs = require 'fs'
_ = require 'underscore'
url = require 'url'
http = require 'http'
sys = require 'sys'
colors = require 'colors'

port = 3000
log = (msg, params) -> console.log msg.blue, params or ""

handler = (req, res) ->
  reqUrl = url.parse req.url
  relPath = if reqUrl.pathname == "/" then "#{__dirname}/public/index.html" else "#{__dirname}#{reqUrl.pathname}"

  fs.readFile relPath, (err, data) ->
    if err
      log "Could not find", relPath
      res.writeHead 500
      return res.end "Error loading #{relPath}"
    else
      log "Serving: ", relPath
      contentType = "text/plain"

      isHtml = relPath.search(".html$") > 0
      isJavaScript = relPath.search(".js$") > 0

      if isHtml then contentType = "text/html"
      if isJavaScript then contentType = "text/javascript"

      res.writeHead 200, { 'Content-Type': contentType }
      res.end data


app = http.createServer(handler)
io = require('socket.io').listen(app)

app.listen port
log "App listening on", port

io.sockets.on 'connection', (socket) ->
  socket.emit 'update', { progess: 0 }
  socket.on 'response', (data) ->
    log "Client responded"
