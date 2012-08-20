ThreeHelpers =
  createTextCanvas: (text, color, font, size) ->
    size = size or 24
    canvas = document.createElement('canvas')
    context = canvas.getContext('2d')
    fontStr = (size + 'px ') + (font or 'Arial')
    context.font = fontStr
    w = context.measureText(text).width
    h = Math.ceil(size)
    canvas.width = w
    canvas.height = h
    context.font = fontStr
    context.fillStyle = color or 'black'
    context.fillText(text, 0, Math.ceil(size * 0.8))
    return canvas
  
  createText2D: (text, color, font, size, segW, segH) ->
    canvas = @createTextCanvas(text, color, font, size)
    plane = new THREE.PlaneGeometry(canvas.width, canvas.height, segW, segH)
    tex = new THREE.Texture(canvas)
    tex.needsUpdate = true
    planeMat = new THREE.MeshBasicMaterial({
      map: tex, color: 0xffffff, transparent: true
    })
    mesh = new THREE.Mesh(plane, planeMat)
    mesh.scale.set(0.25, 0.25, 0.25)
    mesh.doubleSided = true
    return mesh

module?.exports = ThreeHelpers