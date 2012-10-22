Spine = require('spine')

class BinaryTable extends Spine.Controller
  elements:
    'input[name=number]'  : 'rowNumber'
  
  events:
    'keydown input[name=number]'  : 'blockLetter'
    'click input[name=submit]'    : 'updateRows'
    'click input[name=next]'      : 'updateRows'
    'click input[name=prev]'      : 'updateRows'
  
  @permittedKeys: [48..57]
  @.permittedKeys.push(8)
  
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
    unless keyCode in BinaryTable.permittedKeys
      e.preventDefault()
  
  updateRows: (e) =>
    dataunit = @hdu.data
    
    switch e.target.name
      when 'next'
        rowsRead = dataunit.rowsRead
      when 'prev'
        rowsRead = Math.max(dataunit.rowsRead - 2 * 10, 0)
        
      when 'submit'
        rowsRead = parseInt(@rowNumber.val())
    
    count = dataunit.rows - rowsRead
    count = if count < 10 then count else 10
    count -= 1
    
    unless @checkRow(rowsRead)
      alert("NO!")
      return null
    
    table = []
    for i in [rowsRead..rowsRead+count]
      table.push dataunit.getRow(i)
      
    # Would be better to call render here
    info = {columns: dataunit.columns, table: table}
    @html require('views/bintable')(info)
  
  checkRow: (number) =>
    dataunit = @hdu.data
    return false if number < 0
    return false if number > dataunit.rows - 1
    return true
    
module.exports = BinaryTable