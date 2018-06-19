import Foundation
import MetalKit

class RenderableObject
{
  let mesh        : MTLBuffer?
  let indexBuffer : MTLBuffer?
  let texture     : MTLTexture?
  
  
  var count : Int
  
  private var _m:matrix_float4x4 = matrix_identity_float4x4
  private var _needsMatrixUpdate:Bool = true
  var scale   :float3{
    didSet{
      _needsMatrixUpdate = true
    }
  }
  var position:float3{
    didSet{
      _needsMatrixUpdate = true
    }
  }
  var rotation:float3{
    didSet{
      _needsMatrixUpdate = true
    }
  }
  
  
  init(mesh:MTLBuffer, idx:MTLBuffer?, count:Int, tex:MTLTexture?)
  {
    self.mesh        = mesh
    self.indexBuffer = idx
    self.texture     = tex
    self.count       = count
    
    self.scale    = float3(1)
    self.position = float3(0)
    self.rotation = float3(0)
    
  }
  
  //LocalToWorld
  func ModelMatrix() -> matrix_float4x4
  {
    if (_needsMatrixUpdate)
    {
      let scaleMat = scaleD(x: scale.x, y: scale.y, z: scale.z)
      let xrot = rotateMat(angleDeg: rotation.x, axis: float3(1,0,0))
      let yrot = rotateMat(angleDeg: rotation.y, axis: float3(0,1,0))
      let zrot = rotateMat(angleDeg: rotation.z, axis: float3(0,0,1))
      let tf   = translate(x: position.x, y: position.y, z: position.z)
      _m = tf * zrot*yrot*xrot * scaleMat
      
      _needsMatrixUpdate = false
    }
    return _m
  }
  
  func Draw(encoder:MTLRenderCommandEncoder)
  {
    if indexBuffer != nil
    {
      encoder.drawIndexedPrimitives(type: .triangle, indexCount: count, indexType: .uint32, indexBuffer: indexBuffer!, indexBufferOffset: 0)
    }
    else
    {
      encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
    }
  }
}













