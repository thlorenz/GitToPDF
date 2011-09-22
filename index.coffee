sys = require 'sys'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec
fu = require './lib/fileutils'
inlinecss = require './lib/inlinecss.coffee'
Seq = require 'seq'
_ = require 'underscore'

theme = "desert"

results_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf/"
source_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/bdd_nodechat"

project_name = source_dir.split('/').pop()
target_dir = results_dir

compareIgnoreCase = (a, b) ->
  au = a.toUpperCase()
  bu = b.toUpperCase()
  if (au == bu) then return 0
  if (au > bu) then return 1
  return -1

htmlify = (full_source_path, full_target_path, callback) ->
  args = "-c \"colo #{theme}\" -c \"TOhtml\" -c \"w #{full_target_path}\" -c \"qa!\" #{full_source_path}"
  callback()
  # exec "mvim #{args}", callback

extractHtml = (fullpath, name, depth, foldername, isFirstFileInFolder, cb) ->
  inlinecss fullpath, './lib', (err, data) ->
    if err
      console.log "Error", err
      throw err

    body_rx = ///
      \<body(.|\r|\n)*?\>
        ((.|\r|\n)+)
      \</body\>
              ///
    match = body_rx.exec data
    body = match[0]

    
    folderHeader = if isFirstFileInFolder then "<h#{depth}>#{foldername}</h#{depth}><br/><br/>" else ''
    cb null, { fullname: "#{foldername}/#{name}", depth, html: "#{folderHeader}<h#{depth + 1}>#{name}</h#{depth + 1}>in <span>#{foldername}</span><br\>#{body}" }


ignoredFiles = ['jquery-1.2.6.min.js', '.gitignore' ]
ignoredFolders = [ '.git', 'node_modules', 'reading' ]

convertSourceToHtml = (done) ->
  fu.getFoldersRec source_dir, { ignoredFiles, ignoredFolders }, (err, res) ->

    mapFiles = (folder) ->
      targetfolder = path.join target_dir, folder.name

      isFirstFileInFolder = true
      rootFiles = folder.files
        .sort(compareIgnoreCase)
        .map (x) ->
          mappedFile = {
            isFirstFileInFolder
            foldername: folder.name
            name: x
            sourcepath : path.join folder.fullPath, x
            targetpath : path.join targetfolder, x + '.html'
            targetfolder
            depth: folder.depth + 1 }
          console.log "Mapped #{mappedFile.name}, isFirst #{isFirstFileInFolder}"
          isFirstFileInFolder = false
          return mappedFile

      subFiles = folder.folders.map(mapFiles)
      _(rootFiles.concat(subFiles)).flatten()
        
    mappedFiles = mapFiles res

    process.stdout.write "Converting #{mappedFiles.length} files to html: "

    Seq(mappedFiles)
      .seqEach((x) -> fu.createFolder x.targetfolder, (err) => this(err, x))
      .parEach((x) ->
        htmlify x.sourcepath, x.targetpath, (err, res) =>
          process.stdout.write "."
          this(err, mappedFiles)
      )
      .seq((x) -> done(null, mappedFiles))

readHtmlFiles = (done) ->
  htmlDocs = []
  toc = []
  Seq()
    .seq(-> convertSourceToHtml this)
    .seq((res) -> console.log "\nHtml Conversion: OK"; this(null, res))
    .flatten()
    .parMap((x) -> extractHtml(x.targetpath, x.name, x.depth, x.foldername, x.isFirstFileInFolder, this))
    .parEach((x) ->
      process.stdout.write "."
      htmlDocs.push x
      this(null, null)
    )
    .seq(->
      console.log "\nReading Html: OK"
      compareDocs = (a, b) ->
        if (a.depth == b.depth) then return compareIgnoreCase(a.fullname, b.fullname)
        if (a.depth > b.depth) then return 1 else return -1

      res = _(htmlDocs)
        .chain()
        .sort(compareDocs)
        .pluck('html')
        .value()
        .join('<br/><br/>')

      fs.writeFile(path.join(target_dir, 'code.html'), res, this)
    )
    .seq(-> done(null, null))
    .catch((err) -> console.log "Error: ", err)

readHtmlFiles( -> console.log "DONE")

###

        .sort((a, b) ->
        )
    .seq((res) ->
        _(res)
          .chain()
          .sortBy((x) -> x.name)
          .groupBy((x) -> x.foldername)
          .each((group) ->
            headerDepth = group[0].depth + 1
            group[0].header = "<h#{headerDepth}>#{group[0].foldername}</h#{headerDepth}><br/>")
        this(null, res)
    )
###
  
