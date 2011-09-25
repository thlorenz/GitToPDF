fs = require 'fs'
path = require 'path'
Seq = require 'Seq'

fu = require './lib/fileutils'
coreConverter = require './lib/coreconverter.coffee'

converter = require './lib/vimconverter.coffee'

columns = 70

ignoredFiles = ['jquery-1.2.6.min.js', '.gitignore', '.npmignore', '.DS_Store', 'test.pdf', 'inlined.html' ]
ignoredFolders = [ '.git', 'node_modules', 'reading' ]
ignoredExts = ['.sh']

results_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf/"
sourceFolder = fu.cleanPath "~/dev/js/node/sourcetopdf/test"

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
