
class Scatter3D extends Spine.Controller
  name: 'Scatter 3D'
  
  constructor: ->
    super
    console.log 'Scatter2D'
    
    @render()
    @plot = $("#hdu-#{@index} .scatter-3d .plot")
    
  render: ->
    attrs = {columns: @columns, name: @name}
    @html require('views/plot')(attrs)

module.exports = Scatter3D