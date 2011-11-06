fs = require 'fs'
path = require 'path'
Seq = require 'seq'
_ = require 'underscore'


# Replaces problematic characters in path
cleanPath = (path) ->
  if (path.indexOf '~') is 0
    path = process.env.HOME + path.substr(1)

  # Escape all spaces
  path = path.replace(///\s///g, '\\ ')

  return path

class Folder
  constructor: (@name, @fullname, @fullPath, @depth, @files, @folders) ->
    @fullPath = cleanPath @fullPath

# Creates a folder for the given full path unless it exists already
createFolder = (full_path, callback) ->
  path.exists full_path, (path_exists) ->
    if not path_exists
      mode = 0777
      fs.mkdir full_path, mode, (err, res) ->
        callback(err)
    else
      callback(null)

# Returns true if the given path points at a directory, otherwise false
isDirectory = (path, callback) ->
  fs.stat path, (err, stats) ->
    if err
      console.log err
      callback err, null
      return
    callback null, stats.isDirectory()

# Returns true if the given path points at a file, otherwise false
isFile = (path, callback) ->
  fs.stat path, (err, stats) ->
    if err
      console.log err
      callback err, null
      return
    callback null, stats.isFile()

# Collects all files and sub folders for the given path
# Calls back with { files: [ .. ], subFolders: [ .. ] }
collectFilesAndFolders = (fullPath, config, callback) ->
  ctx = { }

  ignoredExts = config?.ignoredExts or []
  ignoredFiles = config?.ignoredFiles or []
  ignoredFolders = config?.ignoredFolders or []

  getFullPath = (x) -> path.join fullPath, x

  matchesExts = (x) ->
    _(ignoredExts).isEmpty() or
    not _(ignoredExts).include(path.extname x)

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
    .flatten()
    .seqFilter((x) ->
      isDirectory getFullPath(x), (err, isDir) =>
        isIncluded = not _(ignoredFolders).include x
        this(null, isDir and isIncluded)
    )
    .unflatten()
    .seq((subFolders) -> callback(null, { files: ctx.files, subFolders }))

# Collects all files and folders for the given path recursively
# Returns with tree of Folder object (see top of file)
# config may contain:
#   depth: folder depth
#   name:  name to give to folder, by default last folder of full path is used
#   ignoredExts: extensions of files to be ignored, by default none are ignored
#   ignoredFiles: files to be ignored, by default no files are ignored
#   ignoredFolders: folder to be ignored in the form of 'parent/child', by default no folder are ignored
getFoldersRec = (fullPath, config, done) ->

  depth = config?.depth or 0
  name = config?.name or path.basename fullPath
  fullname = config?.fullname or fullPath
  ignoredExts = config?.ignoredExts or []
  ignoredFiles = config?.ignoredFiles or []
  ignoredFolders = config?.ignoredFolders or []

  ctx = { }

  getFullPath = (x) -> path.join fullPath, x

  Seq()
    .seq(-> collectFilesAndFolders fullPath, config, this)
    .seq((res) ->
      # Call back immediately if there are no sub folders
      if res.subFolders.length == 0
        done null, new Folder(name, fullname, fullPath, depth, res.files, [])
      else
        ctx = res
        this(null, res.subFolders)
    )
    # Handle all subfolders
    .flatten().seqMap((folder) ->
      process.nextTick =>
        getFoldersRec(
          getFullPath(folder), {
            name: folder
            fullname: "#{fullname}/#{folder}"
            depth: depth + 1
            ignoredExts
            ignoredFiles
            ignoredFolders
          },
          this)
    ).unflatten()
    .seq((folders) ->
      done null, new Folder(name, fullname, fullPath, depth, ctx.files, folders)
      this())

compareIgnoreCase = (a, b) ->
  au = a.toUpperCase()
  bu = b.toUpperCase()
  if (au == bu) then return 0
  if (au > bu) then return 1
  return -1

# Compares two filepaths and returns:
# -1 if the first path should be sorted before the second path
#  1 if the first path should be sorted after the second path
comparePaths = (a, b) ->

  as = a.split '/'
  bs = b.split '/'

  lenA = as.length
  lenB = bs.length

  minLength = if lenA > lenB then lenB else lenA

  result = 0
  index = 0
  while index < minLength and result == 0
    result = compareIgnoreCase(as[index], bs[index])
    index++

  return result if result != 0
  return  1     if lenA < lenB
  return -1

module.exports = {
  cleanPath
  createFolder
  isFile
  isDirectory
  collectFilesAndFolders
  getFoldersRec
  compareIgnoreCase
  comparePaths
}
