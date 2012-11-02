Spine = require('spine')
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
  
  constructor: ->
    super
    @rows = @hdu.data.rows
    
    @render()
    @tbody = @el.find('tbody')
    
    # Populate table with first ten rows
    number = if @rows < 10 then @rows else 10
    table = []
    while number--
      table.push @hdu.data.getRow()
    @tbody.html require('views/tbody')({table: table})
    
    # Initialize a plot objects
    columns = @getNumericalColumns()
    
    @histogramElem = $("#hdu-#{@index} .histogram")
    @histogram = new Histogram({el: @histogramElem, hdu: @hdu, index: @index, columns: columns})
    
    @scatter2dElem = $("#hdu-#{@index} .scatter-2d")
    @scatter2d = new Scatter2D({el: @scatter2dElem, hdu: @hdu, index: @index, columns: columns})
    
    @scatter3dElem = $("#hdu-#{@index} .scatter-3d")
    @scatter3d = new Scatter3D({el: @scatter3dElem, hdu: @hdu, index: @index, columns: columns})
    
  render: =>
    info = {columns: @hdu.data.columns, rows: @hdu.data.rows}
    @html require('views/bintable')(info)
  
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
    
    table = []
    for i in [rowsRead..rowsRead+count]
      table.push dataunit.getRow(i)
    
    @tbody.html require('views/tbody')({table: table})
  
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