FITS = require('fits')

Image = require('controllers/Image')
Cube  = require('controllers/Cube')
Table = require('controllers/Table')

class Handler extends Spine.Controller
  events:
    'click button.hdu'    : 'selectHDU'
    'click #active label' : 'setHDU'
  
  elements:
    '#header' : 'header'
  
  constructor: ->
    super
    window.addEventListener('scroll', @scroll, false)
    
  readBuffer: (buffer) ->
    
    # Initialize FITS object and cache the HDUs
    @fits = new FITS.File(buffer)
    hdus = @fits.hdus
    numHDUs = hdus.length
    
    # Set some styles dynamically (this is messy)
    styles = "<style>"
    for i in [0..numHDUs-1]
      margin = "#{-1 * 100 * i}%"
      
      styles += "#hdu#{i}:checked ~ #slides .inner {margin-left: #{margin};}"
      styles += "#hdu#{i}:checked ~ #active label:nth-child(#{i+1}) {background: #333; border-color: #333 !important;}"
      styles += "#hdu#{i}:checked ~ #slides article:nth-child(#{i+1}) {opacity: 1; -webkit-transition: all 1s ease-out 0.6s; -moz-transition: all 1s ease-out 0.6s; transition: all 1s ease-out 0.6s;}"
    
    styles += "#slides .inner {width: #{100 * numHDUs}%;}"
    styles += "#slides article {width: #{100 / numHDUs}%;}"
    styles += "</style>"
    $('head').append(styles)
    
    # Render the template
    @html require('views/hdus')(hdus)
    
    # Set the default HDU
    # TODO: Default to the first HDU containing a data unit
    $('#hdu0').attr('checked', 'checked') # TODO: Test Zepto's prop method
    
    # Cache the root object
    @root = $('#luminosity')
    
    # Set styles dynamically
    @root.css('margin', '10px 20px')
    window.onresize = =>
      width = $(window).width()
      $('body').width(width)
    window.onresize()
    
    # @root.on('scroll', @scroll)
    # 
    # @currentHDU = 0
    # section = $('section')
    # margin = parseInt(section.css('margin').match(/(\d+)/))
    # @hduHeight = section.height() + margin
    # 
    # @readData(buffer)
  
  setHDU: (e) =>
    console.log e
  
  selectHDU: (e) =>
    selectedHDU = parseInt(e.target.dataset['index'])
    if selectedHDU is @currentHDU
      @showHeader(@currentHDU)
    else
      @header.hide()
      @currentHDU = selectedHDU
      @root[0].scrollTop = @hduHeight * @currentHDU
  
  showHeader: (index) =>
    header = @fits.getHDU(index).header
    @header.html require('views/header')({cards: header.cards})
    @header.toggle()
  
  scroll: (value) =>
    value = @root.scrollTop()
    @currentHDU = Math.floor(value / @hduHeight)
  
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