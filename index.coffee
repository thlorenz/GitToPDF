sys = require 'sys'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec
fu = require './lib/fileutils.coffee'
Seq = require 'seq'

theme = "desert"

results_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf"
source_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/bdd_nodechat"

project_name = source_dir.split('/').pop()
target_dir = path.join results_dir, project_name

ignored_dirs = [ '.git' ]

htmlify = (full_source_path, full_target_path, callback) ->
  args = "-c \"colo #{theme}\" -c \"TOhtml\" -c \"w #{full_target_path}\" -c \"qa!\" #{full_source_path}"
  exec "vim #{args}", callback

ignoredFiles = ['jquery-1.2.6.min.js', '.gitignore' ]
ignoredFolders = ['.git']
fu.getFoldersRec source_dir, { ignoredFiles, ignoredFolders }, (err, res) ->

  mapFiles = (folder) ->
    targetfolder = path.join results_dir, folder
    rootFiles = folder.files.map (x) -> {
      sourcepath : path.join source_dir, x
      targetpath : path.join targetfolder, x + '.html'
      targetfolder
      depth: folder.depth }

    subFiles = folder.folders.map mapFiles
    rootFiles.concat subFiles
      
  mappedFiles = mapFiles res
  
  Seq(mappedFiles)
    .seqEach((x) ->
      console.log "Creating", x.targetfolder
      fu.createFolder x.targetfolder, => this(null, x)
    )
    .seqEach((x) -> htmlify x.sourcepath, x.targetfolder, this)
    .seq(-> console.log "DONE")
