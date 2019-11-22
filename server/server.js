const express = require('express');
const bodyParser = require('body-parser')
const multer = require('multer');
const upload = multer({dest: __dirname + '/public/uploads'});
const spawn = require("child_process").spawn;

const app = express();
const PORT = 3000;

const http = require('http').createServer(app);
const io = require('socket.io')(http);

io.sockets.on('connection', function(socket) {
  console.log('a user connected');

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
  if (req.file) {
    console.log(req.file);
    io.emit('upload', req.file);

    var process = spawn('python',['./hello.py', req.file.path]);
    process.stdout.on('data', function(data) {
      res.send(data.toString());
    });
  }
  else throw 'error';
});

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }))

// parse application/json
app.use(bodyParser.json())

app.post('/sensor', function(req, res) {
  io.emit('snapshot');
  console.log(req.body);
  res.send(req.body);
});

http.listen(PORT, () => {
  console.log('Listening at ' + PORT );
});
