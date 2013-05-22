
{Controller}    = require('spine')

Image           = require('controllers/Image')
Cube            = require('controllers/Cube')
Table           = require('controllers/Table')
CompressedImage = require('controllers/CompressedImage')

class Handler extends Controller
  el: '#luminosity'
  
  handlerConstructor:
    Image: Image
    Table: Table
    BinaryTable: Table
    CompressedImage: CompressedImage
  
  # Storage for HDUs
  hdus: []
  
  events:
    'click #controls label' : 'setHDU'
  
  elements:
    '#header' : 'header'
  
  
  constructor: (args, source)->
    super
    
    # Initialize FITS object with data source and render callback
    @fits = new astro.FITS(source, @render, {context: @})
  
  render: ->
    
    # Get HDU instances
    hdus = @fits.hdus
    
    # Render DOM
    @html require('views/hdus')(hdus)
    
    # Initialize the appropriate data handler
    for hdu, index in hdus
      
      # Get type from header
      type = hdu.header.getDataType()
      
      if type?
        
        # Get DOM element and setup arguments
        elem = $("#dataunits article:nth-child(#{index + 1}) div.container")
        args = {el: elem, hdu: hdu, index: index}
        
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
  
  setHDU: (e) =>
    @currentHDU = parseInt(e.target.dataset.order)
    
    # Read into memory now that user has requested these data
    @hdus[@currentHDU].getData()
    $('#dataunits article.current').removeClass('current')
    $("#dataunits article:nth-child(#{@currentHDU + 1})").addClass('current')
  
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