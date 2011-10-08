#!/usr/bin/env coffee

fs = require 'fs'
_ = require 'underscore'
url = require 'url'
http = require 'http'

handler = (req, res) ->
  fs.readFile "#{__dirname}/public/index.html",(err, data) ->
    if err
      console.log "Could not find index.html"
      res.writeHead 500
      return res.end 'Error loading index.html'
    else
      console.log "Serving index.html"
      res.writeHead 200
      res.end data

app = http.createServer(handler)
io = require('socket.io').listen(app)

app.listen 3000
console.log "App listening on 3000"

io.sockets.on 'connection', (socket) ->
  socket.emit 'update', { progess: 0 }
  socket.on 'response', (data) ->
    console.log "Client responded"
