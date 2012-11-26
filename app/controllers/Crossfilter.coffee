Spine = require('spine')

class Crossfilter extends Spine.Controller
  maxDimensions: 16
  rowsToAppend: 100
  
  constructor: ->
    super
    dataunit = arguments[1]
    
    # Process all data
    data = []
    for i in [0..dataunit.rows-1]
      data.push dataunit.getRow(i)
    
    @cross      = crossfilter(data)
    @dimensions = {}
    @sortOrder  = {}
    @currentRow = 0
  
  # Create a crossfilter dimension on the selected column
  setDimensions: (columns...) =>
    for column in columns
      continue if @dimensions.hasOwnProperty(column)
      @dimensions[column] = @cross.dimension((d) -> d[column])
      @sortOrder[column]  = true # represents ascending order
  
  # Apply a filter on active dimension(s) based on brushing from plot
  applyFilters: (bounds) =>
    
    # Clear the existing filters
    for key, dimension of @dimensions
      dimension.filterAll()
    
    # Apply filters based on bounds
    for key, value of bounds
      @dimensions[key].filter(value)
    
    key = Object.keys(bounds)[0]
    @data = @dimensions[key].top(Infinity)
    
    @currentRow += 10
    @trigger 'dataFiltered', @data.slice(0, 10)
  
  sortByColumn: (column) =>
    @setDimensions(column)
    
    unless @sortOrder[column]
      @data = @dimensions[column].top(Infinity)
      @sortOrder[column] = true
    else
      @data = @dimensions[column].bottom(Infinity)
      @sortOrder[column] = false
    
    @currentRow += 10
    @trigger 'dataFiltered', @data.slice(0, 10)
    
  onScroll: =>
    currentRow = @currentRow
    @currentRow += @rowsToAppend
    
    @trigger 'dataFiltered', @data.slice(currentRow, @currentRow)
    



module.exports = Crossfilter