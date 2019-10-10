// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Created by S.Guillitte 
// Modified for GodotEngine by w84death

shader_type spatial;
render_mode cull_disabled;
                                 
uniform mat2 m2 = mat2(vec2(0.8, 0.6), vec2(-0.6,  0.8));
uniform mat2 im2 = mat2(vec2(0.8,  -0.6), vec2( 0.6,  0.8));


float noise(in vec2 p){
    float res=0.;
    float f=1.;
    for( int i=0; i< 3; i++ ){
        p=m2*p*f+.6;     
        f*=1.2;
        res+=sin(p.x+sin(2.*p.y));
    }  
    return res/3.;
}

float fb_clouds( vec2 p ){
    float f=1.;   
    float r = 0.0;
    for(int i = 0;i<8;i++){
        r += abs(noise( p*f )+.5)/f;       
        f *=2.;
        p=im2*p;
    }
    return 1.-r*.5;
}

vec3 sky(in vec2 p, in float t){
    return sin(vec3(1.7,1.5,1)+ .7+ .9*fb_clouds(p*4.-.02*t))+.25;
}

void fragment() {
    ALBEDO = sky(UV*.1, TIME);
}