
{Controller}  = require('spine')


class Image extends Controller
  nBins: 5000
  inMemory: false
  
  elements:
    '.viewport'           : 'viewport'
    '[data-type="x"]'     : 'xEl'
    '[data-type="y"]'     : 'yEl'
    '[data-type="ra"]'    : 'raEl'
    '[data-type="dec"]'   : 'decEl'
    '[data-type="flux"]'  : 'fluxEl'
  
  events:
    'click .options label'      : 'onStretch'
    'mouseover .options label'  : 'onStretch'
    'mouseleave .options'       : 'resetStretch'
  
  
  constructor: ->
    super
    
    # Get common parameters describing data
    @width = @hdu.header.get('NAXIS1')
    @height = @hdu.header.get('NAXIS2')
    
    @html require('views/image')({index: @index})
    
    # Set current stretch
    # APPSTATE: Storing on controller for now.  Find better way
    #           preserve application state.
    @currentStretch = 'linear'
    
    
    @bind 'data-ready', @draw
    
    # Setup sockets if there is a socket instance
    @setupSockets() if @socket?
  
  getData: ->
    header = @hdu.header
    dataunit = @hdu.data
    
    wcsKeywords =
      WCSAXES: header.get('WCSAXES')
      NAXIS: header.get("NAXIS")
      RADESYS: header.get("RADESYS")
      CTYPE1: header.get("CTYPE1")
      CTYPE2: header.get("CTYPE2")
      CRPIX1: header.get("CRPIX1")
      CRPIX2: header.get("CRPIX2")
      CUNIT1: header.get("CUNIT1")
      CUNIT2: header.get("CUNIT2")
      CRVAL1: header.get("CRVAL1")
      CRVAL2: header.get("CRVAL2")
      CD1_1: header.get("CD1_1")
      CD1_2: header.get("CD1_2")
      CD2_1: header.get("CD2_1")
      CD2_2: header.get("CD2_2")
    
    @wcs = new WCS.Mapper(wcsKeywords)
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
    stretch = e.target.dataset.fn
    if e.type is 'click'
      @currentStretch = stretch
    @wfits.setStretch(stretch)
  
  resetStretch: (e) =>
    @wfits.setStretch(@currentStretch)
  
  draw: (arr) ->
    @unbind 'data-ready', @draw
    
    # Setup histogram
    # @computeHistogram(arr)
    @drawHistogramII(arr, @hdu.data.min, @hdu.data.max)
    
    # Define mouse callbacks for WebFITS
    opts =
      arr: arr
      width: @width
    
    onmousemove = (x, y, opts) =>
      arr = opts.arr
      width = opts.width
      sky = @wcs.pixelToCoordinate([x, y])
      @xEl.text(x)
      @yEl.text(y)
      @raEl.text(sky.ra)
      @decEl.text(sky.dec)
      @fluxEl.text(arr[x + width * y])
    
    # Create a WebFITS object
    @wfits = new astro.WebFITS(@viewport[0], 600)
    @wfits.setupControls({onmousemove: onmousemove}, opts)
    @wfits.loadImage("visualization-#{@index}", arr, @width, @height)
    @wfits.setExtent(@hdu.data.min, @hdu.data.max)
    @wfits.setStretch('linear')
  
  drawHistogramII: (arr, min, max) ->
    nBins = 100
    
    # Define brush events
    brushstart = ->
      svg.classed "selecting", true
    brushmove = =>
      s = d3.event.target.extent()
      bar.classed "selected", (d) ->
        s[0] <= d and d <= s[1]
      
      @wfits.setExtent(s[0], s[1])
    brushend = ->
      svg.classed "selecting", not d3.event.target.empty()
    
    
    # Cast to normal array
    values = []
    for value, index in arr
      values[index] = value
    
    selector = "article:nth-child(#{@index + 1}) .histogram"
    
    formatCount = d3.format(",.0f")
    margin = {top: 10, right: 30, bottom: 30, left: 30}
    width = 400 - margin.left - margin.right
    height = 300 - margin.top - margin.bottom
    
    x = d3.scale.linear()
      .domain(d3.extent(values))
      .range([0, width])
    
    data = d3.layout.histogram()
      .bins(x.ticks(nBins))(values)
    
    y = d3.scale.linear()
      .domain([0, d3.max(data, (d) -> return d.y)])
      .range([height, 0])
    
    xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")
      .ticks(6)
    
    svg = d3.select(selector).append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(#{margin.left}, #{margin.top})")
    
    bar = svg.selectAll(".bar")
      .data(data)
    .enter().append("g")
      .attr("class", "bar")
      .attr("transform", (d) -> return "translate(#{x(d.x)}, #{y(d.y)})")
    
    bar.append("rect")
      .attr("x", 1)
      .attr("width", 1)
      .attr("height", (d) -> return height - y(d.y))
    
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0, #{height})")
      .call(xAxis)
    
    # Append the brush
    svg.append('g')
      .attr('class', 'brush')
      .attr('width', width)
      .attr('height', height)
      .call(d3.svg.brush().x(x)
      .on('brushstart', brushstart)
      .on('brush', brushmove)
      .on('brushend', brushend))
      .selectAll('rect')
      .attr('height', height)
  
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