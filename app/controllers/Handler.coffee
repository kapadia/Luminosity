FITS  = require('fits')

ImageController = require('controllers/Image')
CubeController  = require('controllers/Cube')
TableController = require('controllers/Table')

class Handler extends Spine.Controller
  elements:
    '#header-tabs' : 'tabs'
  
  constructor: ->
    super
    
  readBuffer: (buffer) ->
    @fits = new FITS.File(buffer)
    @renderTabs()
    @readData()
  
  renderTabs: ->
    hdus = @fits.hdus
    @html require('views/hdus')(hdus)
    
    # Store the current tab on selection
    options =
      select: (e, ui) =>
        @currentTab = ui.index
    @tabs.tabs(options)
    @currentTab = 0   # Default to the first tab
    
    # Keyboard shortcuts for tabs
    window.addEventListener('keypress', @shortcuts, false)
  
  shortcuts: (e) =>
    numTabs = @tabs.tabs('length')
    keyCode = e.keyCode
    if keyCode in [49..57]
      index = keyCode - 49
      @tabs.tabs('select', index)
  
  readData: =>
    for hdu, index in @fits.hdus
      header  = hdu.header
      data    = hdu.data
      
      elem = $("#dataunit-#{index}")
      args = {el: elem, hdu: hdu, index: index}
      
      # Determine and initialize the appropriate handler for the HDU
      if header.isPrimary()
        if header.hasDataUnit()
          if data.isDataCube()
            new CubeController args
          else
            new ImageController args
      else if header.isExtension()
        if header['XTENSION'] is 'TABLE'
          new TableController args


module.exports = Handler