es = require 'fs'
path = require 'path'
Hash = require 'hashish'
Seq = require 'seq'
inlinecss = require './inlinecss.coffee'
fu = require './fileutils.coffee'

# Utils
cleanPath = (path) ->
  if (path.indexOf '~') is 0
    return process.env.HOME + path.substr(1)
  return path

project_name = 'bdd_nodechat'
root_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf"

files = [
    path: '~/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf/bdd_nodechat',
    file_name: 'bootstrap.coffee.html'
,
    path: '~/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf/bdd_nodechat/spec',
    file_name: 'server_spec.coffee.html'
,
    path: '~/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf/bdd_nodechat/spec',
    file_name: 'server_specs_vows.coffee.html'
]





getAllSubFolders = (root_folder, depth, cb) ->
  sub_folders = []

  Seq()
    .seq(-> fs.readdir root_folder, this)
    .flatten()
    .seqFilter((file_name) -> fu.isDirectory (path.join root_folder, file_name), this)
    .seqEach((folder) ->
      if (folder is undefined)
        this()
      else
        full_path = path.join root_folder, folder
        console.log "Found folder", full_path
        getAllSubFolders full_path, depth + 1, (err, res) => this([path: full_path, depth: depth])
    )
    .seq((res) ->
      console.log "calling back with", res
      cb null,res)

getAllSubFolders root_dir, 0, (err, res) -> console.log "DONE", res





mapFilesToHtml = (files) ->
  Seq(files)
    .seqMap((file) ->
      fullpath = cleanPath(path.join file.path, file.file_name)
      extractHtml fullpath, (err, res) =>
        file.html = res
        @(err, file)
    )
    .seq(->
      @stack.sort (f0, f1) ->
        # shorter paths go first
        l0 = f0.path.length
        l1 = f1.path.length
        if (l0 is not l1) then return l0 - l1
        # if in same path we sort by filename
        return [f0, f1].map((f) -> f.file_name).sort()
      @(null, @stack)
    )
    .seq((sorted_files) ->
      aggregateHtml = "<body>\n"
      aggregateHtml = aggregateHtml.concat(sorted_files.map((f) -> f.html).join())
      aggregateHtml = aggregateHtml.concat("\n</body>")
      @(null, aggregateHtml)
    )
    .seq((html) -> fs.writeFile('code.html', html, this))
    .catch((err) -> console.log "Error: ", err)
