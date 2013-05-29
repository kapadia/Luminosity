
class Graph extends Spine.Controller
  
  # Must be initialized with an axes (1, 2, 3)
  constructor: ->
    super
    
    @type = Graph.getType(@axes)
    @render()
    
    @drag = false
    @resize = @el.find('.resize')
    @resize.on('mousedown', @mousedown)
    @resize.on('mouseup', @mouseup)
    @resize.on('mousemove', @mousemove)
    @resize.on('mousemove', @mouseout)
    
    @plot = @el.find('.graph')
    @info = $('#info')
    
    for axis in [1..@axes]
      @["axis#{axis}"] = @el.find("select[data-axis='#{axis}']")

    @saveButton = @el.find('button[name=save]')
    @saveButton.prop('disabled', true)
  
  render: =>
    attrs = {columns: @columns, name: @name, axes: @axes}
    @html require('views/plot')(attrs)
    
  mousedown: (e) =>
    @drag = true
    @down = [e.offsetX, e.offsetY]
  mouseup: =>
    @drag = false
  mouseout: => @mouseup()
  mousemove: (e) =>
    return unless @drag
    
    corner = e.target.dataset.corner
    offset = @el.offset()
    
    width   = offset.width
    height  = offset.height
    top     = offset.top
    bottom  = Math.abs(offset.top - height)
    left    = offset.left
    right   = Math.abs(offset.left - width)
    
    dx = @drag[0] - e.offsetX
    dy = @drag[1] - e.offsetY
    
    switch corner
      when 'tl'
        @el.css('left', left + dx)
        @el.css('top', top + dy)
      # when 'tr'
      # when 'bl'
      # when 'br'
    
    
    @el.width(width + dx)
    @el.height(height + dy)
  
  zoom: =>
    @svg.select(".x.axis").call(@xAxis)
    @svg.select(".y.axis").call(@yAxis)
  
  savePlot: =>
    label = ""
    for i in [1..@axes]
      label += @["axis#{i}"].find("option:selected").text()
      label += '-'
    label = label.slice(0, -1)

    svg = @plot.find('svg')
    svg.attr('xmlns', 'http://www.w3.org/2000/svg')
    svg.attr('version', '1.1')
    window.URL = window.URL or window.webkitURL
    blob = new Blob([@plot.html()], {type: 'image/svg+xml'})

    a = document.createElement('a')
    a.download = "#{label}.svg"
    a.type = 'image/svg+xml'
    a.href = window.URL.createObjectURL(blob)
    a.click()
  
  @getType: (axes) ->
    switch axes
      when 1 then return 'histogram'
      when 2 then return 'scatter-2d'
      when 3 then return 'scatter-3d'

module.exports = Graph