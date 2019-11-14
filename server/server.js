const express = require('express');
const multer = require('multer');
const upload = multer({dest: __dirname + '/public/uploads'});

const app = express();
const PORT = 3000;

const http = require('http').createServer(app);
const io = require('socket.io')(http);

app.use(express.static('public'));

app.get('/test', (req, res) => {
  res.json({ key: 'value' });
});

app.post('/upload', upload.single('photo'), (req, res) => {
  if (req.file) res.json(req.file);
  else throw 'error';
	console.log(req.file);
	io.emit('upload', req.file);
});

io.on('connection', function(socket) {
  console.log('on connection');
  io.emit('welcome');

	socket.on('upload', function(msg) {
    io.emit('upload', msg);
    console.log('on upload');
  });
});

io.on('mobile', function(socket) {
  console.log('mobile');
});
io.on('1', function(socket) {
  console.log('1');
});


http.listen(PORT, () => {
  console.log('Listening at ' + PORT );
});
