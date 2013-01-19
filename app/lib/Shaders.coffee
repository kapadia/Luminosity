
Shaders =
  vertex: [
    "attribute vec2 a_position;",
    "attribute vec2 a_textureCoord;",
  
    "varying vec2 v_textureCoord;",
  
    "void main() {",
      "vec2 position = a_position + u_offset;",
      "position = position * u_scale;",
      "gl_Position = vec4(position, 0.0, 1.0);",
      
      # Pass coordinate to fragment shader
      "v_textureCoord = a_textureCoord;",
    "}"
  ].join('\n')
  
  fragment: [
    "precision mediump float;",
    
    "uniform sampler2D u_tex;",
    "uniform vec2 u_extent;",
    
    "varying vec2 v_textureCoord;",
    
    "void main() {",
      "vec4 pixel_v = texture2D(u_tex, v_textureCoord);",
        
      "float min = u_extent[0];",
      "float max = u_extent[1];",
      "float pixel = (pixel_v[0] - min) / (max - min);",
        
      "gl_FragColor = vec4(pixel, pixel, pixel, 1.0);",
    "}"
  ].join('\n')
  
module.exports = Shaders