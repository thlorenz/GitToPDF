fs = require 'fs'
path = require 'path'
_ = require 'underscore'

delay = (elem, cb) ->
  timeout = Math.ceil(Math.random() * 30)
  setTimeout (-> cb(null, elem)), timeout

rootFolder =
  [
    'root1'
    'root2'
    lib: ['lib1', 'lib2', 'lib3' ]
    modules:
      [
        underscore:
          [
            'index'
            lib: ['_lib1', '_lib2' ]
          ]
        '.DSStore'
      ]
  ]
class Folder
  constructor: (@name, @depth, @files, @folders) ->

getFoldersRec = (rawFolder, depth, done) ->
  console.log "analysing #{rawFolder}, depth #{depth}"
  _.series(
    {
      files: (gotFiles) -> _.waterfall([
        # Filter files in folder
        (next) -> _(rawFolder).asyncFilter(
          (x, cb) -> delay(_.isString(x), (err, res) -> cb(res))
          (files) -> next(null, files)
        )
        # Keep track of files and filter raw folders
        (files, next) -> _(rawFolder).asyncFilter(
          (x, cb) -> delay(not _.isString(x), (err, res) -> cb(res))
          (rawFolders) -> next(null, files, rawFolders)
        )
        # Map subfolders to folder object as well
        (files, rawFolders) ->
          _(rawFolders).asyncMapSeries(
            (x, cb) -> getFoldersRec((_.toArray x), depth + 1, (err, res) -> cb(res))
            (err, folders) -> gotFiles(null, new Folder depth, depth, files, folders)
          )
      ])
    }
    (err, res) -> done(null, res)
  )

getFoldersRec(
  rootFolder
  0
  (err, res) ->
    console.log res
 )
