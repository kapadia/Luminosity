require('lib/setup')

{Controller} = require('spine')
Drop  = require('controllers/Drop')


class Luminosity extends Controller
  
  
  constructor: ->
    super
    
    # Initialize controllers
    @el = $('#luminosity')
    drop = new Drop({el: @el})
    
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