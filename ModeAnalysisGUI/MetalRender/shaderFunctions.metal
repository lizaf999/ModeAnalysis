#include <metal_stdlib>
using namespace metal;

enum Colors {
    ocean  = 0,
    frost  = 1,
    pastel = 2,
    triple = 3,
};

static float4 Blender(float ratio,Colors type){
    ratio = max(min(ratio,1.0),0.0);
    int n = 3;
    float4 a,b;
    float  t=1;
    int gradColor[] = {0,0,0};
    float peak[] = {0,1,0};
    switch (type) {
    case ocean:{
        gradColor[0] = 0x2c3e50;
        gradColor[1] = 0x4ca1af;
        break;
    }
    case frost:{
        gradColor[0] = 0x000428;
        gradColor[1] = 0x004e92;
        break;
    }
    case pastel:{
        gradColor[0] = 0xef32d9;
        gradColor[1] = 0x89fffd;
        break;
    }
    case triple:{
            gradColor[0] = 0x0000FF;
            gradColor[1] = 0x00FF00;
            gradColor[2] = 0xFF0000;
            peak[1] = 0.5;
            peak[2] = 1;
        }
    default: break;
    }

    for(int i=0;i<n-1;i++){
        
        if(ratio>=peak[i] && ratio<=peak[i+1]){
            a = float4((gradColor[i]&0xFF0000) >> 16,(gradColor[i]&0x00FF00) >> 8,gradColor[i]&0x0000FF,255)/255.0;
            b = float4((gradColor[i+1]&0xFF0000) >> 16,(gradColor[i+1]&0x00FF00) >> 8,gradColor[i+1]&0x0000FF,255)/255.0;
            t = (ratio-peak[i])/(peak[i+1]-peak[i]);
            
        }
    }
    
    ratio = t;
    t = ratio<=0.5 ? t:1-t;
    float f = -16*t*t*t+12*t*t;
    return ratio<=0.5 ? a+f*b:f*a+b;
}

