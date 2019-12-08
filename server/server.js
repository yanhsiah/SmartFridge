const express = require('express');
const bodyParser = require('body-parser')
const multer = require('multer');
const upload = multer({dest: __dirname + '/public/uploads'});
const spawn = require("child_process").spawn;
const fs = require("fs");
const zerorpc = require("zerorpc");

const app = express();
const PORT = 3000;

const http = require('http').createServer(app);
const io = require('socket.io')(http);

const rpcClient = new zerorpc.Client();
rpcClient.connect("tcp://127.0.0.1:4242");

var cache = [];
var cameras = {};
var weight = 0.0;
var activity = false;

io.sockets.on('connection', function(socket) {
  console.log('a user connected');

  socket.on('camera_id', function (cameraId) {
    cameras[cameraId] = {
      'socket': socket,
      'motion': 0
    };
    console.log('camera ' + cameraId + ' is ready!');
  });

  socket.emit('welcome', cache);
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
    const fileType = '.jpg';
    fs.rename(req.file.path, req.file.path + fileType, err => {
      req.file.path = req.file.path + fileType;
      req.file.filename = req.file.filename + fileType;
      res.send(req.file);
      cache.push(req.file);
      rpcClient.invoke("getJson", req.file.path, req.file.path.replace(fileType, '_result' + fileType), function(error, cvres, more) {
        req.file.cv = cvres;
        console.log(cvres);
        io.emit('upload', req.file);
      });
    });
  }
  else throw 'error';
});

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }));

// parse application/json
app.use(bodyParser.json());

app.post('/sensor', function(req, res) {
  // io.emit('snapshot');
  const payload = req.body;
  const m1 = parseInt(payload.first_motion_sensor_status);
  const m2 = parseInt(payload.second_motion_sensor_status);
  const m3 = parseInt(payload.third_motion_sensor_status);
  const w1 = parseFloat(payload.first_weight_reading);
  const w2 = parseFloat(payload.second_weight_reading);
  const w3 = parseFloat(payload.third_weight_reading);
  const w4 = parseFloat(payload.fourth_weight_reading);
  console.log({ 'motion': [m1, m2, m3], 'weight': [w1, w2, w3, w4] });
  res.send({ 'motion': [m1, m2, m3], 'weight': [w1, w2, w3, w4] });

  const current_weight = Math.abs(w1 + w2) + Math.abs(w3 + w4);
  if (Math.abs(weight - current_weight) > 1.0) {
    activity = true;
  }
  weight = current_weight;

  if (!activity) return; // no activity no capture
  var captured = false;
  if (!captured && cameras['2']) {
    if (!m2 && cameras['2'].motion) {
      cameras['2'].socket.emit('snapshot');
      console.log('snapshot camera 222222222222');
      captured = true;
    }
  }
  if (cameras['2']) cameras['2'].motion = m2;
  if (!captured && cameras['1']) {
    if (!m1 && cameras['1'].motion) {
      cameras['1'].socket.emit('snapshot');
      console.log('snapshot camera 111111111111');
      captured = true;
    }
    cameras['1'].motion = m1;
  }
  if (cameras['1']) cameras['1'].motion = m1;
  if (!captured && cameras['3']) {
    if (!m3 && cameras['3'].motion) {
      cameras['3'].socket.emit('snapshot');
      console.log('snapshot camera 333333333333');
      captured = true;
    }
    cameras['3'].motion = m3;
  }
  if (cameras['3']) cameras['3'].motion = m3;
  if (captured) activity = false;
});

http.listen(PORT, () => { console.log('Listening at ' + PORT ); });

/*
{ first_motion_sensor_status: '0',
  second_motion_sensor_status: '0',
  third_motion_sensor_status: '0',
  first_weight_reading: '0.1',
  second_weight_reading: '-0.1',
  third_weight_reading: '0.3',
  fourth_weight_reading: '-0.3' }
*/
