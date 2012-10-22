
class Scatter2D extends Spine.Controller
  name: 'Scatter 2D'
  
  constructor: ->
    super
    console.log 'Scatter2D'
    
    @render()
    @plot = $("#hdu-#{@index} .scatter-2d .plot")
    
  render: ->
    attrs = {columns: @columns, name: @name}
    @html require('views/plot')(attrs)

module.exports = Scatter2D