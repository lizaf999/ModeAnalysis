import Foundation
import MetalKit

class UniformState
{
  //time:Float,rightDirection:float3,VP:float4x4
  public struct Uniform3D
  {
    var time:Float
    var eyePos:float4
    var rightDiretion:float4
    var rightPos:float4
    var  M:matrix_float4x4
    var VP:matrix_float4x4
  }
  
  private var _uniformBuffer:MTLBuffer
  
  //algebra property
  var rightDirection:float3?
  {
    didSet{
      rightDirection = normalize(rightDirection!)
    }
  }
  var rightPos:float4?
  var eyePos:float4?
  
  var perspectiveMat:matrix_float4x4?
  
  
  //time property
  private static var _startDate = NSDate()
  private static var _nowDate = NSDate()
  static var elapsedTime:Float
  {
    get{
      return Float(NSDate().timeIntervalSince(_startDate as Date))
    }
  }
  static var deltaTime:Float
  {
    get{
      let t = Float(NSDate().timeIntervalSince(_nowDate as Date))
      _nowDate = NSDate()
      return t
    }
  }
  static var isSuspended:Bool = false
  static private var _controlableTime:Float = 0
  static var controlableTime:Float
  {
    get{
      if !isSuspended{
        _controlableTime += deltaTime
      }
      return _controlableTime
    }
  }
  
  init(device:MTLDevice,eyePos:float4, rightDirection:float3, rightPosition:float3)
  {
    self.rightDirection = rightDirection
    let p = rightPosition
    self.rightPos = float4(p.x,p.y,p.z,0)
    self.eyePos = eyePos
    
    let uniform0 = Uniform3D(time: 0, eyePos: float4(0), rightDiretion: float4(0), rightPos: float4(0), M: matrix_float4x4(0), VP: matrix_float4x4(0))
    _uniformBuffer = device.makeBuffer(length: MemoryLayout.size(ofValue: uniform0), options: .storageModeManaged)!
  }
  
  func GetUniformBuffer(ModelMat:inout matrix_float4x4, ViewMat:inout matrix_float4x4) -> MTLBuffer
  {
    if perspectiveMat == nil || rightDirection == nil || rightPos == nil || eyePos == nil{
      fatalError("One or more properties were not set.")
    }
    
    let MVP = perspectiveMat! * ViewMat
    let rd = rightDirection!
    var uniform = Uniform3D(time: UniformState.elapsedTime, eyePos: eyePos!, rightDiretion: float4(rd.z,rd.y,rd.z,1), rightPos: rightPos!, M: ModelMat, VP: MVP)
    
    let bufferPointer = _uniformBuffer.contents()
    memcpy(bufferPointer, &uniform, MemoryLayout.size(ofValue: uniform))
    
    return _uniformBuffer//値渡しかも？
  }
  
  
}
