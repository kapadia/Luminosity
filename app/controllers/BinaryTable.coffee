Spine = require('spine')

class BinaryTable extends Spine.Controller
  elements:
    'input[name=number]'  : 'rowNumber'
  
  events:
    'click input[name=submit]'    : 'selectRows'
    'click input[name=next]'      : 'nextRows'
    'click input[name=prev]'      : 'prevRows'
    'keydown input[name=number]'  : 'blockLetter'
  
  @permittedKeys = [48..57]
  @permittedKeys.push(8)
  
  constructor: ->
    super
    console.log 'BinaryTable'
    @rows = @hdu.data.rows
    
    @render()
    
  render: =>
    number = if @rows < 10 then @rows else 10
    table = []
    
    while number--
      table.push @hdu.data.getRow()
    info = {columns: @hdu.data.columns, table: table}
    @html require('views/bintable')(info)
    
  blockLetter: (e) ->
    keyCode = e.keyCode
    permittedKeys = [48..57]
    permittedKeys.push(8)
    unless keyCode in permittedKeys
      e.preventDefault()
    
  # Methods for controlling which data are displayed on the table
  selectRows: (e) =>
    rowNumber = parseInt(@rowNumber.val()) - 1
    dataunit = @hdu.data
    dataunit.rowsRead = rowNumber
    
    # Determine the number of rows to grab
    numRows = dataunit.rows - rowNumber
    numRows = if numRows < 10 then numRows else 10
    
    table = []
    for i in [0..numRows]
      table.push dataunit.getRow()
    info = {columns: dataunit.columns, table: table}
    @html require('views/bintable')(info)
  
  nextRows: (e) =>
    dataunit = @hdu.data
    console.log 'nextRows', dataunit.rowsRead
    
    rowsRead = dataunit.rowsRead
    
    unless @checkRow(rowsRead)
      alert("NO!")
      return null
    
    table = []
    for i in [rowsRead..rowsRead+9]
      console.log i
      table.push dataunit.getRow(i)
    
    info = {columns: dataunit.columns, table: table}
    @html require('views/bintable')(info)
    
  prevRows: (e) =>
    dataunit = @hdu.data
    console.log 'prevRows', dataunit.rowsRead
    
    rowsRead = dataunit.rowsRead - 20
    
    unless @checkRow(rowsRead)
      alert("NO!")
      return null
    
    table = []
    for i in [rowsRead..rowsRead+9]
      console.log i
      table.push dataunit.getRow(row = i)
    
    info = {columns: dataunit.columns, table: table}
    @html require('views/bintable')(info)
  
  checkRow: (number) =>
    dataunit = @hdu.data
    return false if number < 0
    return false if number > dataunit.rows - 1
    return true
    
module.exports = BinaryTable