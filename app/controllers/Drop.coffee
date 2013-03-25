Handler = require('controllers/Handler')

class Drop extends Spine.Controller
  
  
  events:
    'click .arrow'    : 'beginTutorial'

  @getExtension: (filename) -> filename.split('.').pop()

  constructor: ->
    super
    
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
  
  handleDragOver: (e) ->
    e.stopPropagation()
    e.preventDefault()
    $("#drop").addClass('over')
  
  handleDragLeave: (e) ->
    e.stopPropagation()
    e.preventDefault()
    $("#drop").removeClass('over')
  
  handleDrop: (e) =>
    e.stopPropagation()
    e.preventDefault()
    return null if @disabled
    
    files = e.dataTransfer.files
    
    # Check that only one file is being imported
    if files.length > 1
      alert 'Please load only one file.'
      return null
    
    file = files[0]
    window.f = file
    
    # Check the extension
    ext = Drop.getExtension(file.name)
    unless ext.toLowerCase() in ['fits', 'fit', 'fz']
      alert 'This does not seem to be a FITS file'
      return null
    
    # Read the file
    reader = new FileReader()
    
    reader.onprogress = (e) =>
      if e.lengthComputable
        progress = document.querySelector("#loading progress")
        loaded = e.loaded
        total = e.total
        percent = Math.round(100 * (loaded / total))
        if percent < 100
          progress.value = percent
    
    reader.onloadend = (e) =>
      if e.target.readyState is FileReader.DONE
        buffer = e.target.result
        window.removeEventListener('keydown', @shortcuts, false)
        handler = new Handler({el: @el})
        handler.readBuffer(buffer)
        
    $("#loading").show()
    reader.readAsArrayBuffer(file)
  
  beginTutorial: =>
    xhr = new XMLHttpRequest()
    xhr.open('GET', 'tutorial/demo.fits')
    xhr.responseType = 'arraybuffer'
    xhr.onload = =>
      window.removeEventListener('keydown', @shortcuts, false)
      handler = new Handler({el: @el})
      handler.readBuffer(xhr.response)
    xhr.send()
  
  startSocket: (e) =>
    e.preventDefault()
    
    unless @socket?
      if location.hostname is '0.0.0.0'
        @socket = io.connect('0.0.0.0', {port: 5000})
      else
        @socket = io.connect('weakforce.herokuapp.com', {port: 80})
        
    
    @socket.on('status', (data) =>
      
      # Test with tutorial image
      xhr = new XMLHttpRequest()
      xhr.open('GET', 'tutorial/demo.fits')
      xhr.responseType = 'arraybuffer'
      xhr.onload = =>
        window.removeEventListener('keydown', @shortcuts, false)
        handler = new Handler({el: @el, socket: @socket})
        handler.readBuffer(xhr.response)
      xhr.send()
    )
  
  shortcuts: (e) =>
    keyCode = e.keyCode

    # Escape
    if keyCode is 27
      @el[0].querySelector('#clear').checked = true
    
module.exports = Drop