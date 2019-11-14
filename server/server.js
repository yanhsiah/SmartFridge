const express = require('express');
const bodyParser = require('body-parser')
const multer = require('multer');
const upload = multer({dest: __dirname + '/public/uploads'});

const app = express();
const PORT = 8900;

const http = require('http').createServer(app);
const io = require('socket.io')(http);

io.sockets.on('connection', function(socket) {
  console.log('a user connected');

  setTimeout(function() {
    socket.emit('welcome', 'welcome to the server');
    console.log('welcome message sent after 3 seconds');
  }, 3000);

  socket.on('update', function(payload) {
    console.log('update', payload);
  });
  socket.on('disconnect', function() {
    console.log('user disconnected');
  });
  socket.on('upload', function(msg) {
    io.emit('upload', msg);
    console.log('on upload');
  });
});

app.use(express.static('public'));

app.post('/upload', upload.single('photo'), (req, res) => {
  if (req.file) res.json(req.file);
  else throw 'error';
  console.log(req.file);
  io.emit('upload', req.file);
});

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }))

// parse application/json
app.use(bodyParser.json())

app.post('/sensor', function(req, res) {
  console.log(req.body);
  res.send(req.body);
});

http.listen(PORT, () => {
  console.log('Listening at ' + PORT );
});
