socket = io.connect('http://localhost')
socket.on 'update', (data) ->
  console.log data
