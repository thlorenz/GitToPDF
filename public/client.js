(function() {
  var socket;
  socket = io.connect('http://localhost');
  socket.on('update', function(data) {
    return console.log(data);
  });
}).call(this);
