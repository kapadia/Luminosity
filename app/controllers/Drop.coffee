Handler = require('controllers/Handler')

class Drop extends Spine.Controller
  
  @getExtension: (filename) -> filename.split('.').pop()
  
  constructor: ->
    super
    @html require('views/drop')()
    
    @drop = document.getElementById('drop')
    @drop.addEventListener('dragover', @handleDragOver, false)
    @drop.addEventListener('dragleave', @handleDragLeave, false)
    @drop.addEventListener('drop', @handleDrop, false)
  
  handleDragOver: (e) ->
    e.stopPropagation()
    e.preventDefault()
  
  handleDragLeave: (e) ->
    e.stopPropagation()
    e.preventDefault()
  
  handleDrop: (e) =>
    e.stopPropagation()
    e.preventDefault()
    
    files = e.dataTransfer.files
    
    # Check that only one file is being imported
    if files.length > 1
      alert 'Please load only one file.'
      return null
    
    file = files[0]
    
    # Check the extension
    ext = Drop.getExtension(file.name)
    unless ext.toLowerCase() in ['fits', 'fit', 'fz']
      alert 'This does not seem to be a FITS file'
      return null
    
    # Read the file
    reader = new FileReader()
    
    reader.onprogress = (e) =>
      if e.lengthComputable
        progress = document.querySelector('.percent')
        loaded = e.loaded
        total = e.total
        percent = Math.round(100 * (loaded / total))
        if percent < 100
          progress.style.width = percent + '%'
          progress.textContent = percent + '%'
    
    reader.onloadend = (e) =>
      if e.target.readyState is FileReader.DONE
        buffer = e.target.result
        handler = new Handler({el: @el})
        handler.readBuffer(buffer)
    reader.readAsArrayBuffer(file)
  
module.exports = Drop