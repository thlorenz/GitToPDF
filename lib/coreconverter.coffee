fs = require 'fs'
path = require 'path'

Seq = require 'seq'
_ = require 'underscore'

fu = require './fileutils'

compareIgnoreCase = (a, b) ->
  au = a.toUpperCase()
  bu = b.toUpperCase()
  if (au == bu) then return 0
  if (au > bu) then return 1
  return -1

collectFilesToConvert = (config, callback) ->

  fu.getFoldersRec config.sourceFolder, config, (err, res) ->

    mapFiles = (folder) ->
      targetfolder = path.join(config.targetFolder, folder.fullname)

      isFirstFileInFolder = true

      rootFiles = folder.files
        .sort(compareIgnoreCase)
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
      <span>#{folderHeader}</span><br\>
      <h#{depth + 1}>#{name}</h#{depth + 1}>
      <span>(#{folderfullname})</span><br\>
      #{body}
    """

  { fullname: "#{folderfullname}/#{name}", extension, depth, html }

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

module.exports = { collectFilesToConvert, createHtmlDoc, createHtmlContent }
