sys = require 'sys'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec
fu = require './lib/fileutils.coffee'

theme = "desert"

results_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf"
source_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/bdd_nodechat"

project_name = source_dir.split('/').pop()
target_dir = path.join results_dir, project_name

ignored_dirs = [ '.git' ]

createFolder = (full_path, callback) ->
  path.exists full_path, (path_exists) ->
    if not path_exists
      mode = 0777
      fs.mkdir full_path, mode, ->
        console.log "Created folder: ", full_path
        callback()
    else
      callback()

htmlify = (full_source_path, full_target_path, callback) ->
  args = "-c \"colo #{theme}\" -c \"TOhtml\" -c \"w #{full_target_path}\" -c \"qa!\" #{full_source_path}"
  exec "vim #{args}", callback

readdirRec = (folder, called_from_root, callback) ->
  queries = 0
  files = []
 
  fs.readdir folder, (err, filenames) ->
    if err then callback err, null

    # keep track of how many filenames (some may be directories) we need to examine
    remaining_filenames = filenames.length

    callback_when_complete = ->

      if remaining_filenames is 0 and queries is 0
        callback null, { files: files }


    for filename in filenames
      do (filename) ->

        fullpath = path.join(folder, filename)
        fu.isDirectory fullpath, (err, isDir) ->
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

        fu.isFile fullpath, (err, isF) ->
          files.push fullpath unless err or not isF
          if isF then remaining_filenames--
          callback_when_complete()

createFolder results_dir, ->
  readdirRec source_dir, true, (err, res) ->
    console.log "Found #{res.files.length} files"

    remaining_files = res.files.length
    for file in res.files
      do (file) ->
        folder = (path.dirname file).replace(source_dir, target_dir)
        filename = path.basename(file) + '.html'
        full_target_path = path.join folder, filename

        console.log "Creating html for:\n#{file} as:\n#{full_target_path}"
        createFolder folder, ->
          htmlify file, full_target_path, ->
            remaining_files--
            file_name = path.basename file
            console.log "Finished #{file_name}, #{remaining_files} more files to go"



