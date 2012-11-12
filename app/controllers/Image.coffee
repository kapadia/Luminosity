Spine   = require('spine')
WebGL   = require('lib/WebGL')

class Image extends Spine.Controller
  @viewportWidth  = 600
  @viewportHeight = 600
  @numberOfBins   = 500
  
  constructor: ->
    super
    
    @html require('views/image')()
    
    # Grab a few DOM elements
    @stretch  = document.querySelector("#hdu-#{@index} .stretch")
    @viewer   = document.querySelector("#hdu-#{@index} .fits-viewer")
    @xEl      = $("#hdu-#{@index} .x")
    @yEl      = $("#hdu-#{@index} .y")
    @pixelEl  = $("#hdu-#{@index} .pixel")
    @info     = $("#hdu-#{@index} .info")
    
    # Read the data from the image
    @bind 'dataready', @finishSetup
    @readImageData()
    
    @stretch.addEventListener('change', @changeStretch, false)
  
  changeStretch: =>
    extremesLocation = @gl.getUniformLocation(@program, 'u_extremes')
    extremes = @gl.getUniform(@program, extremesLocation)
    
    @program = @programs[@stretch.value]
    @gl.useProgram(@program)
    
    extremesLocation = @gl.getUniformLocation(@program, 'u_extremes')
    @gl.uniform2fv(extremesLocation, extremes)
    
    @drawScene()
  
  finishSetup: ->
    # Setup histogram
    @computeHistogram()
    @drawHistogram()

    # Setup up WebGL and interface
    @setupWebGL()
    @setupWebGLUI()
  
  readImageData: ->
    
    dataunit = @hdu.data
    [@width, @height] = [dataunit.width, dataunit.height]
    
    # Initialize a Float32Array for WebGL
    dataunit.data = new Float32Array(@width * @height)
    
    dataunit.totalRowsRead = dataunit.width * dataunit.frame
    dataunit.rowsRead = 0
    
    height = dataunit.height
    rowsRead = 0
    
    #
    # This is brute force code.  It seems most stable but is a terrible
    # user experience locking the browser.
    #
    
    dataunit.getFrame()
    $(".read-image").hide()
    dataunit.getExtremes()
    @trigger 'dataready'
  
  setupWebGL: ->    
    container = document.querySelector("#hdu-#{@index} .fits-viewer")
    @canvas   = WebGL.setupCanvas(container, Image.viewportWidth, Image.viewportHeight)
    
    # Set up variables for panning and zooming
    @xOffset = -@width / 2
    @yOffset = -@height / 2
    @xOldOffset = @xOffset
    @yOldOffset = @yOffset
    @scale = 2 / @width
    @minScale = 1 / (Image.viewportWidth * Image.viewportWidth)
    @maxScale = 2
    @drag = false

    @canvas.onmousedown = (e) =>
      @drag = true
      @viewer.style.cursor = "move"
      
      @xOldOffset = @xOffset
      @yOldOffset = @yOffset
      @xMouseDown = e.clientX 
      @yMouseDown = e.clientY

    @canvas.onmouseup = (e) =>
      @drag = false
      @viewer.style.cursor = "crosshair"
      
      # Prevents a NaN from being sent to the GPU
      return null unless @xMouseDown?
      
      xDelta = e.clientX - @xMouseDown
      yDelta = e.clientY - @yMouseDown
      @xOffset = @xOldOffset + (xDelta / @canvas.width / @scale * 2.0)
      @yOffset = @yOldOffset - (yDelta / @canvas.height / @scale * 2.0)
      @drawScene()
    
    @canvas.onmousemove = (e) =>
      xDelta = -1 * (@canvas.width / 2 - e.offsetX) / @canvas.width / @scale * 2.0
      yDelta = (@canvas.height / 2 - e.offsetY) / @canvas.height / @scale * 2.0
      
      x = ((-1 * (@xOffset + 0.5)) + xDelta) + 1.5 << 0
      y = ((-1 * (@yOffset + 0.5)) + yDelta) + 1.5 << 0
      
      @xEl.text("#{x}")
      @yEl.text("#{y}")
      @pixelEl.text("#{@hdu.data.getPixel(x, y)}")
      
      return unless @drag
      
      xDelta = e.clientX - @xMouseDown
      yDelta = e.clientY - @yMouseDown
      
      @xOffset = @xOldOffset + (xDelta / @canvas.width / @scale * 2.0)
      @yOffset = @yOldOffset - (yDelta / @canvas.height / @scale * 2.0)
      
      @drawScene()
    
    @canvas.onmouseout = (e) =>
      @drag = false
      @viewer.style.cursor = "crosshair"
      
    @canvas.onmouseover = (e) =>
      @drag = false
      @viewer.style.cursor = "crosshair"
    
    # Listen for the mouse wheel
    @canvas.addEventListener('mousewheel', @wheelHandler, false)
    @canvas.addEventListener('DOMMouseScroll', @wheelHandler, false)
    
    @gl   = WebGL.create3DContext(@canvas)
    @ext  = @gl.getExtension('OES_texture_float')
    
    unless @ext
      alert "No OES_texture_float"
      return null
    
    @vertexShader = WebGL.loadShader(@gl, WebGL.vertexShader, @gl.VERTEX_SHADER)
  
  wheelHandler: (e) =>
    e.preventDefault()
    factor = if e.shiftKey then 1.01 else 1.1
    @scale *= if (e.detail or e.wheelDelta) < 0 then factor else 1 / factor
    
    # Probably not the most efficient way to do this ...
    @scale = if @scale > @maxScale then @maxScale else @scale
    @scale = if @scale < @minScale then @minScale else @scale
    @drawScene()
  
  setupWebGLUI: ->
    
    # Store parameters needed for rendering
    stretch = @stretch.value
    minimum = @hdu.data.min
    maximum = @hdu.data.max
    
    unless @programs?
      @programs = {}
      
      # No programs so we make them
      for func in ['linear', 'logarithm', 'sqrt', 'arcsinh', 'power']
        fragmentShader  = WebGL.loadShader(@gl, WebGL.fragmentShaders[func], @gl.FRAGMENT_SHADER)
        @programs[func] = WebGL.createProgram(@gl, [@vertexShader, fragmentShader])
      
      # Select and use a program
      @program = @programs[stretch]
      @gl.useProgram(@program)
      
      # Grab locations of WebGL program variables
      positionLocation    = @gl.getAttribLocation(@program, 'a_position')
      texCoordLocation    = @gl.getAttribLocation(@program, 'a_textureCoord')
      extremesLocation    = @gl.getUniformLocation(@program, 'u_extremes')
      offsetLocation      = @gl.getUniformLocation(@program, 'u_offset')
      scaleLocation       = @gl.getUniformLocation(@program, 'u_scale')
      
      texCoordBuffer = @gl.createBuffer()
      @gl.bindBuffer(@gl.ARRAY_BUFFER, texCoordBuffer)
      @gl.bufferData(
        @gl.ARRAY_BUFFER,
        new Float32Array([0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0]),
        @gl.STATIC_DRAW)
      
      @gl.enableVertexAttribArray(texCoordLocation)
      @gl.vertexAttribPointer(texCoordLocation, 2, @gl.FLOAT, false, 0, 0)
      
      texture = @gl.createTexture()
      @gl.bindTexture(@gl.TEXTURE_2D, texture)
      
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE)
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE)
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
      
      # Pass the uniforms
      @gl.uniform2f(extremesLocation, minimum, maximum)
      @gl.uniform2f(offsetLocation, @xOffset, @yOffset)
      @gl.uniform1f(scaleLocation, @scale)
      
      buffer = @gl.createBuffer()
      @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer)
      @gl.enableVertexAttribArray(positionLocation)
      @gl.vertexAttribPointer(positionLocation, 2, @gl.FLOAT, false, 0, 0)
      @setRectangle(0, 0, @width, @height)
      @gl.drawArrays(@gl.TRIANGLES, 0, 6)
      
    # Update texture
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.LUMINANCE, @width, @height, 0, @gl.LUMINANCE, @gl.FLOAT, @hdu.data.data)
    @gl.drawArrays(@gl.TRIANGLES, 0, 6)
  
  setRectangle: (x, y, width, height) ->
    [x1, x2] = [x, x + width]
    [y1, y2] = [y, y + height]
    @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array([x1, y1, x2, y1, x1, y2, x1, y2, x2, y1, x2, y2]), @gl.STATIC_DRAW)
  
  drawScene: ->
    offsetLocation = @gl.getUniformLocation(@program, 'u_offset')
    scaleLocation = @gl.getUniformLocation(@program, 'u_scale')
    @gl.uniform2f(offsetLocation, @xOffset, @yOffset)
    @gl.uniform1f(scaleLocation, @scale)
    @setRectangle(0, 0, @width, @height)
    @gl.drawArrays(@gl.TRIANGLES, 0, 6)
  
  # TODO: Possible optimization using a radix sort
  computeHistogram: ->
    data = @hdu.data
    pixels = data.data
    
    min   = data.min
    max   = data.max
    range = max - min
    
    sum = 0
    bins = Image.numberOfBins
    binSize = range / bins
    length = pixels.length
    
    @histogram = new Uint32Array(bins + 1)
    for pixel in pixels
      sum += pixel
      
      index = Math.floor(((pixel - min) / range) * bins)
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
    
    @histogramLowerIndex = Math.floor(((pixel - @histogramMin) / range) * bins)
    @histogramUpperIndex = Math.floor(((pixel - @histogramMax) / range) * bins)
  
  # TODO: Generalize histogram class further to utilize here
  drawHistogram: =>
    return null unless @histogram?
    
    # Define brush events
    brushstart = ->
      svg.classed "selecting", true
    brushmove = =>
      s = d3.event.target.extent()
      bars.classed "selected", (d) ->
        s[0] <= d and d <= s[1]
      
      extremesLocation = @gl.getUniformLocation(@program, 'u_extremes')
      @gl.uniform2f(extremesLocation, s[0], s[1])
      @gl.drawArrays(@gl.TRIANGLES, 0, 6)
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
    svg = d3.select("#hdu-#{@index} .histogram").append('svg')
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