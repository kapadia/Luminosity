FITS = require('fits')

Image = require('controllers/Image')
Cube  = require('controllers/Cube')
Table = require('controllers/Table')

class Handler extends Spine.Controller
  events:
    'click #active label' : 'setHDU'
  
  elements:
    '#header' : 'header'
    
  readBuffer: (buffer) ->
    
    # Initialize FITS object and cache the HDUs
    @fits = new FITS.File(buffer)
    hdus = @fits.hdus
    numHDUs = hdus.length
    
    # Set some styles dynamically (sadly, this is messy)
    styles = "<style>"
    for i in [0..numHDUs-1]
      margin = "#{-1 * 100 * i}%"
      
      styles += "#hdu#{i}:checked ~ #dataunits .inner {margin-left: #{margin};}"
      styles += "#hdu#{i}:checked ~ #active label:nth-child(#{i+1}) {background: #333; border-color: #333 !important;}"
      styles += "#hdu#{i}:checked ~ #dataunits article:nth-child(#{i+1}) {opacity: 1; -webkit-transition: all 1s ease-out 0.6s; -moz-transition: all 1s ease-out 0.6s; transition: all 1s ease-out 0.6s;}"
    
    styles += "#dataunits .inner {width: #{100 * numHDUs}%; height: 100%}"
    styles += "#dataunits article {width: #{100 / numHDUs}%;}"
    styles += "</style>"
    $('head').append(styles)
    @el.css('margin', '10px 20px')
    
    # Render the template
    @html require('views/hdus')(hdus)
    
    # Set the default HDU
    for hdu, index in hdus
      if hdu.hasData()
        $("#hdu#{index}").attr('checked', 'checked')
        @currentHDU = index
        break
    
    window.onresize = =>
      width = $(window).width()
      $('body').width(width)
    window.onresize()
    
    # Begin reading the dataunits
    @readData(buffer)
    
    # Setup keyboard shortcuts
    window.addEventListener('keydown', @shortcuts, false)
  
  setHDU: (e) => @currentHDU = parseInt(e.target.dataset.unit)
  
  showHeader: (index) =>
    header = @fits.getHDU(index).header
    @header.html require('views/header')({cards: header.cards})
    @header.toggle()
  
  readData: (buffer) =>
    for hdu, index in @fits.hdus
      header  = hdu.header
      data    = hdu.data
      
      elem = $("#dataunit#{index}")
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
    
  shortcuts: (e) =>
    keyCode = e.keyCode
    switch keyCode
      when 37
        @currentHDU -= 1 unless @currentHDU is 0
      when 39
        @currentHDU += 1 unless @currentHDU is @fits.hdus.length - 1
    @el.find("label[for='hdu#{@currentHDU}']").click()
  
module.exports = Handler