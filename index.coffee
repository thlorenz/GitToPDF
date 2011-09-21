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

ignored_dirs = [ '.git', 'node_modules' ]

htmlify = (full_source_path, full_target_path, callback) ->
  args = "-c \"colo #{theme}\" -c \"TOhtml\" -c \"w #{full_target_path}\" -c \"qa!\" #{full_source_path}"
  exec "mvim #{args}", callback

extractHtml = (fullpath, title, depth, cb) ->
  inlinecss fullpath, './lib', (err, data) ->
    if err
      console.log "Error", err
      throw err

    title_rx = ///
      \<title\>
        ((.|\r|\n)+)
      \</title\>
              ///

    body_rx = ///
      \<body(.|\r|\n)*?\>
        ((.|\r|\n)+)
      \</body\>
              ///
    match = body_rx.exec data
    body = match[0]

    cb null, { title, depth, html: "<h#{depth}>#{title}</h#{depth}><br\>#{body}" }


ignoredFiles = ['jquery-1.2.6.min.js', '.gitignore' ]
ignoredFolders = ['.git']

convertSourceToHtml = (done) ->
  fu.getFoldersRec source_dir, { ignoredFiles, ignoredFolders }, (err, res) ->

    mapFiles = (folder) ->
      targetfolder = path.join target_dir, folder.name

      rootFiles = folder.files.map (x) -> {
        name: "#{folder.name}/#{x}"
        sourcepath : path.join source_dir, x
        targetpath : path.join targetfolder, x + '.html'
        targetfolder
        depth: folder.depth }

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
  Seq()
    .seq(-> convertSourceToHtml this)
    .seq((res) -> console.log "\nHtml Conversion: OK"; this(null, res))
    .flatten()
    .parMap((x) -> extractHtml(x.targetpath, x.name, x.depth + 1, this))
    .parEach((x) ->
      process.stdout.write "."
      htmlDocs.push x
      this(null, null)
    )
    .seq(->
      console.log "Reading Html: OK"
      res = _(htmlDocs).chain()
        .sortBy((x) -> x.depth)
        .pluck('html')
        .reduce(((acc, x) -> "#{acc}<br/><br/>#{x}"), "")
        .value()

      fs.writeFile(path.join(target_dir, 'code.html'), res, this)
    )
    .seq(-> done(null, null))
    .catch((err) -> console.log "Error: ", err)

readHtmlFiles( -> console.log "DONE")
  
