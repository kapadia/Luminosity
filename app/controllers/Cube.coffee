
{Controller} = require('spine')


class Cube extends Controller
  viewportWidth: 600
  viewportHeight: 800
  radius: 14
  
  
  constructor: ->
    super
    
    # Render the template and select item
    @html require('views/cube')()
    @container = @el[0].querySelector(".cube-viewer")
  
  getData: ->
    
    header    = @hdu.header
    dataunit  = @hdu.data
    @width    = dataunit.width
    @height   = dataunit.height
    
    # Create a renderer and grab the GL context
    @renderer = new THREE.WebGLRenderer({antialias: false})
    @gl = @renderer.context
    @renderer.setSize(@viewportWidth, @viewportHeight)
    
    # Set up the camera, scene and plane
    @camera   = new THREE.PerspectiveCamera(45, @viewportWidth / @viewportHeight, 1, 12000)
    @scene    = new THREE.Scene()
    @object3d = new THREE.Object3D()
    @geometry = new THREE.CubeGeometry(@width / 4, @height / 4, 2)
    
    # Experiment with lighting
    areaLight1 = new THREE.AreaLight(0xffffff, 1)
    areaLight1.position.set( 0.0001, 10.0001, -18.5001 )
    areaLight1.rotation.set( -0.74719, 0.0001, 0.0001 )
    areaLight1.width = 10
    areaLight1.height = 1
    @scene.add(areaLight1)
    
    @camera.position.z = 240
    
    # Get each frame in the cube
    frame = 1
    dataunit.getFrames(0, dataunit.depth, (arr, opts) =>
      
      # Get the extent and scale
      # TODO: Scaling should be done on the GPU
      # TODO: Learn how to write custom shaders for Three.js
      extent = dataunit.getExtent(arr)
      pixels = @scale(arr, extent[0], extent[1])
      
      # Create a texture
      texture = @createTexture(pixels)
      
      # Add texture to new mesh and position
      mesh = new THREE.Mesh(
        @geometry, new THREE.MeshBasicMaterial
          map: texture
          opacity: 0.7
          transparent: false
          depthTest: false
      )
      mesh.position.y = -dataunit.depth / 2 + 2 * frame
      mesh.rotation.x = 90 * Math.PI / 180
      mesh.doubleSided = true
      
      # Add mesh to 3D object
      @object3d.add(mesh)
      
      frame += 1
      if frame is dataunit.depth
        console.log 'all frames loaded'
        # Add 3D object to scene after all frames read
        @scene.add(@object3d)
        @container.appendChild(@renderer.domElement)
        @addControls()
        
        @animate()
      
    )
  
  createTexture: (arr) ->
    texture = new THREE.Texture()
    texture.needsUpdate = false
    texture.__webglTexture = @gl.createTexture()
    
    @gl.bindTexture(@gl.TEXTURE_2D, texture.__webglTexture)
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.LUMINANCE, @width, @height, 0, @gl.LUMINANCE, @gl.FLOAT, arr)
    texture.__webglInit = false
    texture.magFilter = THREE.NearestFilter
    texture.minFilter = THREE.NearestFilter
    
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
    
    @gl.bindTexture(@gl.TEXTURE_2D, null)
    
    return texture
  
  animate: =>
    requestAnimationFrame(@animate)
    @controls.update()
    @renderer.render(@scene, @camera)
  
  scale: (arr, min, max) ->
    i = arr.length
    pixels = new Float32Array(i)
    
    # min = @scaledArcsinh(min)
    # max = @scaledArcsinh(max)
    range = max - min
    
    while i--
      value = arr[i]
      if isNaN(value)
        pixels[i] = 0
        continue
      pixels[i] = (value - min) / range
      # pixels[i] = (@scaledArcsinh(value) - min) / range
    return pixels
  
  toUint8: (value) ->
    return @scaledArcsinh(1) if isNaN(value)
    value = @scaledArcsinh(value + @min + 1)
    min = @scaledArcsinh(@min + 1)
    max = @scaledArcsinh(@max + 1)
    return (value - min) / (max - min)
  
  scaledArcsinh: (value) ->
    return @arcsinh(value / -0.033) / @arcsinh(1.0 / -0.033)
    
  arcsinh: (value) ->
    Math.log(value + Math.sqrt(1 + value * value))
  
  addControls: ->
    
    @controls = new THREE.TrackballControls(@camera, @renderer.domElement)
    @controls.rotateSpeed = 1
    @controls.zoomSpeed = 0.5
    @controls.panSpeed = 1
    
    @controls.noZoom = false
    @controls.noPan = false
    
    @controls.staticMoving = false
    @controls.dynamicDampingFactor = 0.3
    
    @controls.minDistance = @radius * 1.1
    @controls.maxDistance = @radius * 250
    
    @controls.keys = [65, 83, 68]
  
module.exports = Cube