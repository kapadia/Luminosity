Spine = require('spine')

class Crossfilter extends Spine.Controller
  maxDimensions: 16
  
  constructor: ->
    super
    dataunit = arguments[1]
    
    # Process all data
    data = []
    for i in [0..dataunit.rows-1]
      data.push dataunit.getRow(i)
    
    @cross = crossfilter(data)
    @dimensions = {}
    @bisects = {}
  
  # Create a crossfilter dimension on the selected column
  setDimensions: (columns...) =>
    for column in columns
      continue if @dimensions.hasOwnProperty(column)
      @dimensions[column] = @cross.dimension((d) -> d[column])
  
  # Apply a filter on active dimension(s) based on brushing from plot
  applyFilters: (bounds) =>
    
    # Clear the existing filters
    for key, dimension of @dimensions
      dimension.filterAll()
    
    # Apply filters based on bounds
    for key, value of bounds
      @dimensions[key].filter(value)
    
    key = Object.keys(bounds)[0]
    @trigger 'dataFiltered', @dimensions[key].top(10)
  
  sortByColumn: (column) =>
    console.log 'sortByColumn', column
    unless column of @dimensions
      @dimensions[column] = @cross.dimension((d) -> d[column])
    
    dimension = @dimensions[column]
    
    top = dimension.top(Infinity)
    @trigger 'dataFiltered', dimension.top(10)
    
    



module.exports = Crossfilter