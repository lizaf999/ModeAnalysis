
import Foundation
import simd

let kPi_f = Float.pi
let k1Div180_f:Float = 1/180.0
let kRadians:Float = k1Div180_f * kPi_f

func radians(degrees:Float) -> Float {
  return kRadians * degrees
}

func scaleD(x:Float, y:Float, z:Float) -> float4x4{
  let v:float4 = float4([x,y,z,1.0])
  return float4x4(diagonal: v)
}

func multVecVec(v1:float4, v2:float4) -> Float {
  return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z+v1.w*v2.w
}

func multMatVec(mat:float4x4,v:float4) -> float4{
  let mat0 = mat.columns.0
  let mat1 = mat.columns.1
  let mat2 = mat.columns.2
  let mat3 = mat.columns.3
  let m0 = mat0.x*v.x+mat1.x*v.y+mat2.x*v.z+mat3.x*v.w
  let m1 = mat0.y*v.x+mat1.y*v.y+mat2.y*v.z+mat3.y*v.w
  let m2 = mat0.z*v.x+mat1.z*v.y+mat2.z*v.z+mat3.z*v.w
  let m3 = mat0.w*v.x+mat1.w*v.y+mat2.w*v.z+mat3.w*v.w
  return float4([m0,m1,m2,m3])
}

func rotateMat(angleDeg:Float, axis:float3) -> float4x4 {
  let a:Float = angleDeg * k1Div180_f
  var c:Float = 0
  var s:Float = 0
  
  __sincospif(a, &s, &c)
  
  let k:Float = 1-c
  
  let u:float3 = normalize(axis)
  let v:float3 = s * u
  let w:float3 = k * u
  
  let P = float4([w.x * u.x + c,w.x * u.y + v.z,w.x * u.z - v.y,0.0])
  let Q = float4([w.x * u.y - v.z,w.y * u.y + c,w.y * u.z + v.x,0])
  let R = float4([w.x * u.z + v.y,w.y * u.z - v.x,w.z * u.z + c,0.0])
  let S = float4([0,0,0,1])
  
  return float4x4([P,Q,R,S])
}

func translate(x:Float, y:Float, z:Float) -> float4x4 {
  let P = float4([1,0,0,0])
  let Q = float4([0,1,0,0])
  let R = float4([0,0,1,0])
  
  let v = float4([x,y,z,1.0])
  
  return float4x4([P,Q,R,v])
}

func perspective(width:Float, height:Float, near:Float, far:Float) -> float4x4{
  let zNear:Float = 2.0 * near
  let zFar :Float = far / (far - near)
  
  let P = float4([zNear/width,0,0,0])
  let Q = float4([0,zNear/height,0,0])
  let R = float4([0,0,zFar,1])
  let S = float4([0,0,-near * zFar,0])
  
  return float4x4([P,Q,R,S])
}

func perspective_fov(fovyDeg:Float,aspect:Float,near:Float, far:Float) -> float4x4{
  let angle:Float  = radians(degrees: 0.5 * fovyDeg)
  let yScale:Float = 1/tan(angle)
  let xScale:Float = yScale/aspect
  let zScale:Float = far / (far - near)
  
  let P = float4([xScale,0,0,0])
  let Q = float4([0,yScale,0,0])
  let S = float4([0,0,-near*zScale,0])
  let R = float4([0,0,zScale,1])
  
  return float4x4([P,Q,R,S])
}

func lookAt(eye:float3, center:float3, up:float3) -> float4x4{
  let zAxis:float3 = normalize(center-eye)
  let xAxis:float3 = normalize(cross(up, zAxis))
  let yAxis:float3 = cross(zAxis, xAxis)
  
  let P = float4([xAxis.x,yAxis.x,zAxis.x,0])
  let Q = float4([xAxis.y,yAxis.y,zAxis.y,0])
  let R = float4([xAxis.z,yAxis.z,zAxis.z,0])
  let S = float4([-dot(xAxis, eye),-dot(yAxis, eye),-dot(zAxis, eye),1])
  
  return float4x4([P,Q,R,S])
}



func rotate(p:float4,axis:float3,theta:Float)->float4{
  let v = normalize(axis)
  let t = theta
  let u = float3(p.x,p.y,p.z)
  
  let s = sin(t), c = cos(t)
  let a1 = -s*s*cross(cross(v, u), v)
  let a2 = c*c*u
  let a3 = -2*s*c*cross(u, v)
  let a4 = s*s*dot(u, v)*v
  
  let r = a1+a2+a3+a4
  return float4(r.x,r.y,r.z,p.w)
}








