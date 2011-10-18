fs = require 'fs'
path = require 'path'

Seq = require 'seq'
_ = require 'underscore'

fu = require './fileutils'

collectFilesToConvert = (config, callback) ->

  fu.getFoldersRec config.sourceFolder, config, (err, res) ->

    mapFiles = (folder) ->
      targetfolder = path.join(config.targetFolder, folder.fullname)

      isFirstFileInFolder = true

      rootFiles = folder.files
        .sort(fu.compareIgnoreCase)
        .map (x) ->
          mappedFile = {
            isFirstFileInFolder
            foldername: folder.name
            folderfullname: folder.fullname
            name: x
            extension: path.extname x
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
    

createHtmlDoc = (name, extension, depth, foldername, folderfullname, isFirstFileInFolder, body) ->

  folderHeader = if isFirstFileInFolder
      """
        <h#{depth}>#{foldername}</h#{depth}>
        <span>(#{folderfullname})</span><br/><br/>
      """
  else
    ''

  html =
    """
      <span>#{folderHeader}</span><br/>
      <h#{depth + 1}>#{name}</h#{depth + 1}>
      <span>(#{folderfullname})</span><br/>
      #{body}
    """

  { fullname: "#{folderfullname}/#{name}", extension, depth, html }


createHtmlContent = (htmlDocs) ->
  _(htmlDocs)
    .chain()
    .filter((x) -> x != null)
    .sort((a, b) -> fu.comparePaths(a.fullname, b.fullname))
    .pluck('html')
    .value()
    .join('<br/>')

module.exports = { collectFilesToConvert, createHtmlDoc, createHtmlContent }

