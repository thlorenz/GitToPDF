sys = require 'sys'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

Seq = require 'seq'
_ = require 'underscore'

fu = require './lib/fileutils'
inlinecss = require './lib/inlinecss.coffee'
wrapper = require './lib/wrapper'

converter = require './lib/vimconverter.coffee'


columns = 70

ignoredFiles = ['jquery-1.2.6.min.js', '.gitignore', '.npmignore', '.DS_Store', 'test.pdf', 'inlined.html' ]
ignoredFolders = [ '.git', 'node_modules', 'reading' ]
ignoredExts = ['.sh']

results_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf/"
source_dir = fu.cleanPath "~/dev/js/node/sourcetopdf/test"

project_name = source_dir.split('/').pop()
target_dir = results_dir

config = { ignoredFiles, ignoredFolders, ignoredExts, fullname: project_name, columns }

compareIgnoreCase = (a, b) ->
  au = a.toUpperCase()
  bu = b.toUpperCase()
  if (au == bu) then return 0
  if (au > bu) then return 1
  return -1

collectFilesToConvert = (source_dir, config, callback) ->

  fu.getFoldersRec source_dir, config, (err, res) ->

    mapFiles = (folder) ->
      targetfolder = path.join target_dir, folder.fullname

      isFirstFileInFolder = true

      rootFiles = folder.files
        .sort(compareIgnoreCase)
        .map (x) ->
          mappedFile = {
            isFirstFileInFolder
            foldername: folder.name
            folderfullname: folder.fullname
            name: x
            sourcepath : path.join folder.fullPath, x
            targetpath : path.join targetfolder, x + '.html'
            targetfolder
            depth: folder.depth + 1 }
          isFirstFileInFolder = false
          return mappedFile

      subFiles = folder.folders.map(mapFiles)
      _(rootFiles.concat(subFiles)).flatten()
        
    mappedFiles = mapFiles res
    
    callback(null, mappedFiles)
    

createHtmlDoc = (name, depth, foldername, folderfullname, isFirstFileInFolder, body) ->

  folderHeader = if isFirstFileInFolder
      """
        <h#{depth}>#{foldername}</h#{depth}>
        <span>(#{folderfullname})</span><br/><br/>
      """
  else
    ''

  html =
    """
      <span>#{folderHeader}</span><br\>
      <h#{depth + 1}>#{name}</h#{depth + 1}>
      <span>(#{folderfullname})</span><br\>
      #{body}
    """

  { fullname: "#{folderfullname}/#{name}", depth, html }

createHtmlContent = (htmlDocs) ->
  compareDocs = (a, b) ->
    if (a.depth == b.depth) then return compareIgnoreCase(a.fullname, b.fullname)
    if (a.depth > b.depth) then return 1 else return -1

  _(htmlDocs)
    .chain()
    .filter((x) -> x != null)
    .sort(compareDocs)
    .pluck('html')
    .value()
    .join('<br/>')


convertToHtmlPage = (sourceFolder, callback) ->
    
  config.collectFilesToConvert = collectFilesToConvert
  config.createHtmlDoc = createHtmlDoc

  Seq()
    .seq(-> converter.convertToHtmlDocs(sourceFolder, config, this))
    .seq((htmlDocs) ->
      content = createHtmlContent htmlDocs
      page = converter.createHtmlPage content
      fs.writeFile(path.join(target_dir, 'code.html'), page, this)
    )
    .seq(-> callback(null, null))
    .catch((err) -> console.log "Error: ", err)

convertToHtmlPage(source_dir, -> console.log "\nEverything OK")
