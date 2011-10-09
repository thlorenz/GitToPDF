(function() {
  var socket;
  socket = io.connect('http://localhost');
  socket.on('update', function(data) {
    console.log("Data:", data);
    return socket.emit('response', {
      my: 'data'
    });
  });
}).call(this);
