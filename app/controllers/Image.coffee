
{Controller}  = require('spine')


class Image extends Controller
  nBins: 10000
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
    @setupSocketEvents() if @socket?
  
  getData: ->
    return if @inMemory
    
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
      [min, max] = dataunit.getExtent(arr)
      
      # Broadcast that data is ready
      @trigger 'data-ready', arr, min, max
      
    )
  
  setupSocketEvents: ->
    
    @socket.on('zoom', (zoom) =>
      @wfits.zoom = zoom
      @wfits.draw()
    )
    
    @socket.on('translation', (data) =>
      @wfits.xOffset = data[0]
      @wfits.yOffset = data[1]
      @wfits.draw()
    )
    
    @socket.on('scale', (min, max) =>
      @wfits.setExtent(min, max)
    )
  
  onStretch: (e) =>
    stretch = e.target.dataset.fn
    if e.type is 'click'
      @currentStretch = stretch
    @wfits.setStretch(stretch)
  
  resetStretch: (e) =>
    @wfits.setStretch(@currentStretch)
  
  log10: (value) ->
    return Math.log(value) / Math.log(10)
  
  draw: (arr, min, max) ->
    @unbind 'data-ready', @draw
    
    # Setup histogram
    @drawHistogram(arr, min, max)
    
    # Define mouse callbacks for WebFITS
    opts =
      arr: arr
      width: @width
    
    _onmousemove = (x, y, opts) =>
      arr = opts.arr
      width = opts.width
      sky = @wcs.pixelToCoordinate([x, y])
      @xEl.text(x)
      @yEl.text(y)
      @raEl.text(sky.ra)
      @decEl.text(sky.dec)
      @fluxEl.text(arr[x + width * y])
    
    # Define mouse callbacks for when sockets is enabled
    mouseCallbacks = {}
    if @socket
      
      mouseCallbacks.onmousemove = (x, y, opts) =>
        _onmousemove(x, y, opts)
        @socket.emit 'translation', [@wfits.xOffset, @wfits.yOffset]
      
      mouseCallbacks.onzoom = =>
        @socket.emit 'zoom', @wfits.zoom
    
    else
      mouseCallbacks.onmousemove = _onmousemove
    
    # Create a WebFITS object
    @wfits = new astro.WebFITS(@viewport[0], 600)
    @wfits.setupControls(mouseCallbacks, opts)
    @wfits.loadImage("visualization-#{@index}", arr, @width, @height)
    @wfits.setExtent(min, max)
    @wfits.setStretch('linear')
    
    @inMemory = true
  
  getHistogram: (arr, min, max, bins) ->
    log10 = @log10
    
    console.log min, max
    min = log10(min)
    max = log10(max)
    console.log min, max
    range = max - min
    
    h = new Uint32Array(bins)
    i = arr.length
    while i--
      value = log10( arr[i] )
      index = ~~( ( (value - min) / range) * bins )
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
      if @socket
        @socket.emit 'scale', s[0], s[1]
      
    brushend = ->
      svg.classed "selecting", not d3.event.target.empty()
    
    selector = "article:nth-child(#{@index + 1}) .histogram"
    
    histogram = @getHistogram(arr, min, max, @nBins)
    formatCount = d3.format(",.0f")
    
    margin =
      top: 10
      right: 30
      bottom: 50
      left: 30
    
    width = 600 - margin.left - margin.right
    height = 300 - margin.top - margin.bottom
    
    # Create linear and log scales
    x = d3.scale.log()
      .domain([min, max])
      .range([0, width])
    
    xLog = d3.scale.log()
      .domain([min, max])
      .range([0, width])
    
    @xScale = x
    
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
      .append("text")
        .attr("class", "label")
        .attr("x", width)
        .attr("y", 34)
        .style("text-anchor", "end")
        .text("intensity")
        .on('click', =>
          
          # Toggle scale function
          @xScale = if @xScale is x then xLog else x
          
          svg.selectAll(".bar").data(histogram)
            .transition()
            .delay(1000)
            .duration(1000)
            .attr("transform", (d, i) => return "translate(#{@xScale(min + i * histogram.dx)}, #{y(d)})")
          svg.selectAll(".x")
            .transition()
            .delay(1000)
            .duration(2000)
            .call(xAxis.scale(@xScale))
        )
    
    # Append the brush
    svg.append('g')
      .attr('class', 'brush')
      .attr('width', width)
      .attr('height', height)
      .call(d3.svg.brush().x(@xScale)
      .on('brushstart', brushstart)
      .on('brush', brushmove)
      .on('brushend', brushend))
      .selectAll('rect')
      .attr('height', height)


module.exports = Image