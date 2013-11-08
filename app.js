var express = require('express'),
    persona = require('express-persona'),
    mongoose = require('mongoose');

// Connect to MongoDB and define User scheme
mongoose.connect('mongodb://localhost/luminosity');
var db = mongoose.connection;

var UserScheme = new mongoose.Schema({
  id: 'string',
  email: 'string',
  last_login: 'Date'
});
var User = mongoose.model('User', UserScheme);

// Create and configure Express app
var app = express();
app.configure(function(){
  app.use(express.logger());
  app.use(express.cookieParser(process.env.LUMINOSITY_SESSION_SECRET));
  app.use(express.cookieSession());
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/app'));
});

// Setup Mozilla Persona for authentication

// Query user in database and create if its a new user
function getUser(email) {
  User.update({ email: email }, { email: email, last_login: new Date() }, {upsert: true}, function() {});
}

// Callback after response from Persona servers
function verifyResponse(error, req, res, email) {
  var out;
  if (error) {
    out = { status: "failure", reason: error };
  } else {
    getUser(email);
    out = { status: "okay", email: email };
  }
  res.json(out);
}

var audience = (process.env.PORT === undefined) ? 'http://0.0.0.0:3000' : 'http://luminosity.nodejitsu.com/';
persona(app, {audience: audience, verifyResponse: verifyResponse});

// Example of JSON request requiring authentication
app.get('/data', ensureAuthenticated, function(req, res) {
  res.json({key: 'value'});
});

var port = process.env.PORT || 3000;
app.listen(port, function() {
  console.log("Listening on " + port);
});

// Help middleware function to check authentication status
function ensureAuthenticated(req, res, next) {
  if (req.session.email) { return next(); }
  res.json(null);
}
