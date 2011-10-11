#!/usr/bin/env coffee

fs = require 'fs'
path = require 'path'
Seq = require 'Seq'

fu = require './fileutils'
coreConverter = require './coreconverter'

vim = false

converter =
  if vim
    require './vimconverter'
  else
    require './gorbatchevconverter'

columns = 80

ignoredFiles = ['jquery-1.2.6.min.js', '.gitignore', '.npmignore', '.DS_STORE', 'test.pdf', 'inlined.html' ]
ignoredFolders = [ '.git', 'reading' ] # 'node_modules',
ignoredExts = ['.png', '.jpeg', '.jpg', '.gif', '.bmp', '.md', '.ico']

results_dir = "/users/tlorenz/dropboxes/gmail/dropbox/dev/javascript/node/gittopdf/"
sourceFolder = fu.cleanPath "~/dev/js/node/source/socket_io/"

project_name = sourceFolder.split('/').pop()
targetFolder = results_dir

config = {
  ignoredFiles
  ignoredFolders
  ignoredExts
  sourceFolder
  targetFolder
  columns
  fullname: project_name
}

convertToHtmlPage = (sourceFolder, callback) ->

  Seq()
    .seq(-> converter.convertToHtmlDocs(config, this))
    .seq((htmlDocs) ->
      content = coreConverter.createHtmlContent htmlDocs
      page = converter.createHtmlPage content
      fs.writeFile(path.join(targetFolder, 'code.html'), page, this)
    )
    .seq(-> callback(null, null))
    .catch((err) -> console.log "Error: ", err)

convertToHtmlPage(sourceFolder, -> console.log "\nEverything OK")
