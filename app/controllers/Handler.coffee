Image = require('controllers/Image')
Cube  = require('controllers/Cube')
Table = require('controllers/Table')

class Handler extends Spine.Controller
  
  events:
    'click #controls label' : 'setHDU'
  
  elements:
    '#header' : 'header'
  
  
  constructor: ->
    super
    
    # Initialize a FITS File object with a callback and it context
    opts =
      context: @
    @fits = new astro.FITS.File(arguments[1], @render, opts)
  
  render: ->
    # Get HDU instances
    hdus = @fits.hdus
    
    # Render DOM
    @html require('views/hdus')(hdus)
    
    # Default to the first HDU with a dataunit
    for hdu, index in hdus
      if hdu.hasData()
        $("#hdu#{index}").attr('checked', 'checked')
        $("#dataunits article:nth-child(#{index + 1})").addClass('current')
        @currentHDU = index
        
        # Read only the current data unit
        @getBuffer(index)
        break
    
    # Setup keyboard shortcuts
    window.addEventListener('keydown', @shortcuts, false)
  
  # Read the bytes of only the dataunit specified by index
  getBuffer: (index) ->
    console.log 'getBufferAndRead'
    
    # Get dataunit from file
    dataunit = @fits.getDataUnit(index)
    
    # Copy data chunk into memory.  Passing callback, context, and argument
    dataunit.start(@getFrame, @, dataunit)
  
  getFrame: (dataunit) ->
    opts =
      context: @
    dataunit.getFrameAsync(null, @draw, opts)
  
  draw: (arr, opts) ->
    console.log 'draw', arr, opts
  
  readBuffer: (buffer) ->
    
    # Initialize FITS object and cache the HDUs
    @fits = new astro.FITS.File(buffer)
    hdus = @fits.hdus
    
    # Render the template
    @html require('views/hdus')(hdus)
    
    # Set the default HDU
    for hdu, index in hdus
      if hdu.hasData()
        $("#hdu#{index}").attr('checked', 'checked')
        $("#dataunits article:nth-child(#{index + 1})").addClass('current')
        @currentHDU = index
        break
    
    # Begin reading the dataunits
    @readData(buffer)
    
    # Setup keyboard shortcuts
    window.addEventListener('keydown', @shortcuts, false)
  
  setHDU: (e) =>
    @currentHDU = parseInt(e.target.dataset.order)
    $('#dataunits article.current').removeClass('current')
    $("#dataunits article:nth-child(#{@currentHDU + 1})").addClass('current')
  
  showHeader: (index) =>
    header = @fits.getHDU(index).header
    @header.html require('views/header')({cards: header.cards})
    @header.toggle()
  
  readData: (buffer) =>
    
    for hdu, index in @fits.hdus
      header  = hdu.header
      data    = hdu.data
      
      # Select the parent DOM element for the dataunit
      # TODO: Remove reference to buffer
      elem = $("#dataunits article:nth-child(#{index + 1}) div.container")
      args = {el: elem, hdu: hdu, index: index}
      
      # Initialize the appropriate handler for the HDU
      if header.isPrimary()
        if header.hasDataUnit()
          if data.isDataCube()
            new Cube args
          else
            # Testing sockets with Image class only
            args.socket = @socket if @socket
            new Image args
      else if header.isExtension()
        if header['XTENSION'] is 'TABLE'
          new Table args
        else if header['XTENSION'] is 'BINTABLE'
          if header.contains('ZIMAGE')
            new Image args
          else
            new Table args
        else if header.extensionType is 'IMAGE'
          new Image args
    
  shortcuts: (e) =>
    keyCode = e.keyCode
    switch keyCode
      when 37
        @currentHDU -= 1 unless @currentHDU is 0
      when 39
        @currentHDU += 1 unless @currentHDU is @fits.hdus.length - 1
    @el.find("label[for='hdu#{@currentHDU}']").click()
  
module.exports = Handler