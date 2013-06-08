Handler = require('controllers/Handler')

class Drop extends Spine.Controller
  
  validExtensions: ['fits', 'fit', 'fz']
  tutorialPath: 'tutorial/demo.fits'
  
  events:
    'click .arrow'    : 'beginTutorial'
  
  
  constructor: ->
    super
    
    info = require('lib/info')
    @html require('views/drop')(info)
    
    @drop = document.getElementById('drop')
    @share = document.getElementById('share')
    
    for el in [@drop, @share]
      el.addEventListener('dragenter', @onDragEnter, false)
      el.addEventListener('dragover', @onDragOver, false)
      el.addEventListener('dragleave', @onDragLeave, false)
      el.addEventListener('drop', @handleDrop, false)
    
    @disabled = true
    
    window.addEventListener('keydown', @shortcuts, false)
  
  enable: -> @disabled = false
  
  blockEvent: (e) ->
    e.stopPropagation()
    e.preventDefault()
  
  getExtension: (filename) ->
    filename.split('.').pop()
  
  # TODO: Drag events can be optimized
  onDragOver: (e) =>
    @blockEvent(e)
    
  onDragEnter: (e) ->
    $("#drop").addClass('over')
    
    if e.target.id is "share"
      $(".sharing").addClass('show')
  
  onDragLeave: (e) ->
    $("#drop").removeClass('over')
    
    if e.target.id is "share"
      $(".sharing").removeClass('show')
  
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
    
    # Turn off socket event
    @socket.removeAllListeners('request-to-share')
    
    if e.target.id is "share"
      @setupSocket(file)
      socket = @socket
    
    # Initialize FITS File object using native File instance
    handler = new Handler(null, file, socket)
    window.removeEventListener('keydown', @shortcuts, false)
  
  beginTutorial: =>
    handler = new Handler(null, @tutorialPath)
  
  setupSocket: (file) ->
    
    # Broadcast shared file
    @socket.emit('sharing-data',
      filename: file.name
    )
  
  collaborateOn: (filename) =>
    
    # TODO: Put more data online
    handler = new Handler(null, "http://astrojs.s3.amazonaws.com/sample/#{filename}", @socket)
  
  shortcuts: (e) =>
    keyCode = e.keyCode

    # Escape
    if keyCode is 27
      @el[0].querySelector('#clear').checked = true
    
module.exports = Drop