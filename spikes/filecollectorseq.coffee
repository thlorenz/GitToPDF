fs = require 'fs'
path = require 'path'
fu = require '../lib/fileutils.coffee'
Seq = require 'seq'

root_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf/bdd_nodechat"

class Folder
  constructor: (@name, @fullPath, @depth, @files, @folders) ->


collectFilesAndFolders = (fullPath, callback) ->
  ctx = { }

  getFullPath = (x) -> path.join fullPath, x

  Seq()
    .seq(-> fs.readdir fullPath, this)
    .seq((items) -> ctx.items = items; this(null, items))

    # Collect Files
    .flatten().seqFilter((x) -> fu.isFile getFullPath(x), this).unflatten()
    .seq((files) -> ctx.files = files; this(null, ctx.items))

    # Collect Folders
    .flatten().seqFilter((x) -> fu.isDirectory getFullPath(x), this).unflatten()
    .seq((subFolders) -> callback(null, { files: ctx.files, subFolders }))

getFoldersRec = (fullPath, name, depth, done) ->
  console.log "Processing: #{fullPath} [#{depth}]"
  collectFilesAndFolders fullPath, (err, res) -> console.log res

getFoldersRec(
  root_dir
  "root"
  0
  (err, res) ->
    console.log "Error", err
    console.log res
 )
