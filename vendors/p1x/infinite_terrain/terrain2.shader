shader_type spatial;

uniform vec3 MAIN_COLOR;
uniform sampler2D noisemap;
uniform sampler2D noisemap_ground;
uniform sampler2D noisemap_nrm;
uniform float RANDOM_UV_FACTOR = 16.;
uniform float GROUND_UV_FACTOR = .2;
uniform float DISTORTION_FACTOR = .3;
uniform float BRIGHTNESS = 0.7;

void vertex() {
    float rand = texture(noisemap, VERTEX.xz).x;
    VERTEX.y += rand * DISTORTION_FACTOR;
}

void fragment() {
    float ran = texture(noisemap, UV * RANDOM_UV_FACTOR).x;
    float ran_ground = texture(noisemap_ground, UV * GROUND_UV_FACTOR).x;
    vec3 alb = vec3(0.1);
    
    alb.r = mix(.2 - ran * .1, .2, ran_ground);
    alb.g = mix(.7 - ran * .4, .1 * ran, ran_ground);
    alb.b = mix(0.05, 0.0, ran_ground);

    alb *= vec3(BRIGHTNESS);
    
    SPECULAR = mix(.6, 0., ran_ground);
    ROUGHNESS =  mix(0.6, 0.9, ran_ground);
    METALLIC =  mix(.5, .7, ran_ground);
    
    NORMALMAP = texture(noisemap_nrm, UV).rgb;
    NORMALMAP_DEPTH = mix(2.5, 0., ran_ground);
    
    ALBEDO = alb;
}
