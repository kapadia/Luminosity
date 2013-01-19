Spine   = require('spine')
WebGL   = require('lib/WebGL')
Shaders = require('lib/Shaders')

class Cube extends Spine.Controller
  viewportWidth: 600
  viewportHeight: 800
  radius: 14
  
  constructor: ->
    super
    
    # TODO: Check for WebGL
    
    # Render the template and select item
    @html require('views/cube')()
    @container = @el[0].querySelector(".cube-viewer")
    
    dataunit  = @hdu.data
    @width    = dataunit.width
    @height   = dataunit.height
    nFrames   = i = dataunit.naxis[2]
    nPixels   = @width * @height
    @minimums = []
    @maximums = []
    
    # Create a renderer and grab the GL context
    @renderer = new THREE.WebGLRenderer({antialias: false})
    @gl = @renderer.context
    @renderer.setSize(@viewportWidth, @viewportHeight)
    
    # Set up the camera, scene and plane
    @camera   = new THREE.PerspectiveCamera(45, @viewportWidth / @viewportHeight, 1, 10000)
    @scene    = new THREE.Scene()
    @object3d = new THREE.Object3D()
    @geometry = new THREE.PlaneGeometry(@width / 4, @height / 4)
    
    @camera.position.z = 240
    
    # Get the extent of the data
    extents = []
    frames = []
    while i--
      frame = new Float32Array(dataunit.getFrame())
      [min, max] = @getExtent(frame)
      extents.push min
      extents.push max
      frames.push frame
    [@gMin, @gMax] = @getExtent(extents)
    
    # Set uniforms and attributes for custom shaders
    attributes  = {}
    uniforms    =
      u_extent:
        type: 'v2'
        value: new THREE.Vector2(@gMin, @gMax)
    
    for frame, index in frames
      # Scale the pixels
      pixels = @scale(frame, @gMin, @gMax)
      
      # Create a texture
      texture = @createTexture(pixels)
      
      # Add texture to new mesh
      mesh = new THREE.Mesh(
        @geometry, new THREE.MeshBasicMaterial
          # uniforms: uniforms
          # attributes: attributes
          # vertexShader: Shaders.vertex
          # fragmentShader: Shaders.fragment
          map: texture
          opacity: 0.5
          transparent: false
          depthTest: false
      )
      mesh.position.y = -nFrames / 2 + index
      mesh.rotation.x = 90 * Math.PI / 180
      mesh.doubleSided = true
      
      # Add to object
      @object3d.add(mesh)
    
    @scene.add(@object3d)
    @container.appendChild(@renderer.domElement)
    @addControls()
    
    @animate()
    
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
  
  scale: (arr, min, max) =>
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
  
  getExtent: (arr) ->
    i = arr.length
    
    # Set initial value
    while i--
      continue if isNaN(arr[i])
      min = max = arr[i]
      break
    
    # Continue from where the loop left off
    while i--
      if arr[i] < min
        min = arr[i]
      if arr[i] > max
        max = arr[i]
    return [min, max]
  
  scaledArcsinh: (value) =>
    return @arcsinh(value / -0.033) / @arcsinh(1.0 / -0.033)
    
  arcsinh: (value) =>
    Math.log(value + Math.sqrt(1 + value * value))
  
  addControls: =>
    @controls = new THREE.TrackballControls(@camera, @renderer.domElement)
    @controls.rotateSpeed = 1
    @controls.zoomSpeed = 0.5
    @controls.panSpeed = 1
    
    @controls.noZoom = false
    @controls.noPan = false
    
    @controls.staticMoving = false
    @controls.dynamicDampingFactor = 0.3
    
    @controls.minDistance = @radius * 1.1
    @controls.maxDistance = @radius * 25
    
    @controls.keys = [65, 83, 68]
  
module.exports = Cube