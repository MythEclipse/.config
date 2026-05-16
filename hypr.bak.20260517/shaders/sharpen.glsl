precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    float amount = 1.0; // Kekuatan Sharpening (0.0 - 2.0). Ubah jika terlalu tajam.
    vec2 size = textureSize(tex, 0);
    vec4 color = texture2D(tex, v_texcoord);
    
    vec4 n = texture2D(tex, v_texcoord + vec2(0.0, -1.0) / size);
    vec4 s = texture2D(tex, v_texcoord + vec2(0.0, 1.0) / size);
    vec4 e = texture2D(tex, v_texcoord + vec2(1.0, 0.0) / size);
    vec4 w = texture2D(tex, v_texcoord + vec2(-1.0, 0.0) / size);
    
    vec4 val = color + (color - (n + s + e + w) * 0.25) * amount;
    gl_FragColor = val;
}
