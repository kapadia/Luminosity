require('lib/setup')

Spine = require('spine')
Drop  = require('controllers/Drop')

class Luminosity extends Spine.Controller
  elements:
    '#luminosity' : 'luminosity'
    '#content'    : 'content'
  
  constructor: ->
    super
    
    # Check for compatibility
    unless window.File and window.FileReader and window.FileList and window.Blob
      alert 'You need a better browser to use this application.'
      return null
    
    # Include the DOM from main
    @html require('views/main')()
    
    # Initialize controllers
    new Drop({el: @content})

module.exports = Luminosity