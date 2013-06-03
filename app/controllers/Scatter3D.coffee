Graph = require('controllers/Graph')
ThreeHelpers = require('lib/ThreeHelpers')

class Scatter3D extends Graph
  name: 'Scatter 3D'
  axes: 3
  
  events:
    "change select[data-axis='1']" : 'draw'
    "change select[data-axis='2']" : 'draw'
    "change select[data-axis='3']" : 'draw'
  
  
  constructor: ->
    super
    
    @axis1 = @el.find("select[data-axis='1']")
    @axis2 = @el.find("select[data-axis='2']")
    @axis3 = @el.find("select[data-axis='3']")

  draw: =>
    index1 = @axis1.val()
    index2 = @axis2.val()
    index3 = @axis3.val()
    
    return unless index1 + index2 + index3 > -1
    
    @setup()
    @setupMouseInteractions()
    
    dataunit = @hdu.data
    rows = dataunit.rows
    
    # Set up deferreds
    dfd1 = new jQuery.Deferred()
    dfd2 = new jQuery.Deferred()
    dfd3 = new jQuery.Deferred()
    $.when(dfd1, dfd2, dfd3).then(@_draw, @no)
    
    # Get labels for the axes
    @key1 = xlabel = @axis1.find("option:selected").text()
    @key2 = ylabel = @axis2.find("option:selected").text()
    @key3 = zlabel = @axis3.find("option:selected").text()
    
    # Get data from file
    dataunit.getColumn(@key1, 0, rows - 1, (column) =>
      obj = new Object()
      obj[@key1] = column
      dfd1.resolve(obj)
    )
    
    dataunit.getColumn(@key2, 0, rows - 1, (column) =>
      obj = new Object()
      obj[@key2] = column
      dfd2.resolve(obj)
    )
    
    dataunit.getColumn(@key3, 0, rows - 1, (column) =>
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
    
    # Construct the scatter plot
    mat = new THREE.ParticleBasicMaterial({vertexColors: true, size: 1.0, color: 0xff0000})
    pointGeo = new THREE.Geometry()
    
    rows = @hdu.data.rows
    while rows--
      x = column1[@key1][rows]
      y = column1[@key2][rows]
      z = column1[@key3][rows]
      pointGeo.vertices.push( new THREE.Vector3(x, y, z) )
      pointGeo.colors.push( new THREE.Color().setRGB(0, 113, 229) )
    
    points = new THREE.ParticleSystem(pointGeo, mat)
    @scatter.add(points)
    @scene.add(@scatter)
    
    @renderer.render(@scene, @camera)
    @controls.update()
  
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
    @renderer.setClearColorHex(0xEEEEEE, 1.0)
    @renderer.clear()
    
    @camera = new THREE.PerspectiveCamera(45, width / height, 1, 10000)
    @controls = new THREE.TrackballControls(@camera, @renderer.domElement)
    
    @scene = new THREE.Scene()
    @scene.fog = new THREE.FogExp2(0xFFFFFF, 0.0035)
    
    @scatter = new THREE.Object3D()
    
    # Construct the axes
    v = (x, y, z) => return new THREE.Vector3(x, y, z)
    distance = 1
    labels = ['-X', 'X', '-Y', 'Y', '-Z', 'Z']
    
    Scatter3D.createAxes3D(@scatter, distance)
    
    @container.appendChild(@renderer.domElement)
    
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

module.exports = Scatter3D