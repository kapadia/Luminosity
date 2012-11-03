Spine = require('spine')

class Crossfilter extends Spine.Controller
  
  constructor: ->
    super
    
    # Process all data
    dataunit = @hdu.data
    @data = []
    for i in [0..dataunit.rows-1]
      @data.push dataunit.getRow(i)
    
    @cross = crossfilter(@data)
    @all = @cross.groupAll()
    
  setDimensions: (@column1, @column2) =>
    @dimension1 = @cross.dimension( (d) => d[@column1])
    @dimension2 = @cross.dimension( (d) => d[@column2])
    
  setGroups: (column1, column2) =>
    @dimension1.group()
    @dimension2.group()
  
  applyFilter: (d) =>
    [x1, y1] = d[0]
    [x2, y2] = d[1]
    
    console.log [x1, x2]
    console.log [y1, y2]
    @dimension1.filter [x1, x2]
    @dimension2.filter [y1, y2]
    
    @trigger 'dataFiltered', @dimension1.top(10)
    
module.exports = Crossfilter