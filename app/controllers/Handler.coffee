FITS  = require('fits')

ImageController     = require('controllers/Image')
CubeController      = require('controllers/Cube')
TableController     = require('controllers/Table')
BinTableController  = require('controllers/BinaryTable')

class Handler extends Spine.Controller
  events:
    'click button.hdu'  : 'selectHDU'
  
  elements:
    '#header' : 'header'
  
  constructor: ->
    super
    window.addEventListener('keydown', @shortcuts, false)
    
  readBuffer: (buffer) ->
    @fits = new FITS.File(buffer)
    
    hdus = @fits.hdus
    @html require('views/hdus')(hdus)
    
    @currentHDU = 0
    section = $('section')
    margin = parseInt(section.css('margin').match(/(\d+)/))
    @hduHeight = section.outerHeight() + margin
    
    # Set up scroll event
    $('#luminosity').scroll( (e) =>
      @scroll(e.target.scrollTop)
    )
    
    @readData(buffer)
  
  selectHDU: (e) =>
    selectedHDU = parseInt(e.target.dataset['index'])
    if selectedHDU is @currentHDU
      @showHeader(@currentHDU)
    else
      @header.hide()
      @currentHDU = selectedHDU
      $('#luminosity').animate({
        scrollTop: @hduHeight * @currentHDU
      })
  
  showHeader: (index) =>
    header = @fits.getHDU(index).header
    @header.html require('views/header')({cards: header.cards})
    @header.toggle()
  
  scroll: (value) =>
    @currentHDU = Math.floor(value / @hduHeight)
  
  readData: (buffer) =>
    for hdu, index in @fits.hdus
      header  = hdu.header
      data    = hdu.data
      
      elem = $("#hdu-#{index} .dataunit")
      args = {el: elem, hdu: hdu, index: index, buffer: buffer}
      
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
        else if header['XTENSION'] is 'BINTABLE'
          if header.contains('ZIMAGE')
            new ImageController args
          else
            new BinTableController args
        else if header.extensionType is 'IMAGE'
          new ImageController args
  
  shortcuts: (e) =>
    keyCode = e.keyCode
    
    # Escape
    if keyCode is 27
      $('.modal').hide()
  
module.exports = Handler