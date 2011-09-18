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

getFoldersRec = (name, fullPath, depth, done) ->
  ctx = { }

  getFullPath = (x) -> path.join fullPath, x

  Seq()
    .seq(-> collectFilesAndFolders fullPath, this)
    .seq((res) ->
      if res.subFolders.length == 0
        done null, { name, files: res.files, folders: [] }
        done null, new Folder(name, fullPath, depth, res.files, [])
      else
        ctx = res
        this(null, res.subFolders)
    )
    .flatten().seqMap((folder) ->
      getFoldersRec("#{name}/#{folder}", getFullPath(folder), depth + 1, this)
    ).unflatten()
    .seq((folders) ->
      done null, new Folder(name, fullPath, depth, ctx.files, folders)
      this())

getFoldersRec(
  "bdd_nodechat"
  root_dir
  0
  (err, res) ->
    console.log res
 )
