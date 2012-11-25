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
    @sortOrder = {}
  
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
    unless column of @sortOrder
      @sortOrder[column] = true # Represents ascending order
    
    unless @sortOrder[column]
      rows = @dimensions[column].top(10)
      @sortOrder[column] = true
    else
      rows = @dimensions[column].bottom(10)
      @sortOrder[column] = false
      
    @trigger 'dataFiltered', rows
    
    



module.exports = Crossfilter