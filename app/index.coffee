require('lib/setup')

Spine = require('spine')
Drop  = require('controllers/Drop')

class Luminosity extends Spine.Controller
  elements:
    '#luminosity' : 'luminosity'
  
  constructor: ->
    super
    
    # Check for compatibility
    unless window.File and window.FileReader and window.FileList and window.Blob
      alert 'You need a better browser to use this application.'
      return null
    
    # Include the DOM from main
    @html require('views/main')()
    
    # # Set some styles dynamically
    $("body").css('height', window.innerHeight)
    # window.onresize = ->  
    #   $(".hdu").css('height', window.innerHeight)
      
    # Initialize controllers
    new Drop({el: @luminosity})

module.exports = Luminosity