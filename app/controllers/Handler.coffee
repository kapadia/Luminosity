
{Controller}    = require('spine')

Image           = require('controllers/Image')
Cube            = require('controllers/Cube')
Table           = require('controllers/Table')
CompressedImage = require('controllers/CompressedImage')


class Handler extends Controller
  el: '#luminosity'
  
  handlerConstructor:
    Image: Image
    Cube: Cube
    Table: Table
    BinaryTable: Table
    CompressedImage: CompressedImage
  
  # Storage for HDUs
  hdus: []
  
  events:
    'click #controls label' : 'setHDU'
  
  elements:
    '#header' : 'header'
  
  
  constructor: (args, source, @socket) ->
    super
    
    # Initialize FITS object with data source and render callback
    @fits = new astro.FITS(source, @render, {context: @})
  
  render: ->
    
    # Get HDU instances
    hdus = @fits.hdus
    
    # Render DOM
    @html require('views/hdus')(hdus)
    
    # Set up HDU selection
    $(".select-hdu").removeClass('hide')
    optionsHDU = $(".select-hdu ul")
    
    # Initialize the appropriate data handler
    for hdu, index in hdus
      
      # Get type from header
      type = hdu.header.getDataType()
      optionsHDU.append("<li data-index='#{index}'>#{type}</li>")
      
      # TEMP: Check case for cube
      if type is 'Image'
        if hdu.data.isDataCube()
          type = 'Cube'
      
      if type?
        
        # Get DOM element and setup arguments
        elem = $("#dataunits article:nth-child(#{index + 1}) div.container")
        args = {el: elem, hdu: hdu, index: index, socket: @socket}
        
        handler = new @handlerConstructor[type](args)
        @hdus.push handler
      else
        @hdus.push null
    
    # Default to the first HDU with a dataunit
    for hdu, index in hdus
      if hdu.hasData()
        $("#hdu#{index}").attr('checked', 'checked')
        $("#dataunits article:nth-child(#{index + 1})").addClass('current')
        @currentHDU = index
        
        # Read only the current data unit
        @hdus[@currentHDU].getData()
        
        break
    
    # Setup keyboard shortcuts
    window.addEventListener('keydown', @shortcuts, false)
    
    $(".select-hdu li").on('click', (e) => @setHDU(e) )
  
  setHDU: (e) =>
    @currentHDU = parseInt(e.target.dataset.index)
    
    # Update DOM
    $('#dataunits article.current').removeClass('current')
    $("#dataunits article:nth-child(#{@currentHDU + 1})").addClass('current')
    
    # Read into memory now that user has requested data
    @hdus[@currentHDU].getData()
  
  showHeader: (index) =>
    header = @fits.getHDU(index).header
    @header.html require('views/header')({cards: header.cards})
    @header.toggle()
  
  shortcuts: (e) =>
    keyCode = e.keyCode
    switch keyCode
      when 37
        @currentHDU -= 1 unless @currentHDU is 0
      when 39
        @currentHDU += 1 unless @currentHDU is @fits.hdus.length - 1
    @el.find("label[for='hdu#{@currentHDU}']").click()


module.exports = Handler