fs = require 'fs'
path = require 'path'
fu = require '../lib/fileutils.coffee'
_ = require 'underscore'

delay = (elem, cb) ->
  timeout = Math.ceil(Math.random() * 30)
  setTimeout (-> cb(null, elem)), timeout

root_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf/bdd_nodechat"

class Folder
  constructor: (@name, @fullPath, @depth, @files, @folders) ->

getFoldersRec = (fullPath, depth, done) ->
  console.log "Processing: #{fullPath} [#{depth}]"

  getFullPath = (x) -> path.join fullPath, x

  _.waterfall([
    # Get all folder items
    (next) -> fs.readdir fullPath, (err, res) -> next(null, res)
    # Filter files in folder
    (items, next) -> _(items).asyncFilter(
      (x, cb) -> fu.isFile getFullPath(x), (err, res) -> cb(res)
      (files) -> next(null, items, files)
    )
    # Keep track of files and filter raw folders
    (items, files, next) -> _(items).asyncFilter(
      (x, cb) -> fu.isDirectory getFullPath(x), (err, res) -> cb(res)
      (rawFolders) -> next(null, files, rawFolders)
    )
    # Map subfolders to folder object as well
    (files, rawFolders, next) ->
      console.log rawFolders
      if (rawFolders.length == 0)
        done null, null
      else
        _(rawFolders).asyncMapSeries(
          (x, cb) -> getFoldersRec(getFullPath(x), depth + 1, (err, res) -> cb(err, x, res))
          (err, name, folders) ->
            console.log "Error #{err} Name: #{name} Folders", folders
            next(err, new Folder(name, getFullPath(name), depth, files, folders))
        )
    (err, folders) -> done(err, folders)
  ])

getFoldersRec(
  root_dir
  0
  (err, res) ->
    console.log "Error", err
    console.log res
 )
