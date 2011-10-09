(function() {
  var log, socket;
  log = function(msg, params) {
    console.log(msg.blue, params || "");
  };
  socket = io.connect('http://localhost');
  socket.on('update', function(data) {
    log("Data:", data);
    return socket.emit('response', {
      my: 'data'
    });
  });
}).call(this);
