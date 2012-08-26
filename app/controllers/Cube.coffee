Spine = require('spine')
WebGL = require('lib/WebGL')

class Cube extends Spine.Controller
  @viewportWidth  = 600
  @viewportHeight = 800
  
  constructor: ->
    console.log 'Cube'
    super
    
    # Check for WebGL
    return null unless WebGL.check()
    
    # TEMP variables for scaling data
    @min = -0.78050774
    @max = 4.0023365
    # @min = -0.38050774
    # @max = 3.9023365
    # @min = -12.537979
    # @max = 177.71017
    
    data = @hdu.data
    @width  = data.width
    @height = data.height
    @depth  = data.naxis[2]
    
    # Create a renderer and grab the GL context
    @renderer = new THREE.WebGLRenderer({antialias: false})
    @gl = @renderer.context
    @renderer.setSize(Cube.viewportWidth, Cube.viewportHeight)
    
    # Render the template and select item
    @html require('views/cube')()
    @container = document.querySelector("#dataunit-#{@index} .cube-viewer")
    
    # Set initial variables
    [@mouseX, @mouseY] = [0, 0]
    [@windowHalfX, @windowHalfY] = [Cube.viewportWidth / 2, Cube.viewportHeight / 2]
    
    # Set up the camera, scene and plane
    @camera = new THREE.PerspectiveCamera(75, Cube.viewportWidth / Cube.viewportHeight, 1, 10000)
    @camera.position.z = 240
    @camera.position.y = -120
    @camera.rotation.x = Math.PI / 10
    
    @scene = new THREE.Scene()
    @geometry = new THREE.PlaneGeometry(@width / 4, @height / 4)
    
    for frameIndex in [1..@depth]
      frame = data.getFrame()
      
      for pixel, index in frame
        frame[index] = @toUint8(pixel)
      
      # Create the texture
      texture = @createTexture(@width, @height, frame)
      
      # Add to the mesh
      mesh = new THREE.Mesh(
        @geometry, new THREE.MeshBasicMaterial( { map: texture, opacity: 0.5, transparent: true, depthTest: false, blending: THREE.AdditiveBlending })
      )
      
      mesh.position.y = 300 - 1.25 * frameIndex
      mesh.rotation.x = 90 * Math.PI / 180
      mesh.doubleSided = true
      @scene.add(mesh)
    
    @container.appendChild(@renderer.domElement)
    @container.addEventListener('mousemove', @onMouseMove, false)
    
    @animate()
    
  createTexture: (width, height, data) ->
    texture = new THREE.Texture()
    texture.needsUpdate = false
    texture.__webglTexture = @gl.createTexture()
    
    @gl.bindTexture(@gl.TEXTURE_2D, texture.__webglTexture)
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.LUMINANCE, width, height, 0, @gl.LUMINANCE, @gl.FLOAT, data)
    texture.__webglInit = false
    texture.magFilter = THREE.NearestFilter
    texture.minFilter = THREE.NearestFilter
    
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
    
    @gl.bindTexture(@gl.TEXTURE_2D, null)
    
    return texture
  
  onMouseMove: (e) ->
    @mouseX = e.clientX - @windowHalfX
    @mouseY = e.clientX - @windowHalfY
  
  animate: =>
    requestAnimationFrame(@animate)
    @render()
  
  render: ->
    time = new Date().getTime() * 0.000000000000005
    @camera.position.x += ( @mouseX - @camera.position.x ) * .0000002
    @camera.position.y += ( -@mouseY - @camera.position.y ) * .0000002
    for i in [0..@scene.children.length - 1]
      @scene.children[i].rotation.z += time
      # @scene.children[i].rotation.x += time
    @renderer.render(@scene, @camera)
    
  toUint8: (value) ->
    return @arcsinh(1) if isNaN(value)
    value = @arcsinh(value + @min + 1)
    min = @arcsinh(@min + 1)
    max = @arcsinh(@max + 1)
    return (value - min) / (max - min)
  
  arcsinh: (value) -> Math.log(value + Math.sqrt(1 + value * value))
    
module.exports = Cube