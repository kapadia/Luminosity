
class HeaderController extends Spine.Controller
  
  constructor: ->
    super
    console.log 'Header'
    @render()
  
  render: =>
    @html require('views/header')({cards: @header.cards})
    @
    

module.exports = HeaderController