fs = require 'fs'
path = require 'path'
Hash = require 'hashish'
Seq = require 'seq'
inlinecss = require './inlinecss.coffee'

# Utils
cleanPath = (path) ->
  if (path.indexOf '~') is 0
    return process.env.HOME + path.substr(1)
  return path

project_name = 'bdd_nodechat'


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
###
  fs.readFile fullpath, encoding='utf8', (err, data) ->
    if err
      console.log "Error", err
      throw err
###
extractHtml = (fullpath, cb) ->
  depth = 1
  inlinecss fullpath, (err, data) ->
    if err
      console.log "Error", err
      throw err

    title_rx = ///
      \<title\>
        ((.|\r|\n)+)
      \</title\>
              ///

    body_rx = ///
      \<body(.|\r|\n)*?\>
        ((.|\r|\n)+)
      \</body\>
              ///

    match = title_rx.exec data
    title = match[1]
    cutoffpoint = title.lastIndexOf(project_name) + project_name.length + 1
    title = title.substr cutoffpoint

    match = body_rx.exec data
    body = match[2]

    cb null, "<h#{depth}>#{title}</h#{depth}>\n#{body}"
    return

Seq(files)
  .seqMap((file) ->
    fullpath = cleanPath(path.join file.path, file.file_name)
    extractHtml fullpath, (err, res) =>
      file.html = res
      console.log res
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
  .seq((html) -> console.log html)

  .catch((err) -> console.log "Error: ", err)

###
single_file_path = path.join cleanPath(source_path), file_name


Seq().seq(->
  fs.readdir __dirname, this
).flatten().parEach((file) ->
  fs.stat __dirname + "/" + file, @into(file)
).seq ->
  sizes = Hash.map(@vars, (s) ->
  a   s.size
  )
  console.dir sizes

