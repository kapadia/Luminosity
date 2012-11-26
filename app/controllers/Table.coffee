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
    'click .fits-table th' : 'sortByColumn'
  
  constructor: ->
    super
    @rows = @hdu.data.rows
    
    @render()
    
    tableContainer = @el[0].querySelector('.table-container')
    tableContainer.addEventListener('scroll', @scroll, false)
    
    # Populate table with first ten rows
    number = if @rows < 10 then @rows else 10
    data = []
    while number--
      data.push @hdu.data.getRow()
    
    # Create the table header
    d3.select("article:nth-child(#{@index + 1}) .table-container thead").selectAll('th')
        .data(@hdu.data.columns)
      .enter().append('th')
        .text( (d) -> return d )
    
    # Place initial data in table
    @tbody = d3.select("article:nth-child(#{@index + 1}) .table-container tbody")
    @renderRows(data)
    
    window.addEventListener('keydown', @shortcuts, false)
    
    # Initialize a plot controllers
    columns = @getNumericalColumns()
    
    index = @index + 1
    @histogramElem = $("article:nth-child(#{index}) .one")
    @histogram = new Histogram({el: @histogramElem, hdu: @hdu, index: @index, columns: columns})
    
    @scatter2dElem = $("article:nth-child(#{index}) .two")
    @scatter2d = new Scatter2D({el: @scatter2dElem, hdu: @hdu, index: @index, columns: columns})
    
    @scatter3dElem = $("article:nth-child(#{index}) .three")
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
    info = {index: @index}
    @html require('views/table')(info)
  
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
  
  sortByColumn: (e) ->
    column = e.target.__data__  # When creating tables, D3 sets this property
    @cross.sortByColumn(column)
    
  scroll: (e) =>
    clientHeight  = e.target.clientHeight
    scrollHeight  = e.target.scrollHeight
    scrollTop     = e.target.scrollTop
    
    state = clientHeight is scrollHeight - scrollTop
    @cross.onScroll() if state
  
  shortcuts: (e) =>
    keyCode = e.keyCode

    # Escape
    if keyCode is 27
      @el[0].querySelector("#clear-#{@index}").checked = true
  
module.exports = Table