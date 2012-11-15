Spine = require('spine')

Cross     = require('controllers/Crossfilter')
Histogram = require('controllers/Histogram')
Scatter2D = require('controllers/Scatter2D')
Scatter3D = require('controllers/Scatter3D')

class Table extends Spine.Controller
  @binary = /(\d*)([BIJKED])/
  @ascii = /([IFED])(\d+)\.*(\d+)*/
  
  elements:
    'input[name=number]'  : 'rowNumber'
  
  events:
    'keydown input[name=number]'    : 'blockLetter'
    'keyup input[name=number]'      : 'updateRows'
    'click input[name=next]'        : 'updateRows'
    'click input[name=prev]'        : 'updateRows'
    'click input[name=histogram]'   : 'toggleHistogram'
    'click input[name=scatter-2d]'  : 'toggleScatter2D'
    'click input[name=scatter-3d]'  : 'toggleScatter3D'
  
  @permittedKeys: [48..57]
  @.permittedKeys.push(8)   # Delete
  @.permittedKeys.push(91)  # Shift
  @.permittedKeys.push(16)  # Command
  @.permittedKeys.push(37)  # Left arrow
  @.permittedKeys.push(39)  # Right array
  
  @stringCompare: (a, b) ->
    a = a.toLowerCase()
    b = b.toLowerCase()
    return (if a > b then 1 else (if a is b then 0 else -1))
  
  constructor: ->
    super
    @rows = @hdu.data.rows
    
    @render()
    @tbody = @el.find('tbody')
    
    # Populate table with first ten rows
    number = if @rows < 10 then @rows else 10
    data = []
    while number--
      data.push @hdu.data.getRow()
    
    # Create the table header
    d3.select("#dataunit#{@index} .table-container thead").selectAll('th')
        .data(@hdu.data.columns)
      .enter().append('th')
        .text( (d) -> return d )
    
    # Place initial data in table
    @tbody = d3.select("#dataunit#{@index} .table-container tbody")
    @renderRows(data)
    
    # Set height  TODO: Do this in pure css
    @el.find('.table-container').height(@el.parent().height() - @el.find('.controls').height())
    
    # Initialize a plot controllers
    columns = @getNumericalColumns()
    
    @histogramElem = $("#dataunit#{@index} .histogram")
    @histogram = new Histogram({el: @histogramElem, hdu: @hdu, index: @index, columns: columns})
    
    @scatter2dElem = $("#dataunit#{@index} .scatter-2d")
    @scatter2d = new Scatter2D({el: @scatter2dElem, hdu: @hdu, index: @index, columns: columns})
    
    @scatter3dElem = $("#dataunit#{@index} .scatter-3d")
    @scatter3d = new Scatter3D({el: @scatter3dElem, hdu: @hdu, index: @index, columns: columns})
    
    # Setup crossfilter object and hook up events
    setTimeout =>
      @cross = new Cross({index: @index}, @hdu.data)
      
      @histogram.bind 'onColumnChange', (col1) =>
        @cross.setDimensions(col1)
      
      @histogram.bind 'brushend', (d) =>
        @cross.applyFilters(d)
      
      @scatter2d.bind 'onColumnChange', (col1, col2) =>
        @cross.setDimensions(col1, col2)
      
      @scatter2d.bind 'brushend', (d) =>
        @cross.applyFilters(d)
      
      @cross.bind 'dataFiltered', @renderRows
    , 0
    
    
    
  render: =>
    info = {columns: @hdu.data.columns, rows: @hdu.data.rows}
    @html require('views/table')(info)
  
  blockLetter: (e) ->
    keyCode = e.keyCode
    unless keyCode in Table.permittedKeys
      e.preventDefault()
  
  updateRows: (e) =>
    dataunit = @hdu.data
    
    switch e.target.name
      when 'next'
        rowsRead = dataunit.rowsRead
      when 'prev'
        rowsRead = Math.max(dataunit.rowsRead - 2 * 10, 0)
      when 'number'
        @rowNumber.val(0) if @rowNumber.val() is ''
        rowsRead = parseInt(@rowNumber.val())
    
    return null unless @checkRow(rowsRead)
    
    count = dataunit.rows - rowsRead
    count = if count < 10 then count else 10
    count -= 1
    
    data = []
    for i in [rowsRead..rowsRead+count]
      data.push dataunit.getRow(i)
    @renderRows(data)
  
  renderRows: (data) =>
    @tbody.selectAll('tr').remove()
    @tbody.selectAll('tr')
        .data(data)
      .enter().append('tr')
      .selectAll('td')
        .data( (d) ->
          row = []
          for key, value of d
            row.push value
          return row
        )
      .enter().append('td')
      .text( (d) -> return d)
  
  checkRow: (number) =>
    return false if number < 0
    return false if number > @hdu.data.rows - 1
    return true
    
  getNumericalColumns: ->
    columns = {}
    header = @hdu.header
    dataunit = @hdu.data
    cols = dataunit.cols
    
    pattern = if header['XTENSION'] is 'TABLE' then Table.ascii else Table.binary
    
    for i in [1..cols]
      form = "TFORM#{i}"
      type = "TTYPE#{i}"
      match = header[form].match(pattern)
      if match?
        columns[header[type]] = i - 1
    return columns
  
  toggleHistogram: => @histogramElem.toggle()
  toggleScatter2D: => @scatter2dElem.toggle()
  toggleScatter3D: => @scatter3dElem.toggle()
    
module.exports = Table