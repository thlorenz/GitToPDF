sys = require 'sys'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec
fu = require './lib/fileutils'
inlinecss = require './lib/inlinecss.coffee'
Seq = require 'seq'
_ = require 'underscore'

theme = "desert"

results_dir = "/Users/tlorenz/Dropboxes/Gmail/Dropbox/dev/javascript/node/gittopdf/"
source_dir = fu.cleanPath "~/dev/js/node/sourcetopdf/test"

project_name = source_dir.split('/').pop()
target_dir = results_dir

compareIgnoreCase = (a, b) ->
  au = a.toUpperCase()
  bu = b.toUpperCase()
  if (au == bu) then return 0
  if (au > bu) then return 1
  return -1

cleanBody = (body) ->
    lines = body.split '\n'
    shortenedLines = lines.map((x) -> if (x.length > 200) then '' else x)
    return shortenedLines.join '\n'

htmlify = (full_source_path, full_target_path, callback) ->
  fs.readFile full_source_path, (err, data) ->
    console.log "Res", data.toString()
    content = data.toString()
    args = "
      -
      -U .conversionrc
      -c \"TOhtml\"
      -c \"w #{full_target_path}\"
      -c \"qa!\" 
      "
    args = '-'

    exec "echo \"#{content}\""
    exec "echo \"#{content}\" | mvim #{args}", callback

extractHtml = (fullpath, name, depth, foldername, folderfullname, isFirstFileInFolder, cb) ->

  inlinecss fullpath, './lib', (err, data) ->
    if err
      cb(null, null)
      console.log "ExtractHtml - error encountered, returning"
      return

    body_rx = ///
                  \<body(.|\r|\n)*\>
                    ((.|\r|\n)+)
                  \</body\>
              ///
    match = body_rx.exec data
    body = match[0]

    folderHeader = if isFirstFileInFolder
        """
          <h#{depth}>#{foldername}</h#{depth}>
          <span>(#{folderfullname})</span><br/><br/>
        """
    else
      ''

    cb null, {
      fullname: "#{folderfullname}/#{name}",
      depth,
      html: """
              <span>#{folderHeader}</span><br\>
              <h#{depth + 1}>#{name}</h#{depth + 1}>
              <span>(#{folderfullname})</span><br\>
              #{body}
            """
    }


ignoredFiles = ['jquery-1.2.6.min.js', '.gitignore', '.npmignore', '.DS_Store', 'test.pdf', 'inlined.html' ]
ignoredFolders = [ '.git', 'node_modules', 'reading' ]
ignoredExts = ['.sh']

convertSourceToHtml = (done) ->
  fu.getFoldersRec source_dir, { ignoredFiles, ignoredFolders, ignoredExts, fullname: project_name }, (err, res) ->

    mapFiles = (folder) ->
      targetfolder = path.join target_dir, folder.fullname

      isFirstFileInFolder = true
      rootFiles = folder.files
        .sort(compareIgnoreCase)
        .map (x) ->
          mappedFile = {
            isFirstFileInFolder
            foldername: folder.name
            folderfullname: folder.fullname
            name: x
            sourcepath : path.join folder.fullPath, x
            targetpath : path.join targetfolder, x + '.html'
            targetfolder
            depth: folder.depth + 1 }
          isFirstFileInFolder = false
          return mappedFile

      subFiles = folder.folders.map(mapFiles)
      _(rootFiles.concat(subFiles)).flatten()
        
    mappedFiles = mapFiles res

    process.stdout.write "Converting #{mappedFiles.length} files to html: "

    Seq(mappedFiles)
      .seqEach((x) -> fu.createFolder x.targetfolder, (err) => this(err, x))
      .seqEach((x) ->
        htmlify x.sourcepath, x.targetpath, (err, res) =>
          process.stdout.write "."
          this(err, mappedFiles)
      )
      .seq((x) -> done(null, mappedFiles))

readHtmlFiles = (done) ->
  htmlDocs = []
    
  compareDocs = (a, b) ->
    if (a.depth == b.depth) then return compareIgnoreCase(a.fullname, b.fullname)
    if (a.depth > b.depth) then return 1 else return -1

  Seq()
    .seq(-> convertSourceToHtml this)
    .seq((res) -> process.stdout.write " OK"; this(null, res))
    .seq((res) -> process.stdout.write "\nProcessing html: "; this(null, res))
    .flatten()
    .seqMap((x) ->
      extractHtml(x.targetpath, x.name, x.depth, x.foldername, x.folderfullname, x.isFirstFileInFolder, (err, res) =>
        if (err)
          console.log "WARN: Unable to extract html from", x.targetpath
          this(err, null)
        else
          process.stdout.write "."
          this(err, res)
      )
    )
    .parEach((x) -> htmlDocs.push x; this())
    .seq(-> process.stdout.write " OK"; this())
    .seq(->
      content = _(htmlDocs)
        .chain()
        .filter((x) -> x != null)
        .sort(compareDocs)
        .pluck('html')
        .value()
        .join('<br/>')

      res = """
              <!DOCTYPE html> 
              <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en-us"> 
              <head> 
                <meta http-equiv="content-type" content="text/html; charset=utf-8" /> 
                <title>Generated with GitToPdf</title> 
              </head>
              <body>
                #{content}
              </body>
            """

      fs.writeFile(path.join(target_dir, 'code.html'), res, this)
    )
    .seq(-> done(null, null))
    .catch((err) -> console.log "Error: ", err)

readHtmlFiles( -> console.log "\nEverything OK")
