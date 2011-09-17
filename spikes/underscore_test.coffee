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
  _.series([
    (next) -> scheduleElement elements.pop(), (err, res) -> next(err, res)
  ,
    (next) -> scheduleElement elements.pop(), (err, res) -> next(err, res)
  ,
    (next) -> scheduleElement elements.pop(), (err, res) -> next(err, res)
  ]
  , (err, results) -> console.log "Result", results)

parallel = ->
  _.parallel([
    (next) -> scheduleElement elements.pop(), (err, res) -> next(err, res)
  ,
    (next) -> scheduleElement elements.pop(), (err, res) -> next(err, res)
  ,
    (next) -> scheduleElement elements.pop(), (err, res) -> next(err, res)
  ]
  , (err, results) -> console.log "Result", results)

class Pipe
  constructor: (@stack = []) ->
    @stack = [@stack] if not _(@stack).isArray()

  push: (result) ->
    @stack.push result
    @

waterfall = ->
  ((finalcb) -> _.waterfall [ (cb) ->
    scheduleElement elements.pop(), (err, res) ->
      # Wrap result array inside a pipe object to prevent it from being unflattened into argument list
      cb(err, new Pipe res)
  ,
    (pipe, cb) -> scheduleElement elements.pop(), (err, res) -> cb(err, pipe.push res)
  ,
    (pipe, cb) -> scheduleElement elements.pop(), (err, res) -> finalcb(err, pipe.push res)

   ])((err, pipe) -> console.log pipe.stack)

waterfall_mapreduce = ->
  _.waterfall [ (next) ->
    _(elements).asyncMap(
      (x, cb) -> scheduleElement(x, cb)
      (err, res) -> next(err, res)
    )
  ,
    (res, next) ->
     _(res).asyncReduce(0
        (acc, x, cb) -> scheduleElement x, (err, res) -> cb(err, acc + res)
        (err, res) -> next(err, res)
     )
   ,
     (res, _) -> console.log "Reduced", res
  ]
parallel()

