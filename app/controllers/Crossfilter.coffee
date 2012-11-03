
class Crossfilter
  
  constructor: ->
    console.log 'Crossfilter', arguments
    
    @cross = crossfilter(@data)
    
module.exports = Crossfilter