exec = require('child_process').exec
Seq = require 'seq'

fu = require './fileutils'
inlinecss = require './inlinecss.coffee'
wrapper = require './wrapper'
coreConverter = require './coreConverter.coffee'

pipeThruVimAndWriteHtml = (full_source_path, full_target_path, columns, callback) ->
  args = "
    -U .conversionrc
    -c \"set columns=#{columns}\"
    -c \"TOhtml\"
    -c \"w #{full_target_path}\"
    -c \"qa!\" 
    "
  exec "mvim #{args} #{full_source_path}", callback

inlineCssAndExtractBody = (fullpath, cb) ->

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

    cb null, body

writeHtmlFilesFromSourceFiles = (config, callback) ->

  coreConverter.collectFilesToConvert config, (err, mappedFiles) ->

    process.stdout.write "Converting #{mappedFiles.length} files to html: "

    Seq(mappedFiles)
      .seqEach((x) -> fu.createFolder x.targetfolder, (err) => this(err, x))
      .seqEach((x) ->
        # Wrap lines in this file if needed, otherwise this will just return the original file path
        wrapper.wrapFile x.sourcepath, config.columns, (err, fullpath) =>
          x.sourcepath = fullpath
          this(null, x)
      )
      .seqEach((x) ->
        pipeThruVimAndWriteHtml x.sourcepath, x.targetpath, config.columns, (err, res) =>
          process.stdout.write "."
          this(err, mappedFiles)
      )
      .seq((x) -> callback(null, mappedFiles))

convertToHtmlDocs = (config, callback) ->

  htmlDocs = []

  Seq()
    .seq(-> writeHtmlFilesFromSourceFiles config, this)
    .seq((res) -> process.stdout.write " OK"; this(null, res))
    .seq((res) -> process.stdout.write "\nProcessing html: "; this(null, res))
    .flatten()
    .seqMap((x) ->
      inlineCssAndExtractBody(x.targetpath, (err, body) =>
        if (err)
          console.log "WARN: Unable to extract html from", x.targetpath
          this(err, null)
        else
          htmlDoc = coreConverter.createHtmlDoc(x.name, x.depth, x.foldername, x.folderfullname, x.isFirstFileInFolder, body)
          process.stdout.write "."
          
          this(err, htmlDoc)
      )
    )
    .parEach((x) -> htmlDocs.push x; this())
    .seq(-> callback(null, htmlDocs))

createHtmlPage = (content) ->
  """
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

module.exports = { convertToHtmlDocs, createHtmlPage }
