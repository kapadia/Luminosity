require('lib/setup')

Spine = require('spine')
Drop  = require('controllers/Drop')

class Luminosity extends Spine.Controller
  elements:
    '#luminosity' : 'luminosity'
  
  constructor: ->
    super
    
    # Include the DOM from main
    @html require('views/main')()
    
    # Set some styles dynamically
    $("body").css('height', window.innerHeight)
    # window.onresize = ->  
    #   $(".hdu").css('height', window.innerHeight)
    
    # Initialize controllers
    drop = new Drop({el: @luminosity})
    
    # Check for compatibility
    if @browserCheck()
      drop.enable()
    else
      $('.requirements').show()
      $('.requirements').animate({opacity: 1}, 1000)
  
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