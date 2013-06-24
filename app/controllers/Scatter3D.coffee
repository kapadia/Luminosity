Graph = require('controllers/Graph')
ThreeHelpers = require('lib/ThreeHelpers')

class Scatter3D extends Graph
  name: 'Scatter 3D'
  axes: 3
  isSetup: false
  
  events:
    "change select[data-axis='1']" : 'draw'
    "change select[data-axis='2']" : 'draw'
    "change select[data-axis='3']" : 'draw'
  
  
  constructor: ->
    super
    
    @axis1 = @el.find("select[data-axis='1']")
    @axis2 = @el.find("select[data-axis='2']")
    @axis3 = @el.find("select[data-axis='3']")
    
  setup: ->
    
    width = @el.width() - parseInt(@el.css('padding-left')) - parseInt(@el.css('padding-right'))
    height = @el.height() - parseInt(@el.css('padding-top')) - parseInt(@el.css('padding-bottom'))
    
    # Setup the parent div
    @container = @el[0].querySelector('.graph')
    @container.width = width
    @container.height = height
    
    # Setup THREE 
    @renderer = new THREE.WebGLRenderer({antialias: true})
    @renderer.setSize(width, height)
    @renderer.setClearColor(0xEEEEEE, 1.0)
    
    # Setup camera
    @camera = new THREE.PerspectiveCamera(45, width / height, 1, 10000)
    @camera.position.z = 200
    @camera.position.x = 0
    @camera.position.y = 10
    
    # Setup controls
    @setupMouseInteractions()
    # @controls = new THREE.TrackballControls(@camera, @renderer.domElement)
    
    # Setup scene
    @scene = new THREE.Scene()
    # @scene.fog = new THREE.FogExp2(0xFFFFFF, 0.0035)
    
    # Look
    @camera.lookAt(@scene.position)
    
    @scatter = new THREE.Object3D()
    
    distance = 50
    labels = ['-X', 'X', '-Y', 'Y', '-Z', 'Z']
    
    @createAxes3D(distance)
    
    @container.appendChild(@renderer.domElement)
    @isSetup = true
    
  draw: =>
    
    index1 = @axis1.val()
    index2 = @axis2.val()
    index3 = @axis3.val()
    
    return unless index1 + index2 + index3 > -1
    
    # Setup is needed here because the height of the div is 0 until
    # FIXME: Work better with DOM
    @setup() unless @isSetup
    
    dataunit = @hdu.data
    rows = dataunit.rows
    
    # Set up deferreds
    dfd1 = new jQuery.Deferred()
    dfd2 = new jQuery.Deferred()
    dfd3 = new jQuery.Deferred()
    $.when(dfd1, dfd2, dfd3).then(@_draw, -> alert 'Sorry, something went wrong')
    
    # Get labels for the axes
    @key1 = xlabel = @axis1.find("option:selected").text()
    @key2 = ylabel = @axis2.find("option:selected").text()
    @key3 = zlabel = @axis3.find("option:selected").text()
    
    # Get data from file
    dataunit.getColumn(@key1, (column) =>
      obj = new Object()
      obj[@key1] = column
      dfd1.resolve(obj)
    )
    
    dataunit.getColumn(@key2, (column) =>
      obj = new Object()
      obj[@key2] = column
      dfd2.resolve(obj)
    )
    
    dataunit.getColumn(@key3, (column) =>
      obj = new Object()
      obj[@key3] = column
      dfd3.resolve(obj)
    )
  
  _draw: (column1, column2, column3) =>
    
    # Merge objects
    for k, v of column2
      column1[k] = v
    for k, v of column3
      column1[k] = v
    
    # Get extent for each column
    extentX = @getExtent(column1[@key1])
    extentY = @getExtent(column1[@key2])
    extentZ = @getExtent(column1[@key3])
    
    minX = extentX[0]
    minY = extentY[0]
    minZ = extentZ[0]
    
    rangeX = extentX[1] - minX
    rangeY = extentY[1] - minY
    rangeZ = extentZ[1] - minZ
    
    columnX = column1[@key1]
    columnY = column1[@key2]
    columnZ = column1[@key3]
    
    # Create geometry to store points
    pointGeo = new THREE.Geometry()
    
    # Loop over values sending each to the GPU
    rows = @hdu.data.rows
    while rows--
      
      # Get point
      x = columnX[rows]
      y = columnY[rows]
      z = columnZ[rows]
      
      # Normalize
      xn = 50 * (x - minX) / rangeX
      yn = 50 * (y - minY) / rangeY
      zn = 50 * (z - minZ) / rangeZ
      
      # Create vector representing point
      point = new THREE.Vector3(xn, yn, zn)
      pointGeo.vertices.push(point)
    
    
    points = new THREE.ParticleSystem(pointGeo, new THREE.ParticleBasicMaterial({size: 1.5, color: 0x0071e5}))
    @scatter.add(points)
    @scene.add(@scatter)
    
    @renderer.render(@scene, @camera)
    @controls.update()
  
  setupMouseInteractions: ->
    @down = false
    [@sx, @sy] = [0, 0]
    @container.onmousedown = (e) =>
      @down = true
      @sx = e.clientX
      @sy = e.clientY
    @container.onmouseup = (e) =>
      @down = false
    @container.onmousemove = (e) =>
      if @down
        dx = e.clientX - @sx
        dy = e.clientY - @sy
        @scatter.rotation.y += dx * 0.01
        @scatter.rotation.x += dy * 0.01
        @scatter.rotation.z += dx * 0.01
        # @camera.position.y += dy
        @sx += dx
        @sy += dy
        @renderer.render(@scene, @camera)

  createAxes3D: (size) ->
    v = (x, y, z) ->
      return new THREE.Vector3(x, y, z)

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
    @scatter.add(line)

  createAxesLabel3D: (plot, labels, distance) ->
    axes = ['x', 'x', 'y', 'y', 'z', 'z']
    for label, index in labels
      axis = axes[index]

      title = ThreeHelpers.createText2D(label)
      title.position[axis] = Math.pow(-1, index + 1) * distance
      plot.add(title)

  getExtent: (arr) ->
    min = max = arr[0]
    
    for value, index in arr
      if value < min
        min = value
      if value > max
        max = value
    return [min, max]

module.exports = Scatter3D