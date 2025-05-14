#pragma header

uniform vec3 fromColor;
uniform vec3 toColor;

void main() {
    vec4 pixel = texture2D(bitmap, openfl_TextureCoordv);
    if (distance(pixel.rgb, fromColor) < 0.01) {
        gl_FragColor = vec4(toColor, pixel.a);
    } else {
        gl_FragColor = pixel;
    }
}
