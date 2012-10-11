ThreeHelpers = require('lib/ThreeHelpers')

class TableController extends Spine.Controller
  @scatterWidth   = 600
  @scatterHeight  = 600
  
  constructor: ->
    console.log 'Table', ThreeHelpers
    super
    
    @rows = @hdu.data.rows
    @render()
    
    # Store DOM elements
    #hdu-#{@index}
    @axes = $("#hdu-#{@index} select.axis")
    @plot = $("#hdu-#{@index} .plot")
    
    @createScatter3D()
    
    # Bind events for plots
    @axes.change (e) =>
      @trigger 'axisChange'
    @bind 'axisChange', @createPlot
  
  render: ->
    number = if @rows < 10 then @rows else 10
    table = []
    
    while number--
      table.push @hdu.data.getRow()
    info = {columns: @hdu.data.columns, table: table}
    @html require('views/table')(info)
  
  @createAxes3D: (plot, size) ->
    v = (x, y, z) => return new THREE.Vector3(x, y, z)
    
    lineGeo = new THREE.Geometry()
    lineGeo.vertices.push(
      v(-1 * size, 0, 0), v(size, 0, 0),
      v(0, -1 * size, 0), v(0, size, 0),
      v(0, 0, -1 * size), v(0, 0, size),

      v(-1 * size, size, -1 * size), v(size, size, -1 * size),
      v(-1 * size, -1 * size, -1 * size), v(size, -1 * size, -1 * size),
      v(-1 * size, size, size), v(size, size, size),
      v(-1 * size, -1 * size, size), v(size, -1 * size, size),

      v(-1 * size, 0, size), v(size, 0, size),
      v(-1 * size, 0, -1 * size), v(size, 0, -1 * size),
      v(-1 * size, size, 0), v(size, size, 0),
      v(-1 * size, -1 * size, 0), v(size, -1 * size, 0),

      v(size, -1 * size, -1 * size), v(size, size, -1 * size),
      v(-1 * size, -1 * size, -1 * size), v(-1 * size, size, -1 * size),
      v(size, -1 * size, size), v(size, size, size),
      v(-1 * size, -1 * size, size), v(-1 * size, size, size),

      v(0, -1 * size, size), v(0, size, size),
      v(0, -1 * size, -1 * size), v(0, size, -1 * size),
      v(size, -1 * size, 0), v(size, size, 0),
      v(-1 * size, -1 * size, 0), v(-1 * size, size, 0),

      v(size, size, -1 * size), v(size, size, size),
      v(size, -1 * size, -1 * size), v(size, -1 * size, size),
      v(-1 * size, size, -1 * size), v(-1 * size, size, size),
      v(-1 * size, -1 * size, -1 * size), v(-1 * size, -1 * size, size),

      v(-1 * size, 0, -1 * size), v(-1 * size, 0, size),
      v(size, 0, -1 * size), v(size, 0, size),
      v(0, size, -1 * size), v(0, size, size),
      v(0, -1 * size, -1 * size), v(0, -1 * size, size)
    )
    
    lineMat = new THREE.LineBasicMaterial({color: 0x808080, lineWidth: 1})
    line = new THREE.Line(lineGeo, lineMat)
    line.type = THREE.Lines
    plot.add(line)
  
  @createAxesLabel3D: (plot, labels, distance) ->
    axes = ['x', 'x', 'y', 'y', 'z', 'z']
    for label, index in labels
      axis = axes[index]
      
      title = ThreeHelpers.createText2D(label)
      title.position[axis] = Math.pow(-1, index + 1) * distance
      plot.add(title)
  
  createScatter3D: =>
    console.log 'createScatter3D'
    
    # Grab the data
    dataunit = @hdu.data
    dataunit.rowsRead = 0
    
    # Setup the parent div
    @scatterContainer = document.querySelector("#hdu-#{@index} .scatter3d")
    @scatterContainer.width   = TableController.scatterWidth
    @scatterContainer.height  = TableController.scatterHeight
    
    # Setup THREE 
    @renderer = new THREE.WebGLRenderer({antialias: true})
    @renderer.setSize(TableController.scatterWidth, TableController.scatterHeight)
    @renderer.setClearColorHex(0xEEEEEE, 1.0)
    @renderer.clear()
    
    @camera = new THREE.PerspectiveCamera(45, TableController.scatterWidth / TableController.scatterHeight, 1, 10000)
    @camera.position.z = 20
    
    @scene = new THREE.Scene()
    
    @scatterPlot = new THREE.Object3D()
    
    # Construct the axes
    v = (x, y, z) => return new THREE.Vector3(x, y, z)
    
    # Construct the axes
    distance = 20
    labels = ['-X', 'X', '-Y', 'Y', '-Z', 'Z']
    
    TableController.createAxes3D(@scatterPlot, distance)
    TableController.createAxesLabel3D(@scatterPlot, labels, distance)
    
    # Construct the scatter plot
    mat = new THREE.ParticleBasicMaterial({vertexColors: true, size: 0.10, color: 0xff0000})
    pointCount = dataunit.rows
    pointGeo = new THREE.Geometry()
    
    for rowNumber in [0..pointCount - 1]
      row = dataunit.getRow()
      x = row[0]
      y = row[1]
      z = row[3]
      pointGeo.vertices.push(new THREE.Vector3(x, y, z))
      pointGeo.colors.push(new THREE.Color().setHSV(10, 84, 80))
    
    points = new THREE.ParticleSystem(pointGeo, mat)
    @scatterPlot.add(points)
    @scene.fog = new THREE.FogExp2(0xFFFFFF, 0.0035)
    @scene.add(@scatterPlot)
    
    @renderer.render(@scene, @camera)
    @scatterContainer.appendChild(@renderer.domElement)
    
    # Setup mouse interactions
    @down = false
    [@sx, @sy] = [0, 0]
    @scatterContainer.onmousedown = (e) =>
      @down = true
      @sx = e.clientX
      @sy = e.clientY
    @scatterContainer.onmouseup = (e) =>
      @down = false
    @scatterContainer.onmousemove = (e) =>
      if @down
        dx = e.clientX - @sx
        dy = e.clientY - @sy
        @scatterPlot.rotation.y += dx * 0.01
        @scatterPlot.rotation.x += dy * 0.01
        @scatterPlot.rotation.z += dx * 0.01
        # @camera.position.y += dy
        @sx += dx
        @sy += dy
        @renderer.render(@scene, @camera)
  
  createPlot: =>
    console.log 'createPlot'
    [axis1, axis2] = [@axes.first().val(), @axes.last().val()]
    
    dataunit = @hdu.data
    dataunit.rowsRead = 0

    data = []
    for column, index in dataunit.columns
      data.push([])

    for row in [1..dataunit.rows]
      for value, index in dataunit.getRow()
        data[index].push value

    # Using D3 to create a scatter plot
    @plot.empty()

    width = 600
    height = 300
    margin = {top: 20, right: 15, bottom: 60, left: 60}

    xdata = data[axis1]
    ydata = data[axis2]

    x = d3.scale.linear().domain([d3.min(xdata), d3.max(xdata)]).range([0, width])
    y = d3.scale.linear().domain([d3.min(ydata), d3.max(ydata)]).range([0, height])

    chart = d3.select("#dataunit-#{@index} .plot")
      .append('svg:svg')
      .attr('width', width + margin.right + margin.left)
      .attr('height', height + margin.top + margin.bottom)
      .attr('class', 'chart')

    main = chart.append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
      .attr('width', width)
      .attr('height', height)
      .attr('class', 'main')

    xAxis = d3.svg.axis()
      .scale(x)
      .orient('bottom')

    main.append('g')
      .attr('transform', 'translate(0,' + height + ')')
      .attr('class', 'main axis date')
      .call(xAxis)

    yAxis = d3.svg.axis()
      .scale(y)
      .orient('left')

    main.append('g')
      .attr('transform', 'translate(0,0)')
      .attr('class', 'main axis date')
      .call(yAxis)

    g = main.append("svg:g")

    g.selectAll("scatter-dots")
      .data(ydata)
      .enter().append("svg:circle")
        .attr("cy", (d) ->
          return y(d)
        )
        .attr("cx", (d, i) ->
          return x(xdata[i])
        )
        .attr("r", 1)
        .style("opacity", 0.6)
        .style("stroke", "#CD3E20")


module.exports = TableController