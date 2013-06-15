
express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
port = 8080
url = "http://localhost:#{port}/"

if (process.env.SUBDOMAIN)
  url = "http://#{process.env.SUBDOMAIN}.jit.su/"

server.listen(port)
console.log "Express server listening on port #{port}"
console.log url

app.use( express.static("#{__dirname}/public") )

io.sockets.on('connection', (socket) ->
  console.log 'CONNECTION MADE!'
  
  # Note the use of io.sockets to emit but socket.on to listen
  io.sockets.emit "status",
    status: true

  socket.on 'sharing-data', (msg) ->
    socket.broadcast.emit 'request-to-share', msg.filename

  socket.on 'translation', (xOffset, yOffset) ->
    socket.broadcast.emit 'translation', xOffset, yOffset

  socket.on 'zoom', (zoom) ->
    socket.broadcast.emit 'zoom', zoom

  socket.on 'scale', (min, max) ->
    socket.broadcast.emit 'scale', min, max
)





# 
# # Setup new express application
# express = require("express")
# http    = require('http')
# 
# app     = express()
# server  = app.listen(process.env.PORT || 5000)
# io      = require('socket.io').listen(server)
# 
# app.configure ->
#   app.use(express.favicon())
#   app.use(express.logger('dev'))
#   app.use(express.bodyParser())
#   app.use(express.methodOverride())
# 
# app.configure('development', ->
#   app.use(express.errorHandler())
# )
# 
# console.log "listening on #{process.env.PORT}"
# app.use(express.static(__dirname + '/public'))
# 
# # # Set root url
# # app.get('/', (req, res) ->
# #   body = 'Luminosity WebSocket Server'
# #   res.setHeader('Content-Type', 'text/plain')
# #   res.setHeader('Content-Length', body.length)
# #   res.end(body)
# # )
# 
# # Heroku won't actually allow us to use WebSockets
# # so we have to setup polling instead.
# # https://devcenter.heroku.com/articles/using-socket-io-with-node-js-on-heroku
# # io.configure ->
# #   io.set "transports", ["xhr-polling"]
# #   io.set("polling duration", 10)
# 
# 
# io.sockets.on "connection", (socket) ->
#   
#   console.log 'CONNECTION MADE'
#   
#   # # Prints a list of connected clients
#   # console.log "CLIENTS", io.sockets.clients().map((client) -> return client.id)
#   
#   # Note the use of io.sockets to emit but socket.on to listen
#   io.sockets.emit "status",
#     status: true
#   
#   socket.on 'sharing-data', (msg) ->
#     socket.broadcast.emit 'request-to-share', msg.filename
#   
#   socket.on 'translation', (xOffset, yOffset) ->
#     socket.broadcast.emit 'translation', xOffset, yOffset
#   
#   socket.on 'zoom', (zoom) ->
#     socket.broadcast.emit 'zoom', zoom
#     
#   socket.on 'scale', (min, max) ->
#     socket.broadcast.emit 'scale', min, max
#   
#   # Listen for Peer Id
#   socket.on 'requestPeerId', (sessionId) ->
#     io.sockets.emit 'requestPeerId', sessionId
#   
#   socket.on 'sendPeerId', (sessionId, peerId) ->
#     io.sockets.emit 'sendPeerId',
#       sessionId: sessionId
#       peerId: peerId