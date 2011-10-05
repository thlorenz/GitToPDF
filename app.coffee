#!/usr/bin/env coffee

_ = require 'underscore'
http = require 'http'
url = require 'url'

server = http.createServer (req, res) ->
  uri = url.parse req.url
  path = uri.pathname
  query = uri.query
  
  console.log "uri", uri
  console.log "path", path
  console.log "query", query


  res.writeHead 200, { 'Content-Type': 'text/plain' }
  res.end 'DONE'

server.listen 3000, 'localhost'

console.log 'Server running on localhost port 3000'

