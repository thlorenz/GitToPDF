Seq = require 'seq'

seqInfo = (seq) ->
  console.log "Stack: ", seq.stack
  console.log "Vars: ", seq.vars
  console.log "Args: ", seq.args

elements = [1,2,3,4,5,6,7,8,9]
scheduleElement = (elem, cb) ->
  timeout = Math.ceil(Math.random() * 300)
  setTimeout (-> cb(null, elem)), timeout



Seq(elements)
  .parEach((element) ->
    console.log "seq", seqInfo(@)
    scheduleElement element, @
  )
  .seqEach((res) ->
    console.log "Res", res
    @()
  )
