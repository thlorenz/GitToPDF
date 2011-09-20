sys = require 'sys'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec
fu = require './lib/fileutils.coffee'
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
  exec "vim #{args}", callback

ignoredFiles = ['jquery-1.2.6.min.js', '.gitignore' ]
ignoredFolders = ['.git']

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

  console.log "Found #{mappedFiles.length} files."
  process.stdout.write "Converting to html: "
  Seq(mappedFiles)
    .seqEach((x) -> fu.createFolder x.targetfolder, (err) => this(err, x))
    .parEach((x) -> htmlify x.sourcepath, x.targetpath, (err, res) =>
      process.stdout.write "."
      this(err, res))
    .seq(-> console.log "\nHtml Conversion: OK")
