const express = require('express');
const bodyParser = require('body-parser')
const multer = require('multer');
const upload = multer({dest: __dirname + '/public/uploads'});

const app = express();
const PORT = 3000;

const http = require('http').createServer(app);
const io = require('socket.io')(http);

app.use(express.static('public'));

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }))

// parse application/json
app.use(bodyParser.json())

app.get('/test', (req, res) => {
  res.json({ key: 'value' });
});

app.post('/upload', upload.single('photo'), (req, res) => {
  if (req.file) res.json(req.file);
  else throw 'error';
	console.log(req.file);
	io.emit('upload', req.file);
});

app.post('/sensor', function(req, res) {
  console.log(req.body);
  res.send(req.body);
});

io.on('connection', function(socket) {
  console.log('on connection');
  io.emit('welcome');

	socket.on('upload', function(msg) {
    io.emit('upload', msg);
    console.log('on upload');
  });
});

http.listen(PORT, () => {
  console.log('Listening at ' + PORT );
});
