import Foundation
import MetalKit

class Camera
{
    private var m:float4x4 = matrix_identity_float4x4
    
    private var _needsMatrixUpdate:Bool = true
    private var _center:float3 = float3(0)
    private var _up:float3 = float3(0,1,0)
    
    var position:float3
    {
        get {
            let r  = polarPosRTP.x
            let y  = r*cos(polarPosRTP.y)
            let xz = r*sin(polarPosRTP.y)
            let x  = xz*cos(polarPosRTP.z)
            let z  = xz*sin(polarPosRTP.z)
            
            return float3(x,y,z)
        }
    }
    var polarPosRTP:float3
    {
        didSet
        {
            if abs(polarPosRTP.y)>Float.pi
            {
                polarPosRTP.y = polarPosRTP.y+2*Float.pi*(polarPosRTP.y>=0 ? -1:1)
            }
            if abs(polarPosRTP.z)>2*Float.pi
            {
                polarPosRTP.z = polarPosRTP.z+2*Float.pi*(polarPosRTP.z>=0 ? -1:1)
            }
            _needsMatrixUpdate = true
        }
    }
    var center:float3
    {
        set { _center = newValue; _needsMatrixUpdate = true}
        get { return _center }
    }
    var up:float3
    {
        set { _up = normalize(newValue); _needsMatrixUpdate = true}
        get { return _up}
    }
    
    init(polar:float3, center:float3, up:float3) {
        self.polarPosRTP = polar
        self.center = center
        self.up = up
    }
    
    func setUpDir() {
        let dt:Float = 0.001
        let p0 = position
        polarPosRTP.y -= dt
        let p1 = position
        let dir:float3 = normalize(p1-p0)
        up = dir
    }
    
    func GetViewMatrix() -> matrix_float4x4
    {
        if _needsMatrixUpdate
        {
            m = lookAt(eye: position, center: center, up: up)
            _needsMatrixUpdate = false
        }
        
        return m
    }
    
}
