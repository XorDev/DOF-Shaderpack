#version 120

#define Quality 6. //Bokeh quality (reduces noise) [2. 4. 6. 8. 16.]
#define Size 32.   //Bokeh size [8. 16. 32. 64. 128.]
#define Range 1.   //Focus range [.1 .5 1. 2. 5.]
#define Bias 3.    //Bias towards brightness [0. 1. 3. 5. 8.]

//Focusing speed:
const float centerDepthHalflife = 1.0f;

uniform sampler2D texture;
uniform sampler2D depthtex0;

uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float centerDepthSmooth;

varying vec4 color;
varying vec2 coord0;

const int steps = 4;

float depth(float d)
{
    return 1./(1.+near/(near+far-d*(far-near))/Range);
}
vec2 hash(vec2 p)
{
	return normalize(fract(cos(p*mat2(-69.38,-89.27,94.55,78.69))*825.79)-.5);
}
vec4 pack_color(vec4 col)
{
    float gray = dot(col,vec4(.299,.587,.114,0));
    return col*pow(gray,Bias);
}
vec4 unpack_color(vec4 col)
{
    float gray = pow(dot(col,vec4(.299,.587,.114,0)),Bias/(1.+Bias));
    return col/gray;
}
void main()
{
    float radius = abs(depth(texture2D(depthtex0,coord0).r)-depth(centerDepthSmooth));
    float weight = 0.;
    vec4 col = vec4(0);

    vec2 size = 1./vec2(viewWidth,viewHeight);

    float d = 1.;
    vec2 samp = hash(coord0)*radius/Quality*Size;
	mat2 ang = mat2(-.73736882209777832,.67549037933349609,-.67549037933349609,-.73736882209777832);

	for(int i = 0;i<int(Quality*Quality);i++)
	{
        d += 1./d;
        samp *= ang;

        vec2 uv = coord0 + samp*(d-1.)*size;
        vec4 tex = texture2D(texture,uv);

        weight++;
        col += pack_color(tex);
	}

    gl_FragData[0] = color * unpack_color(col / weight) * vec4(1,1,1,radius);
}
