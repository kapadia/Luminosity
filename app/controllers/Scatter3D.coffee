
class Scatter3D extends Spine.Controller
  name: 'Scatter 3D'
  
  events:
    'change .scatter-2d select[data-axis=1]' : 'draw'
    'change .scatter-2d select[data-axis=2]' : 'draw'
    'change .scatter-2d select[data-axis=3]' : 'draw'
  
  constructor: ->
    super
    console.log 'Scatter3D'
    
    @render()
    @plot = $("#hdu-#{@index} .scatter-3d.graph")
    
  render: ->
    attrs = {columns: @columns, name: @name, axes: 3}
    @html require('views/plot')(attrs)

  draw: =>
    console.log 'draw'
    @plot.empty()

module.exports = Scatter3D