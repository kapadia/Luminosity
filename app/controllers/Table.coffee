{Controller} = require('spine')

Cross     = require('controllers/Crossfilter')
Histogram = require('controllers/Histogram')
Scatter2D = require('controllers/Scatter2D')
Scatter3D = require('controllers/Scatter3D')


class Table extends Controller
  @binary = /(\d*)([BIJKED])/
  @ascii = /([IFED])(\d+)\.*(\d+)*/
  inMemory: false
  
  
  elements:
    'input[name=number]'  : 'rowNumber'
  
  
  constructor: ->
    super
    
    # Get number of rows in data
    @rows = @hdu.data.rows
    @render()
  
  getData: ->
    return if @inMemory
    @inMemory = true
    
    tableContainer = @el[0].querySelector('.table-container')
    tableContainer.addEventListener('scroll', @scroll, false)
    
    # Create table header using document fragments
    thead = document.querySelector("article:nth-child(#{@index + 1}) .table-container thead")
    fragment = document.createDocumentFragment()
    for column, index in @hdu.data.columns
      th = document.createElement('th')
      id = "th-#{@index}-#{index}"
      th.appendChild(document.createTextNode(column))
      fragment.appendChild(th)
    
    thead.appendChild(fragment)
    
    # Populate table with first ten rows
    rows = if @rows < 14 then @rows else 14
    
    # Place initial data in table
    dataunit = @hdu.data
    dataunit.getRows(0, rows, (data) =>
      @renderRows(data)
    )
    
    @tbody = d3.select("article:nth-child(#{@index + 1}) .table-container tbody")
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
    
    return
    
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
  
  render: ->
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
    
    pattern = if header.get('XTENSION') is 'TABLE' then Table.ascii else Table.binary
    
    for i in [1..cols]
      form = "TFORM#{i}"
      type = "TTYPE#{i}"
      match = header.get(form).match(pattern)
      if match?
        columns[header.get(type)] = i - 1
    return columns
  
  sortByColumn: (e) ->
    column = e.target.__data__  # When creating tables, D3 sets this property
    @cross.sortByColumn(column)
    
  scroll: (e) =>
    clientHeight  = e.target.clientHeight
    scrollHeight  = e.target.scrollHeight
    scrollTop     = e.target.scrollTop
    
    state = clientHeight is scrollHeight - scrollTop
    # @cross.onScroll() if state
  
  shortcuts: (e) =>
    keyCode = e.keyCode

    # Escape
    if keyCode is 27
      @el[0].querySelector("#clear-#{@index}").checked = true
  
module.exports = Table