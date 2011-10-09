socket = io.connect('http://localhost')

socket.on 'update', (data) ->
  $("#progressBar").attr "value", data.percent

