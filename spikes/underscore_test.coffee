_ = require 'underscore'

elements = [1,2,3,4,5,6,7,8,9]
scheduleElement = (elem, cb) ->
  timeout = Math.ceil(Math.random() * 300)
  setTimeout (-> cb(null, elem * 2)), timeout

# parallel
asyncEach = ->
  _(elements).asyncEach(
    (x, cb) -> scheduleElement x, (err, res) -> console.log(res); cb()
    (err) -> console.log "done")

asyncEachSeries = ->
  _(elements).asyncEachSeries(
    (x, cb) -> scheduleElement x, (err, res) -> console.log(res); cb()
    (err) -> console.log "done")

asyncMap = ->
  _(elements).asyncMap(
    (x, cb) -> scheduleElement x, cb
    (err, res) -> console.log "Mapped to ", res)

asyncMapSeries = ->
  _(elements).asyncMapSeries(
    (x, cb) -> scheduleElement x, cb
    (err, res) -> console.log "Mapped to ", res)

asyncReduce = ->
  _(elements).asyncReduce(0,
    (acc, x, cb) -> scheduleElement x, (err, res) -> cb(err, acc + res)
    (err, acc) -> console.log "Reduced to", acc)

mapReduce = ->
  map = (x, cb) -> scheduleElement x, cb

  printResult = (err, res) -> console.log "Reduced to", res

  reduce = (err, xs) ->
    _(xs).asyncReduce(0,
        (acc, x, cb) -> scheduleElement x, (err, res) -> cb(err, acc + res)
        printResult)

series = ->
  result = []
  _.series([
    (next) -> scheduleElement elements.pop(), (err, res) -> result.push res; next()
  ,
    (next) -> scheduleElement elements.pop(), (err, res) -> result.push res; next()
  ,
    (next) -> scheduleElement elements.pop(), (err, res) -> result.push res; next()
  ]
  , (err) -> console.log "Result", result)

parallel = ->
  result = []
  _.parallel([
    (next) -> scheduleElement elements.pop(), (err, res) -> result.push res; next()
  ,
    (next) -> scheduleElement elements.pop(), (err, res) -> result.push res; next()
  ,
    (next) -> scheduleElement elements.pop(), (err, res) -> result.push res; next()
  ]
  , (err) -> console.log "Result", result)

waterfall0 = ->
  ((finalcb) -> _.waterfall [ (callback) ->
      console.log "1"
      callback null, "one", "two"
    , (arg1, arg2, callback) ->
      console.log "2", arg1, arg2
      callback null, "three"
    , (arg1, callback) ->
      finalcb null, "DONE"
     ])((err, res) -> console.log res)

class Pipe

  constructor: (@stack = []) ->

  push: (res) -> @stack.push res; @

waterfall = ->
  ((finalcb) -> _.waterfall [ (cb) ->
    scheduleElement elements.pop(), (err, res) ->
      # Wrap reulst array inside a pipe object to prevent underscore from unflattening it to argument list
      cb(err, new Pipe [res])
  ,
    (pipe, cb) -> 
      console.log pipe
      scheduleElement elements.pop(), (err, res) -> cb(err, pipe.push res)
  ,
    (pipe, cb) -> scheduleElement elements.pop(), (err, res) -> finalcb(err, pipe.push res)
   ])((err, pipe) -> console.log pipe.stack)
  



waterfall()
