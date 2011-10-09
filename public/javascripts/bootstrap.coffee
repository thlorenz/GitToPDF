log = (msg, params) -> console.log msg.blue, params or ""

socket = io.connect('http://localhost')

socket.on 'update', (data) ->
  log "Data:", data
  socket.emit('response', { my: 'data' })
