socket = io.connect('http://localhost')

socket.on 'update', (data) ->
  console.log "Data:", data
  socket.emit('response', { my: 'data' })
