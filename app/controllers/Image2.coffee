Spine = require('spine')
WebGL = require('lib/WebGL')

class Image2 extends Spine.Controller
  @viewportWidth  = 400
  @viewportHeight = 300
  @numberOfBins   = 500
  
  constructor: ->
    console.log 'Image2'
    super
    
    # Check fro WebGL
    return null unless WebGL.check()
    
    @html require('views/image')()
    
    # Grab a few DOM elements
    @stretch = document.querySelector("#dataunit-#{@index} .stretch")
    
    # Read the data from the image
    data = @item.data
    data.getFrameWebGL()
    data.getExtremes()
    
    # Setup histogram
    @computeHistogram()
    @drawHistogram()
    
    # WebGL setup
    @initGL()

  initGL: ->
    # Grab the containing element
    container = document.querySelector("#dataunit-#{@index} .fits-viewer")
    
    # Create a canvas and append it to the container
    canvas = document.createElement('canvas')
    canvas.setAttribute('class', 'webgl-fits')
    canvas.setAttribute('width', Image2.viewportWidth)
    canvas.setAttribute('height', Image2.viewportHeight)
    container.appendChild(canvas)
    
    # Attempt to initialize a WebGL context
    try
      @gl = canvas.getContext("experimental-webgl")
      console.log @gl
      @gl.viewportWidth = canvas.width
      @gl.viewportHeight = canvas.height
    catch e
      console.log e
      
    unless @gl
      alert "Could not initialise WebGL"
      return null
    
    
    
    
    

  computeHistogram: ->
    console.log 'computeHistogram'
    data = @item.data
    pixels = data.data
    
    min   = data.min
    max   = data.max
    range = max - min
    
    sum = 0
    bins = Image2.numberOfBins
    @histogram = new Uint32Array(bins + 1)
    for pixel in pixels
      sum += pixel
      
      index = Math.floor(((pixel - min) / range) * bins)
      @histogram[index] += 1
      
    @mean = sum / pixels.length
    @histogramMax = Math.max.apply Math, @histogram
    @histogramMin = Math.min.apply Math, @histogram
    console.log @histogram, @mean
    
  drawHistogram: ->
    console.log 'drawHistogram'
    return null unless @histogram?
    
    # Define brush events
    brushstart = ->
      chart.classed "selecting", true
    brushmove = ->
      s = d3.event.target.extent()
      bars.classed "selected", (d) ->
        s[0] <= d and d <= s[1]
        
      console.log s
      
    brushend = ->
      chart.classed "selecting", not d3.event.target.empty()
    
    margin =
      top: 0
      right: 20
      bottom: 60
      left: 10
    w = 530 - margin.right - margin.left
    h = 260 - margin.top - margin.bottom
    
    # Create scales for both axes
    x = d3.scale.linear()
      .domain([0, Image2.numberOfBins])
      .range([0, w])
    
    y = d3.scale.linear()
      .domain([0, d3.max(@histogram)])
      .range([0, h])
    
    # Create a chart object
    chart = d3.select("#dataunit-#{@index} .histogram").append('svg')
      .attr('class', 'chart')
      .attr('width', w + margin.right + margin.left)
      .attr('height', h + margin.top + margin.bottom)
      .append('g')
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
    
    # Create a parent element for the chart
    main = chart.append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
      .attr('width', w)
      .attr('height', h)
      .attr('class', 'main')
    
    # Add the data to the chart
    bars = chart.selectAll('rect')
      .data(@histogram)
      .enter().append('rect')
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
      .orient('bottom')

    # Append the x axis to the parent object
    main.append('g')
      .attr('transform', 'translate(' + -1 * margin.left + ',' + h + ')')
      .attr('class', 'main axis date')
      .call(xAxis)
    
    # Append the brush
    chart.append('g')
      .attr('class', "brush")
      .attr('width', w)
      .attr('height', h)
      .call(d3.svg.brush().x(x)
      .on("brushstart", brushstart)
      .on("brush", brushmove)
      .on("brushend", brushend))
      .selectAll("rect")
      .attr("height", h)
    
module.exports = Image2