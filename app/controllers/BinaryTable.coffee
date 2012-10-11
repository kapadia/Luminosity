Spine = require('spine')

class BinaryTable extends Spine.Controller
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
    console.log table
    info = {columns: @hdu.data.columns, table: table}
    @html require('views/bintable')(info)
    
module.exports = BinaryTable