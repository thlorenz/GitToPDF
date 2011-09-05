
sys = require 'sys'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

theme = "desert"

source_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/bdd_nodechat/"
target_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/sourcetopdf/html"

ignored_dirs = [ '.git' ]

createHtmlFolder = (full_path, callback) ->
  mode = 0777
  fs.mkdir full_path, mode, ->
    console.log "Created folder: ", full_path
    callback()

htmlify = (full_source_path, full_target_path, callback) ->
  args = "-c \"colo #{theme}\" -c \"TOhtml\" -c \"w #{full_target_path}\" -c \"qa\" #{full_source_path}"
  exec "mvim #{args}", callback

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

readdirRec = (folder, called_from_root, callback) ->
  queries = 0
  files = []
 
  fs.readdir folder, (err, filenames) ->
    if err then callback err, null

    # keep track of how many filenames (some may be directories) we need to examine
    remaining_filenames = filenames.length

    callback_when_complete = ->
      console.log "\n------------------------------------------------"
      console.log "Inside #{folder}\ngot called back have #{remaining_filenames} files and #{queries} queries left"

      if remaining_filenames is 0 and queries is 0
         
        console.log "Calling back from #{folder} with: "
        console.log(file) for file in files

        console.log "++++++++++++++++++++++++++++++++++++++++++++++++\n"

        callback null, { files: files }


    for filename in filenames
      do (filename) ->

        fullpath = path.join(folder, filename)
        isDirectory fullpath, (err, isDir) ->
          if not err and isDir
            remaining_filenames--
            
            if (called_from_root and ignored_dirs.indexOf(fullpath.split('/')?.pop()) >= 0)
              callback_when_complete()
            else
              # start another sub directory query
              queries++
              readdirRec fullpath, false, (err, res) ->
                # signal that a sub directory query has finished
                files.push(file) for file in res.files unless err
                queries--
                callback_when_complete()

        isFile fullpath, (err, isF) ->
          files.push fullpath unless err or not isF
          if isF then remaining_filenames--
          callback_when_complete()

readdirRec source_dir, true, (err, res) -> 
  console.log "Found #{res.files.length} files"
  
