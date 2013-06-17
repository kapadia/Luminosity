require('lib/setup')

{Controller} = require('spine')

Drop  = require('controllers/Drop')
Info  = require('lib/info')

class Luminosity extends Controller
  
  
  constructor: ->
    super
    
    @setBuild()
    
    # Initialize controllers
    @el = $('#luminosity')
    
    # Start socket and determine hostname and port for sockets
    if location.hostname is '0.0.0.0'
      socket = io.connect('http://localhost', {port: 8080})
    else
      socket = io.connect()
    
    # Initialize Drop controller with DOM element and socket
    drop = new Drop({el: @el, socket: socket})
    
    # Listen for share request
    # TODO: Make more elegant
    socket.on('request-to-share', (filename) ->
      answer = confirm "Would you like to collaborate on #{filename}?"
      drop.collaborateOn(filename) if answer
    )
    
    # Check for compatibility
    # TODO: Implement using css checked attribute (keeps styles outside of JS)
    if @browserCheck()
      drop.enable()
    else
      reqStyle = document.querySelector('.requirements').style
      reqStyle.display = 'block'
      reqStyle.opacity = 1
  
  # TODO: Double check all the native APIs that are used.
  browserCheck: ->
    
    # Check for native objects
    checkFile = File?
    checkFileReader = FileReader?
    checkFileList = FileList?
    checkDataView = DataView?
    checkBlob = Blob?
    checkWebWorker = Worker?
    
    # Check for WebGL and texture extension
    canvas = document.createElement('canvas')
    context = canvas.getContext('webgl')
    context = canvas.getContext('experimental-webgl') unless context?
    checkWebGL = context?
    checkExt = if context? then context.getExtension('OES_texture_float')? else null
    
    context = null
    canvas = null
    
    return checkFile and checkFileReader and checkFileList and checkDataView and checkBlob and checkWebWorker and checkWebGL and checkExt
  
  setBuild: ->
    a = $('footer a')
    href = a.attr('href').replace('{{ref}}', Info.ref)
    text = a.text().replace('{{ref}}', Info.ref).replace('{{date}}', Info.date)
    a.attr('href', href)
    a.text(text)


module.exports = Luminosity