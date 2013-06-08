require('lib/setup')

{Controller} = require('spine')
Drop  = require('controllers/Drop')


class Luminosity extends Controller
  
  
  constructor: ->
    super
    
    # Initialize controllers
    @el = $('#luminosity')
    
    # Start socket and determine hostname and port for sockets
    if location.hostname is '0.0.0.0'
      hostname = '0.0.0.0'
      port = 3000
    else
      hostname = 'http://weakforce-env-y2xt7saftp.elasticbeanstalk.com/'
      # @hostname = 'http://ec2-50-17-0-195.compute-1.amazonaws.com/'
      port = 80
    socket = io.connect(hostname, {port: port})
    
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
    
    # Check for WebGL
    canvas = document.createElement('canvas')
    context = canvas.getContext('webgl')
    context = canvas.getContext('experimental-webgl') unless context?
    checkWebGL = context?
    
    return checkFile and checkFileReader and checkFileList and checkDataView and checkBlob and checkWebWorker and checkWebGL


module.exports = Luminosity