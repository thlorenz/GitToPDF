fs = require 'fs'
path = require 'path'
Seq = require 'seq'
_ = require 'underscore'

class Folder
  constructor: (@name, @fullPath, @depth, @files, @folders) ->

isDirectory = (path, callback) ->
  fs.stat path, (err, stats) ->
    if err
      console.log err
      callback err, null
      return
    callback null, stats.isDirectory()

isFile = (path, callback) ->
  fs.stat path, (err, stats) ->
    if err
      console.log err
      callback err, null
      return
    callback null, stats.isFile()

collectFilesAndFolders = (fullPath, config, callback) ->
  ctx = { }

  includedExts = config?.includedExts or []
  ignoredFiles = config?.ignoredFiles or []

  getFullPath = (x) -> path.join fullPath, x

  matchesExts = (x) ->
    _(includedExts).isEmpty() or
    _(includedExts).include(path.extname x)

  Seq()
    .seq(-> fs.readdir fullPath, this)
    .seq((items) -> ctx.items = items; this(null, items))

    # Collect Files
    .flatten()
    .seqFilter((x) ->
      isFile getFullPath(x), (err, isFile) =>
        isIncluded = (not _(ignoredFiles).include x) and matchesExts x
        this(null, isFile and isIncluded)
    )
    .unflatten()
    .seq((files) -> ctx.files = files; this(null, ctx.items))

    # Collect Folders
    .flatten().seqFilter((x) -> isDirectory getFullPath(x), this).unflatten()
    .seq((subFolders) -> callback(null, { files: ctx.files, subFolders }))

getFoldersRec = (fullPath, config, done) ->

  depth = config?.depth or 0
  name = config?.name or path.basename fullPath
  includedExts = config?.includedExts or []
  ignoredFiles = config?.ignoredFiles or []

  ctx = { }

  getFullPath = (x) -> path.join fullPath, x

  Seq()
    .seq(-> collectFilesAndFolders fullPath, config, this)
    .seq((res) ->
      # Call back immediately if there are no sub folders
      if res.subFolders.length == 0
        done null, new Folder(name, fullPath, depth, res.files, [])
      else
        ctx = res
        this(null, res.subFolders)
    )
    # Handle all subfolders
    .flatten().seqMap((folder) ->
      getFoldersRec(
        getFullPath(folder), {
          name: "#{name}/#{folder}"
          depth: depth + 1
          includedExts
          ignoredFiles
        },
        this)
    ).unflatten()
    .seq((folders) ->
      done null, new Folder(name, fullPath, depth, ctx.files, folders)
      this())

module.exports = { isFile, isDirectory, collectFilesAndFolders, getFoldersRec }
