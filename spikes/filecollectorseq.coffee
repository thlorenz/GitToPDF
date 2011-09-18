fu = require '../lib/fileutils.coffee'
Seq = require 'seq'
_ = require 'underscore'

includedExts = ['.html']
ignoredFiles = ['.DS_Store']

root_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf/bdd_nodechat"


fu.getFoldersRec(
  "bdd_nodechat"
  root_dir
  0
  includedExts
  ignoredFiles
  (err, res) ->
    console.log res
 )
