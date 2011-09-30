fs = require 'fs'
Seq = require 'Seq'

fu = require './fileutils'
wrapper = require './wrapper'
coreConverter = require './coreConverter.coffee'
highlight = require './gorbatchevhelper.coffee'

createHtmlPage = (content, config) ->
  root = fu.cleanPath "~/dev/js/node/sourcetopdf/lib/syntaxhighlighter"
  highlight.highlightHtml root, content

convertToHtmlDocs = (config, callback) ->

  getBrush = (extension) ->

    # Map similar syntaxes to known ones
    map =
      'json'    : 'js'
      'coffee'  : 'python'
      'groovy'  : 'python'
      'txt'     : 'text'
      'md'      : 'text'
      'markdown': 'text'
      'key'     : 'text'


    brush = extension.substr 1
    brush = map[brush] or brush

  contentToHtmlDoc = (x) ->

    wrapped = wrapper.wrapContent x.code, config.columns
    
    brush = getBrush x.info.extension

    body = highlight.codeToHtml(brush, wrapped.content)

    coreConverter.createHtmlDoc(
      x.info.name,
      x.info.extension,
      x.info.depth,
      x.info.foldername,
      x.info.folderfullname,
      x.info.isFirstFileInFolder,
      body)

  htmlDocs = []

  Seq()
    .seq(-> coreConverter.collectFilesToConvert config, this)
    .flatten()
    .parMap((info) ->
      fs.readFile info.sourcepath, (err, data) =>
        this(null, { info, code: data.toString() })
    )
    .parEach((res) ->
      htmlDoc = contentToHtmlDoc res
      
      htmlDocs.push htmlDoc
      process.stdout.write "."
      this(null, htmlDocs)
    )
    .seq((docs) -> callback(null, htmlDocs))

module.exports = { convertToHtmlDocs, createHtmlPage }

return

# Test Area
columns = 70

ignoredFiles = ['jquery-1.2.6.min.js', '.gitignore', '.npmignore', '.ds_store', 'test.pdf', 'inlined.html' ]
ignoredFolders = [ '.git', 'node_modules', 'reading' ]
ignoredExts = ['.sh']

results_dir = "/users/tlorenz/dropboxes/gmail/dropbox/dev/javascript/node/gittopdf/"
sourceFolder = fu.cleanPath "~/dev/js/node/sourcetopdf/test"

project_name = sourceFolder.split('/').pop()
targetFolder = results_dir

config = {
  ignoredFiles
  ignoredFolders
  ignoredExts
  sourceFolder
  targetFolder
  columns
  fullname: project_name
}

convertToHtmlDocs config, (err, docs) -> console.log docs

