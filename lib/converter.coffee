#!/usr/bin/env coffee

fs = require 'fs'
path = require 'path'
Seq = require 'Seq'

fu = require './fileutils'
coreConverter = require './coreconverter'

columns = 80

ignoredFiles = ['jquery-1.2.6.min.js', '.gitignore', '.npmignore', '.DS_STORE', 'test.pdf', 'inlined.html' ]
ignoredFolders = [ '.git', 'reading' ] # 'node_modules',
ignoredExts = ['.png', '.jpeg', '.jpg', '.gif', '.bmp', '.md', '.ico']

convertToHtmlPage = (config, callback) ->

  sourceFolder = fu.cleanPath config.sourceFolder
  targetFolder = fu.cleanPath config.targetFolder
  targetFileName = config.targetFileName

  project_name = sourceFolder.split('/').pop()

  converter =
    if config.useVim then require './vimconverter' else require './gorbatchevconverter'

  converterConfig = {
    ignoredFiles
    ignoredFolders
    ignoredExts
    sourceFolder
    targetFolder
    columns
    fullname: project_name
  }

  Seq()
    .seq(-> converter.convertToHtmlDocs(converterConfig, this))
    .seq((htmlDocs) ->
      content = coreConverter.createHtmlContent htmlDocs
      page = converter.createHtmlPage content
      fs.writeFile(path.join(targetFolder, targetFileName), page, this)
    )
    .seq(-> callback(null, null))
    .catch((err) -> console.log "Error: ", err)

module.exports = { convertToHtmlPage }

# return

# Testing

targetFolder = "/users/tlorenz/dropboxes/gmail/dropbox/dev/javascript/node/gittopdf/"
sourceFolder = "~/dev/js/node/source/socket_io"
targetFileName = "code.html"

convertToHtmlPage({ sourceFolder, targetFolder, targetFileName, useVim: false }, -> console.log "\nEverything OK")
