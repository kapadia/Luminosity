ThreeHelpers = require('lib/ThreeHelpers')

class TableController extends Spine.Controller
  @scatterWidth   = 600
  @scatterHeight  = 600
  
  constructor: ->
    console.log 'Table', ThreeHelpers
    super
    
    @html require('views/table')(@hdu.data)
    
    # Create a sortable table
    $("#dataunit-#{@index} .fits-table").tablesorter()
    
    # Store DOM elements
    @axes = $("#dataunit-#{@index} select.axis")
    @plot = $("#dataunit-#{@index} .plot")
    
    # TEST: WebGL scatter plot
    @createScatter3D()
    
    # Bind events for plots
    @axes.change (e) =>
      @trigger 'axisChange'
    @bind 'axisChange', @createPlot
  
  createScatter3D: =>
    console.log 'createScatter3D'
    
    # Grab the data
    dataunit = @hdu.data
    dataunit.rowsRead = 0
    
    # Setup the parent div
    @scatterContainer = document.querySelector("#dataunit-#{@index} .scatter3d")
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
    v = (x, y, z) => return new THREE.Vertex(new THREE.Vector3(x, y, z))
    
    lineGeo = new THREE.Geometry()
    lineGeo.vertices.push(
      v(-20, 0, 0), v(20, 0, 0),
      v(0, -20, 0), v(0, 20, 0),
      v(0, 0, -20), v(0, 0, 20),

      v(-20, 20, -20), v(20, 20, -20),
      v(-20, -20, -20), v(20, -20, -20),
      v(-20, 20, 20), v(20, 20, 20),
      v(-20, -20, 20), v(20, -20, 20),

      v(-20, 0, 20), v(20, 0, 20),
      v(-20, 0, -20), v(20, 0, -20),
      v(-20, 20, 0), v(20, 20, 0),
      v(-20, -20, 0), v(20, -20, 0),

      v(20, -20, -20), v(20, 20, -20),
      v(-20, -20, -20), v(-20, 20, -20),
      v(20, -20, 20), v(20, 20, 20),
      v(-20, -20, 20), v(-20, 20, 20),

      v(0, -20, 20), v(0, 20, 20),
      v(0, -20, -20), v(0, 20, -20),
      v(20, -20, 0), v(20, 20, 0),
      v(-20, -20, 0), v(-20, 20, 0),

      v(20, 20, -20), v(20, 20, 20),
      v(20, -20, -20), v(20, -20, 20),
      v(-20, 20, -20), v(-20, 20, 20),
      v(-20, -20, -20), v(-20, -20, 20),

      v(-20, 0, -20), v(-20, 0, 20),
      v(20, 0, -20), v(20, 0, 20),
      v(0, 20, -20), v(0, 20, 20),
      v(0, -20, -20), v(0, -20, 20)
    )
    
    lineMat = new THREE.LineBasicMaterial({color: 0x808080, lineWidth: 1})
    line = new THREE.Line(lineGeo, lineMat)
    line.type = THREE.Lines
    @scatterPlot.add(line)
    
    # Create and add labels to the axes
    titleX = ThreeHelpers.createText2D('-X')
    titleX.position.x = -20
    @scatterPlot.add(titleX)
    
    titleX = ThreeHelpers.createText2D('X')
    titleX.position.x = 20
    @scatterPlot.add(titleX)
    
    titleY = ThreeHelpers.createText2D('-Y')
    titleY.position.y = -20
    @scatterPlot.add(titleY)
    
    titleY = ThreeHelpers.createText2D('Y')
    titleY.position.y = 20
    @scatterPlot.add(titleY)
    
    titleZ = ThreeHelpers.createText2D('-Z')
    titleZ.position.z = -20
    @scatterPlot.add(titleZ)
    
    titleZ = ThreeHelpers.createText2D('Z')
    titleZ.position.z = 20
    @scatterPlot.add(titleZ)
    
    # Construct the scatter plot
    mat = new THREE.ParticleBasicMaterial({vertexColors: true, size: 0.10, color: 0xff0000})
    pointCount = dataunit.rows
    pointGeo = new THREE.Geometry()

    for rowNumber in [0..pointCount - 1]
      row = dataunit.getRow()
      x = row[0]
      y = row[1]
      z = row[3]
      pointGeo.vertices.push(new THREE.Vertex(new THREE.Vector3(x, y, z)))
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