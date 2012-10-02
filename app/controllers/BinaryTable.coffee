Spine = require('spine')

class BinaryTable extends Spine.Controller
  constructor: ->
    super
    
    @html require('views/bintable')(@hdu.data)
    
module.exports = BinaryTable