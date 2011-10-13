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
pdfsFolder = path.join publicFolder, "pdfs"

handler = (req, res) ->
  reqUrl = url.parse req.url
  filename = if reqUrl.pathname == "/" then "index.html" else reqUrl.pathname

  extension = path.extname filename

  isHtml = extension == ".html"
  isJavaScript = extension == ".js"
  isCss = extension == ".css"
  isImage = extension == ".ico"


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

  updateAction = (message) ->
    socket.emit 'action', { message }

  updateSuccess = (percent) ->
    socket.emit 'success', { percent }

  socket.on 'convert', (args) ->
    log "Client requested to convert", args

    percent = 0
    url = args.url

    name = path.basename(url).split('.')[0]
    htmlFileName = "#{name}.html"
    pdfFileName = "#{name}.pdf"

    updateAction "git clone #{url} #{name}"

    cloneTmpFolder = ""
    htmlTmpFolder = ""
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

        gitclone.clone url, cloneTmpFolder, this
      )
      .seq((data) ->
        log "Data", data

        percent += 30
        updateSuccess percent

        updateAction "Converting to html ..."

        converter.convertToHtmlPage({
          sourceFolder: cloneTmpFolder
          targetFolder: htmlTmpFolder
          targetFileName: htmlFileName}, this)
      )
      .seq(->
        percent += 20
        updateSuccess percent
        
        htmlPath = path.join htmlTmpFolder, htmlFileName
        pdfPath = path.join pdfsFolder, pdfFileName

        log "Converting #{htmlPath} to #{pdfPath}"
        updateAction "Converting #{htmlFileName} to #{pdfFileName} ..."

        htmltopdf.htmlToPdf htmlPath, pdfPath, this
      )
      .seq(->
        percent += 30
        updateSuccess percent

        log "Deleting temp folder"
        updateAction "Cleaning up ..."

        rimraf cloneTmpFolder, this
      )
      .seq(->
        percent += 10
        rimraf htmlTmpFolder, this
      )
      .seq(->
          percent = 100
          updateSuccess percent
      )
      .catch((err) -> log "Error", err)


