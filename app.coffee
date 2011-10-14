#!/usr/bin/env coffee

fs = require 'fs'
rimraf = require 'rimraf'
_ = require 'underscore'
url = require 'url'
http = require 'http'
sys = require 'sys'
path = require 'path'
colors = require 'colors'
Seq = require 'seq'
temp = require './lib/temp'
gitclone = require './lib/gitclone'
converter = require './lib/converter'
htmltopdf = require './lib/htmltopdf'


port = 3000
log = (msg, params) -> console.log msg.blue, params or ""

publicFolder = path.join __dirname, "public"
javascriptsFolder = path.join publicFolder, "javascripts"
styleSheetsFolder = path.join publicFolder, "stylesheets"
imagesFolder = path.join publicFolder, "images"
pdfsFolder = path.join publicFolder, "pdfs"

handler = (req, res) ->
  reqUrl = url.parse req.url
  filename = if reqUrl.pathname == "/" then "index.html" else reqUrl.pathname

  extension = path.extname filename

  relPath = "NOTRESOLVED"
  contentType = "text/plain"

  switch extension
    when ".html"
      relPath = path.join publicFolder, filename
      contentType = "text/html"
    when ".js"
      relPath = path.join javascriptsFolder, filename
      contentType = "text/javascript"
    when ".css"
      relPath = path.join styleSheetsFolder, filename
      contentType = "text/css"
    when ".ico"
      relPath = path.join imagesFolder, filename
    when ".pdf"
      relPath = path.join pdfsFolder, filename
      contentType = "application/pdf"

  fs.readFile relPath, (err, data) ->
    if err
      log "Could not find", relPath
      res.writeHead 500
      return res.end "Error loading #{relPath}"
    else
      log "Serving: ", relPath

      res.writeHead 200, { 'Content-Type': contentType }
      res.end data


app = http.createServer(handler)
io = require('socket.io').listen(app)

app.listen port
log "App listening on", port


io.sockets.on 'connection', (socket) ->

  updateAction = (message) ->
    socket.emit 'action', { message }

  updateSuccess = (percent) ->
    socket.emit 'success', { percent }

  updateCompletion = (pdfName) ->
    socket.emit 'complete', { pdfName }

  socket.on 'convert', (args) ->
    log "Client requested to convert", args

    repoUrl = args.url

    name = path.basename(repoUrl).split('.')[0]
    htmlFileName = "#{name}.html"
    pdfFileName = "#{name}.pdf"

    updateAction "git clone #{repoUrl} #{name}"

    cloneTmpFolder = ""
    htmlTmpFolder = ""
    pdfPath = ""

    Seq()
      .seq(-> temp.mkdir name, this)
      .seq((tmpFolder) ->
        cloneTmpFolder = tmpFolder
        log "Got Clone Temp", cloneTmpFolder

        temp.mkdir "#{name}_html", this
      )
      .seq((tmpFolder) ->
        htmlTmpFolder = tmpFolder
        log "Got Html Temp", htmlTmpFolder

        gitclone.clone repoUrl, cloneTmpFolder, this
      )
      .seq((data) ->
        log "Data", data

        updateSuccess 30

        updateAction "Converting to #{htmlFileName} ..."

        converter.convertToHtmlPage({
          sourceFolder: cloneTmpFolder
          targetFolder: htmlTmpFolder
          targetFileName: htmlFileName}, this)
      )
      .seq(->
        updateSuccess 50
        
        htmlPath = path.join htmlTmpFolder, htmlFileName
        pdfPath = path.join pdfsFolder, pdfFileName

        log "Converting #{htmlPath} to #{pdfPath}"
        updateAction "Converting #{htmlFileName} to #{pdfFileName} ..."

        htmltopdf.convert htmlPath, pdfPath, this
      )
      .seq(->
        updateSuccess 80

        log "Deleting temp folder"
        updateAction "Removing cloned folder ..."

        rimraf cloneTmpFolder, this
      )
      .seq(->
        updateSuccess 90
        updateAction "Removing html ..."
        rimraf htmlTmpFolder, this
      )
      .seq(->
        updateSuccess 100
        updateCompletion pdfFileName
      )
      .catch((err) -> log "Error", err)


