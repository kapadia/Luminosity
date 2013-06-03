
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
    
    
    # Massage fitsjs header
    # TODO: Ideally this step should not be needed
    wcsObj = {}
    for card, datum of header.cards
      wcsObj[card] = datum.value
    
    @wcs = new WCS.Mapper(wcsObj)
    dataunit.getFrame(0, (arr) =>
      
      # Hide DOM element
      $(".read-image").hide()
      
      # Compute extent
      dataunit.getExtent(arr)
      
      # Broadcast that data is ready
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
    @drawHistogram(arr, @hdu.data.min, @hdu.data.max)
    
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
  
  getHistogram: (arr, min, max, bins) ->
    range = max - min
    
    h = new Uint32Array(bins)
    i = arr.length
    while i--
      value = arr[i]
      index = ~~(((value - min) / range) * bins)
      h[index] += 1
    h.dx = range / bins
    
    return h
  
  drawHistogram: (arr, min, max) ->
    
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
    
    selector = "article:nth-child(#{@index + 1}) .histogram"
    histogram = @getHistogram(arr, min, max, 1000)
    formatCount = d3.format(",.0f")
    
    margin =
      top: 10
      right: 30
      bottom: 30
      left: 30
    
    width = 600 - margin.left - margin.right
    height = 300 - margin.top - margin.bottom
    
    x = d3.scale.linear()
      .domain([min, max])
      .range([0, width])
    
    y = d3.scale.linear()
      .domain([0, d3.max(histogram)])
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
        .data(histogram)
      .enter().append("g")
        .attr("class", "bar")
        .attr("transform", (d, i) -> return "translate(#{x(min + i * histogram.dx)}, #{y(d)})")
    
    bar.append("rect")
      .attr("x", 1)
      .attr("width", 1)
      .attr("height", (d) -> return height - y(d))
      
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


module.exports = Image