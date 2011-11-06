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

folderHeaderHtml = (foldername, folderfullname, depth) ->
  if foldername is '' and folderfullname is '' then ''

  """
    <h#{depth}>#{foldername}</h#{depth}>
    <span>(#{folderfullname})</span><br/><br/>
  """

createHtmlDoc = (name, extension, depth, foldername, folderfullname, isFirstFileInFolder, body) ->
  if folderfullname is foldername then foldername = ''

  # Instead of temp folder root we'll show the foldername as root
  afterRoot = folderfullname.indexOf '/'
  if afterRoot > 0
    folderfullname = folderfullname.substring afterRoot
  else
    folderfullname = ''

  folderHeader = if isFirstFileInFolder
    folderHeaderHtml foldername, folderfullname, depth
  else
    ''
# <span>#{folderHeader}</span><br/>
  html =
    """
      <h#{depth + 1}>#{name}</h#{depth + 1}>
      <span>(#{folderfullname})</span><br/>
      #{body}
    """

  {
    fullname: "#{folderfullname}/#{name}"
    folderfullname
    extension
    depth
    html
    isFirstFileInFolder
  }


createHtmlContent = (htmlDocs) ->
  listedHeaders = []

  injectFolderHeaders = (doc) ->
    neededParentHeaders = []
    folders = doc.folderfullname.split('/')

    if not doc.isFirstFileInFolder then folders.pop()

    depth = 1
    while folders.length > 0
      do ->
        depth++
        fullname = folders.join '/'
        if not _(listedHeaders).contains(fullname)
          neededParentHeaders.push(
            name: _(folders).last()
            fullname: fullname
            depth: depth)
        folders.pop()

    if not _(neededParentHeaders).isEmpty()
      parentHeaderHtml = neededParentHeaders
        .map((x) -> folderHeaderHtml x.name, x.fullname, x.depth)
        .join ('</br>')

      neededParentHeaders.forEach((x) -> listedHeaders.push(x.fullname))
      doc.html = parentHeaderHtml + doc.html

    listedHeaders.push doc.folderfullname

    doc

  _(htmlDocs)
    .chain()
    .filter((x) -> x != null)
    .sort((a, b) -> fu.comparePaths(a.fullname, b.fullname))
    .map(injectFolderHeaders)
    .pluck('html')
    .value()
    .join('<br/>')

module.exports = { collectFilesToConvert, createHtmlDoc, createHtmlContent }
