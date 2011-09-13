fs = require 'fs'

exports.isDirectory = (path, callback) ->
  fs.stat path, (err, stats) ->
    if err
      console.log err
      callback err, null
      return
    callback null, stats.isDirectory()

exports.isFile = (path, callback) ->
  fs.stat path, (err, stats) ->
    if err
      console.log err
      callback err, null
      return
    callback null, stats.isFile()
