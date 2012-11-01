FITS = require('fits')

Image = require('controllers/Image')
Cube  = require('controllers/Cube')
Table = require('controllers/Table')

class Handler extends Spine.Controller
  events:
    'click button.hdu'  : 'selectHDU'
  
  elements:
    '#header'     : 'header'
  
  constructor: ->
    super
    
  readBuffer: (buffer) ->
    @fits = new FITS.File(buffer)
    
    hdus = @fits.hdus
    @html require('views/hdus')(hdus)
    @root = $('#luminosity')
    
    @currentHDU = 0
    section = $('section')
    margin = parseInt(section.css('margin').match(/(\d+)/))
    @hduHeight = section.outerHeight() + margin
    
    @root.scroll((e) => @scroll(e.target.scrollTop))
    
    @readData(buffer)
  
  selectHDU: (e) =>
    selectedHDU = parseInt(e.target.dataset['index'])
    if selectedHDU is @currentHDU
      @showHeader(@currentHDU)
    else
      @header.hide()
      @currentHDU = selectedHDU
      @root.animate({scrollTop: @hduHeight * @currentHDU})
  
  showHeader: (index) =>
    header = @fits.getHDU(index).header
    @header.html require('views/header')({cards: header.cards})
    @header.toggle()
  
  scroll: (value) => @currentHDU = Math.floor(value / @hduHeight)
  
  readData: (buffer) =>
    for hdu, index in @fits.hdus
      header  = hdu.header
      data    = hdu.data
      
      elem = $("#hdu-#{index} .dataunit")
      args = {el: elem, hdu: hdu, index: index, buffer: buffer}
      
      # Initialize the appropriate handler for the HDU
      if header.isPrimary()
        if header.hasDataUnit()
          if data.isDataCube()
            new Cube args
          else
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
  
module.exports = Handler