
{Controller}  = require('spine')


class Image extends Controller
  nBins: 5000
  inMemory: false
  
  elements:
    '.fits-viewer'  : 'viewport'
    '.x'            : 'xEl'
    '.y'            : 'yEl'
    '.pixel'        : 'pixelEl'
    '.info'         : 'info'
  
  events:
    'change .stretch' : 'onStretch'
  
  
  constructor: ->
    super
    
    # Get common parameters describing data
    @width = @hdu.header.get('NAXIS1')
    @height = @hdu.header.get('NAXIS2')
    
    @html require('views/image')()
    
    # Get DOM elements
    @stretch  = @el[0].querySelector('.stretch')
    
    @bind 'data-ready', @draw
    
    # Setup sockets if there is a socket instance
    @setupSockets() if @socket?
  
  getData: ->
    dataunit = @hdu.data
    
    dataunit.getFrame(0, (arr) =>
      
      $(".read-image").hide()
      dataunit.getExtent(arr)
      @trigger 'data-ready', arr
      
    )
  
  setupSockets: ->
    
    @socket.on('zoom', (data) =>
      unless @socket.socket.sessionid is data.id
        @scale = data.zoom
        @drawScene()
    )
    
    @socket.on('translation', (data) =>
      unless @socket.socket.sessionid is data.id
        @xOffset = data.xOffset
        @yOffset = data.yOffset
        @drawScene()
    )
  
  onStretch: (e) =>
    @wfits.setStretch(e.target.value)
  
  draw: (arr) ->
    @unbind 'data-ready', @draw
    
    # Setup histogram
    @computeHistogram(arr)
    @drawHistogram()
    
    # Create a WebFITS object
    @wfits = new astro.WebFITS(@viewport[0], 600)
    @wfits.setupControls()
    @wfits.loadImage("visualization-#{@index}", arr, @width, @height)
    @wfits.setExtent(@hdu.data.min, @hdu.data.max)
    @wfits.setStretch('linear')
  
  # TODO: Possible optimization using a radix sort
  computeHistogram: (arr) ->
    dataunit = @hdu.data
    
    min   = dataunit.min
    max   = dataunit.max
    range = max - min
    
    sum = 0
    bins = @nBins
    binSize = range / bins
    length = arr.length
    
    @histogram = new Uint32Array(bins + 1)
    for value in arr
      sum += value
      
      index = Math.floor(((value - min) / range) * bins)
      @histogram[index] += 1
      
    @mean = sum / length
    
    # Compute standard deviation
    sum = 0
    for count, index in @histogram
      value = min + index * binSize
      diff = value - @mean
      sum += (diff * diff) * count
    @std = Math.sqrt(sum / length)
    
    @histogramMax = Math.max.apply Math, @histogram
    @histogramMin = Math.min.apply Math, @histogram
    
    @histogramLowerIndex = Math.floor(((value - @histogramMin) / range) * bins)
    @histogramUpperIndex = Math.floor(((value - @histogramMax) / range) * bins)
  
  # TODO: Generalize histogram class further to utilize here
  drawHistogram: ->
    return null unless @histogram?
    
    # Define brush events
    brushstart = ->
      svg.classed "selecting", true
    brushmove = =>
      s = d3.event.target.extent()
      bars.classed "selected", (d) ->
        s[0] <= d and d <= s[1]
      
      @wfits.setExtent(s[0], s[1])
    brushend = ->
      svg.classed "selecting", not d3.event.target.empty()
    
    margin =
      top: 0
      right: 20
      bottom: 60
      left: 10
    
    w = 390 - margin.right - margin.left
    h = 260 - margin.top - margin.bottom
    
    # Grab some info about the data
    data = @hdu.data
    [min, max] = [data.min, data.max]
    
    # Create scales for both axes
    x = d3.scale.linear()
      .domain([min, max])
      .range([0, w])
    
    y = d3.scale.linear()
      .domain([0, d3.max(@histogram)])
      .range([0, h])
    
    # Create the SVG
    # TODO: Find way to set a selection root with D3
    svg = d3.select("article:nth-child(#{@index + 1}) .histogram").append('svg')
      .attr('width', w + margin.right + margin.left)
      .attr('height', h + margin.top + margin.bottom)
      .append('g')
      .attr('transform', "translate(#{margin.left}, #{margin.top})")
    
    # Create a parent element for the svg
    main = svg.append('g')
      .attr('transform', "translate(#{margin.left}, #{margin.top})")
      .attr('width', w)
      .attr('height', h)
      .attr('class', 'main')
    
    # Add the data
    bars = svg.selectAll('rect')
      .data(@histogram)
      .enter().append('rect' )
      .attr('x', ((d, i) ->
        return i * 1.25 + margin.left
      ))
      .attr('y', ((d) ->
        return h - y(d) + margin.top - 1.5
      ))
      .attr('width', 1)
      .attr('height', ((d) ->
        return y(d)
      ))
    
    # Create an x axis
    xAxis = d3.svg.axis()
      .scale(x)
      .ticks(6)
      .orient('bottom')

    # Append the x axis to the parent object
    main.append('g')
      .attr('transform', "translate(#{-1 * margin.left}, #{h})")
      .attr('class', 'main axis date')
      .call(xAxis)
    
    # Append the brush
    svg.append('g')
      .attr('class', 'brush')
      .attr('width', w)
      .attr('height', h)
      .call(d3.svg.brush().x(x)
      .on('brushstart', brushstart)
      .on('brush', brushmove)
      .on('brushend', brushend))
      .selectAll('rect')
      .attr('height', h)


module.exports = Image