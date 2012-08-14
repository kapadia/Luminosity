Spine = require('spine')
WebGL = require('lib/WebGL')

class Image extends Spine.Controller
  @viewportWidth  = 600
  @viewportHeight = 600
  @numberOfBins   = 500
  
  constructor: ->
    console.log 'Image'
    super
    
    # Check fro WebGL
    return null unless WebGL.check()
    
    @html require('views/image')()
    
    # Grab a few DOM elements
    @stretch = document.querySelector("#dataunit-#{@index} .stretch")
    
    # NOTE: Turning off stretch function for now.
    @stretch.style.display = 'none'
    
    # Read the data from the image
    data = @item.data
    [@width, @height] = [@item.header['NAXIS1'], @item.header['NAXIS2']]
    
    data.getFrameWebGL()
    data.getExtremes()
    
    # Setup histogram
    @computeHistogram()
    @drawHistogram()
    
    # Setup up WebGL and interface
    @setupWebGL()
    @setupWebGLUI()
  
  setupWebGL: ->
    console.log 'setupWebGL'
    
    container = document.querySelector("#dataunit-#{@index} .fits-viewer")
    @canvas   = WebGL.setupCanvas(container, Image.viewportWidth, Image.viewportHeight)
    
    # Set up variables for panning and zooming
    @mouseParameters =
      offset: [0.0, 0.0]
      oldOffset: [0.0, 0.0]
      scale: 1.0
      mouseDown: [null, null]
      drag: 0
      
    # Set up mouse interactions with canvas
    @canvas.onmousedown = (e) =>
      @mouseParameters.drag = 1
      @mouseParameters.oldOffset = @mouseParameters.offset
      @mouseParameters.mouseDown = [e.offsetX, e.offsetY]
    
    @canvas.onmousemove = (e) =>
      return if @mouseParameters.drag is 0
      xDelta = e.offsetX - @mouseParameters.mouseDown[0]
      yDelta = e.offsetY - @mouseParameters.mouseDown[1]
      
      @mouseParameters.offset[0] = @mouseParameters.oldOffset[0] - (xDelta / @canvas.width / @mouseParameters.scale * 2.0)
      @mouseParameters.offset[1] = @mouseParameters.oldOffset[1] - (yDelta / @canvas.height / @mouseParameters.scale * 2.0)
      @drawScene()
    
    @canvas.onmouseup = (e) =>
      @mouseParameters.drag = 0
      xDelta = e.offsetX - @mouseParameters.mouseDown[0]
      yDelta = e.offsetY - @mouseParameters.mouseDown[1]
      @mouseParameters.offset[0] = @mouseParameters.oldOffset[0] - (xDelta / @canvas.width / @mouseParameters.scale * 2.0)
      @mouseParameters.offset[1] = @mouseParameters.oldOffset[1] - (yDelta / @canvas.height / @mouseParameters.scale * 2.0)
      @drawScene()
    
    @canvas.onmouseout = (e) =>
      @mouseParameters.drag = 0
    
    # Listen for the mouse wheel
    @canvas.addEventListener('mousewheel', @wheelHandler, false)
    
    @gl       = WebGL.create3DContext(@canvas)
    @ext      = @gl.getExtension('OES_texture_float')
    
    unless @ext
      alert "No OES_texture_float"
      return null
    
    @vertexShader = WebGL.loadShader(@gl, WebGL.vertexShader, @gl.VERTEX_SHADER)
  
  wheelHandler: (e) =>
    e.preventDefault()
    e.stopPropagation()
    factor = if e.shiftKey then 1.01 else 1.1
    @mouseParameters.scale *= if (e.detail or e.wheelDelta) < 0 then factor else 1 / factor
    @drawScene()
  
  setupWebGLUI: ->
    console.log 'setupWebGLUI'
    
    # Store parameters needed for rendering
    stretch = @stretch.value
    minimum = @item.data.min
    maximum = @item.data.max
    
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
      resolutionLocation  = @gl.getUniformLocation(@program, 'u_resolution')
      extremesLocation    = @gl.getUniformLocation(@program, 'u_extremes')
      offsetLocation      = @gl.getUniformLocation(@program, 'u_offset')
      scaleLocation       = @gl.getUniformLocation(@program, 'u_scale')
      
      texCoordBuffer = @gl.createBuffer()
      @gl.bindBuffer(@gl.ARRAY_BUFFER, texCoordBuffer)
      @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array([0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0]), @gl.STATIC_DRAW)
      
      @gl.enableVertexAttribArray(texCoordLocation)
      @gl.vertexAttribPointer(texCoordLocation, 2, @gl.FLOAT, false, 0, 0)

      texture = @gl.createTexture()
      @gl.bindTexture(@gl.TEXTURE_2D, texture)
      
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE)
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE)
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
      
      # Pass the uniforms
      @gl.uniform2f(resolutionLocation, Image.viewportWidth, Image.viewportHeight)
      @gl.uniform2f(extremesLocation, minimum, maximum)
      @gl.uniform2fv(offsetLocation, @mouseParameters.offset)
      @gl.uniform1f(scaleLocation, @mouseParameters.scale)
      
      buffer = @gl.createBuffer()
      @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer)
      @gl.enableVertexAttribArray(positionLocation)
      @gl.vertexAttribPointer(positionLocation, 2, @gl.FLOAT, false, 0, 0)
      @setRectangle(0, 0, @width, @height)
      @gl.drawArrays(@gl.TRIANGLES, 0, 6)
      
    # Update texture
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.LUMINANCE, @width, @height, 0, @gl.LUMINANCE, @gl.FLOAT, @item.data.data)
    @gl.drawArrays(@gl.TRIANGLES, 0, 6)
  
  setRectangle: (x, y, width, height) ->
    [x1, x2] = [x, x + width]
    [y1, y2] = [y, y + height]
    @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array([x1, y1, x2, y1, x1, y2, x1, y2, x2, y1, x2, y2]), @gl.STATIC_DRAW)
  
  drawScene: ->
    offsetLocation = @gl.getUniformLocation(@program, 'u_offset')
    scaleLocation = @gl.getUniformLocation(@program, 'u_scale')
    @gl.uniform2fv(offsetLocation, @mouseParameters.offset)
    @gl.uniform1f(scaleLocation, @mouseParameters.scale)
    @setRectangle(0, 0, @width, @height)
    @gl.drawArrays(@gl.TRIANGLES, 0, 6)
  
  computeHistogram: ->
    console.log 'computeHistogram'
    data = @item.data
    pixels = data.data
    
    min   = data.min
    max   = data.max
    range = max - min
    
    sum = 0
    bins = Image.numberOfBins
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
    brushmove = =>
      s = d3.event.target.extent()
      bars.classed "selected", (d) ->
        s[0] <= d and d <= s[1]
      
      [min, max] = [@item.data.min, @item.data.max]
      f = (x) ->
        return (max - min) / Image.numberOfBins * x + min
      extremesLocation = @gl.getUniformLocation(@program, 'u_extremes')
      @gl.uniform2f(extremesLocation, f(s[0]), f(s[1]))
      @gl.drawArrays(@gl.TRIANGLES, 0, 6)
      
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
      .domain([0, Image.numberOfBins])
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
    
module.exports = Image