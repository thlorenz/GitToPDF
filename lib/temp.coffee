# Generated from the javascript version via js2coffee for easier maintenance
# TODO: Improve code that is not truly CoffeeScript like

sys = require("sys")
fs = require("fs")
path = require("path")
defaultDirectory = "/tmp"
environmentVariables = [ "TMPDIR", "TMP", "TEMP" ]
findDirectory = ->
  i = 0
  
  while i < environmentVariables.length
    value = process.env[environmentVariables[i]]
    return fs.realpathSync(value)  if value
    i++
  fs.realpathSync defaultDirectory

generateName = (rawAffixes, defaultPrefix) ->
  affixes = parseAffixes(rawAffixes, defaultPrefix)
  now = new Date()
  name = [
    affixes.prefix,
    now.getYear(), now.getMonth(), now.getDay(),
    "-", process.pid, "-",
    (Math.random() * 0x100000000 + 1).toString(36),
    affixes.suffix
  ].join("")

  path.join exports.dir, name

parseAffixes = (rawAffixes, defaultPrefix) ->
  affixes =
    prefix: null
    suffix: null
  
  if rawAffixes
    switch typeof (rawAffixes)
      when "string"
        affixes.prefix = rawAffixes
      when "object"
        affixes = rawAffixes
      else
        throw ("Unknown affix declaration: " + affixes)
  else
    affixes.prefix = defaultPrefix
  affixes

mkdir = (affixes, callback) ->
  dirPath = generateName(affixes, "d-")
  fs.mkdir dirPath, 0700, (err) ->
    _gc.push [ "rmdirSync", dirPath ]  unless err
    callback err, dirPath  if callback

mkdirSync = (affixes) ->
  dirPath = generateName(affixes, "d-")
  fs.mkdirSync dirPath, 0700
  _gc.push [ "rmdirSync", dirPath ]
  dirPath

open = (affixes, callback) ->
  filePath = generateName(affixes, "f-")
  fs.open filePath, "w+", 0600, (err, fd) ->
    _gc.push [ "unlinkSync", filePath ]  unless err
    if callback
      callback err,
        path: filePath
        fd: fd

openSync = (affixes) ->
  filePath = generateName(affixes, "f-")
  fd = fs.openSync(filePath, "w+", 0600)
  _gc.push [ "unlinkSync", filePath ]
  path: filePath
  fd: fd

_gc = []
process.addListener "exit", ->
  for i of _gc
    try
      fs[_gc[i][0]] _gc[i][1]

exports.dir = findDirectory()
exports.mkdir = mkdir
exports.mkdirSync = mkdirSync
exports.open = open
exports.openSync = openSync
exports.path = generateName
