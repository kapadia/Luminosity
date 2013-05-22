Handler = require('controllers/Handler')

class Drop extends Spine.Controller
  
  validExtensions: ['fits', 'fit', 'fz']
  tutorialPath: 'tutorial/demo.fits'
  
  events:
    'click .arrow'    : 'beginTutorial'
  
  
  constructor: ->
    super
    
    # Determine hostname and port for sockets
    if location.hostname is '0.0.0.0'
      @hostname = '0.0.0.0'
      @port = 5000
    else
      @hostname = 'weakforce.herokuapp.com'
      @port = 80
    
    info = require('lib/info')
    @html require('views/drop')(info)
    
    @drop = document.getElementById('drop')
    @drop.addEventListener('dragover', @handleDragOver, false)
    @drop.addEventListener('dragleave', @handleDragLeave, false)
    @drop.addEventListener('drop', @handleDrop, false)
    @disabled = true
    
    window.addEventListener('keydown', @shortcuts, false)
    
    # Socket handler
    @el.find('.sockets-experiment').on('click', @startSocket)
  
  enable: -> @disabled = false
  
  blockEvent: (e) ->
    e.stopPropagation()
    e.preventDefault()
  
  getExtension: (filename) ->
    filename.split('.').pop()
  
  handleDragOver: (e) =>
    @blockEvent(e)
    $("#drop").addClass('over')
  
  handleDragLeave: (e) =>
    @blockEvent(e)
    $("#drop").removeClass('over')
  
  handleDrop: (e) =>
    @blockEvent(e)
    return null if @disabled
    
    # Get the file list
    files = e.dataTransfer.files
    
    # Check that only one file is being imported
    if files.length > 1
      alert 'Please load only one file.'
      return null
    
    # Get the file from the list
    file = files[0]
    
    # Check the extension
    ext = @getExtension(file.name)
    unless ext.toLowerCase() in @validExtensions
      alert 'This does not seem to be a FITS file'
      return null
    
    # Initialize FITS File object using native File instance
    handler = new Handler(null, file)
    window.removeEventListener('keydown', @shortcuts, false)
  
  beginTutorial: =>
    handler = new Handler(null, @tutorialPath)
  
  startSocket: (e) =>
    @blockEvent(e)
    
    unless @socket?
      @socket = io.connect(@hostname, {port: @port})
    
    @socket.on('status', (data) =>
      window.removeEventListener('keydown', @shortcuts, false)
      handler = new Handler({socket: @socket}, @tutorialPath)
    )
  
  shortcuts: (e) =>
    keyCode = e.keyCode

    # Escape
    if keyCode is 27
      @el[0].querySelector('#clear').checked = true
    
module.exports = Drop