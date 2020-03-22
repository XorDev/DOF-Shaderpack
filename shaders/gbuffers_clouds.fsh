#version 120

uniform sampler2D texture;

uniform float blindness;
uniform int isEyeInWater;

varying vec4 color;
varying vec2 coord0;

void main()
{
    vec3 light = vec3(1.-blindness);
    vec4 col = color * vec4(light,1) * texture2D(texture,coord0);

    float fog = (isEyeInWater>0) ? 1.-exp(-gl_FogFragCoord * gl_Fog.density):
    clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);

    col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);

    gl_FragData[0] = col;
}
