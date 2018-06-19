import Foundation
import MetalKit

struct VertexUniform {
  var time: Float
  var projectionView: float4x4
  var normal: float4x4
}

enum Material: Int {
  case Diffuse = 0
  case Metal = 1
}

//MARK: -
public class Mesh {
  //bind point at vertex buffer
  enum Buffer: Int {
    case MeshVertex = 0
    case FrameUniform = 1
    func index() -> Int {return self.rawValue}
  }
  
  let vertexBuffer: MTLBuffer
  let indexBuffer: MTLBuffer
  let indexCount:Int
  
  public init(pos: [double3], normal: [double3] = [], indices: [[Int]], color: [double4] = [], values: [double_t] = []) {
    var vertexArray:[VertexStructure] = []
    var indexArray:[uint32] = []
    let bColor:Bool = color.isEmpty
    let bValue:Bool = values.isEmpty
    for i in 0..<pos.count {
      let posf:float3 = float3(Float(pos[i].x),Float(pos[i].z),Float(pos[i].y))//yz入れ替え
      let norf:float3 = float3(Float(normal[i].x),Float(normal[i].z),Float(normal[i].y))//yz入れ替え
      let colf:float4 = bColor ? float4(1) : float4(Float(color[i].x),Float(color[i].y),Float(color[i].z),Float(color[i].w))
      let valf:Float = bValue ? 0 : Float(values[i])
      let vertexAttrib = VertexStructure(pos: posf, normal: norf, color: colf, value: valf)
      vertexArray.append(vertexAttrib)
    }
    
    indices.forEach { (a) in
      a.forEach({ (b) in
        indexArray.append(uint32(b))
      })
    }
    indexCount = indexArray.count
    
    guard let device = Render.current.device else {
      fatalError("Render has not been initialized.")
    }
    guard let vBuff = device.makeBuffer(bytes: vertexArray, length: MemoryLayout<VertexStructure>.stride*vertexArray.count, options: .cpuCacheModeWriteCombined),
      let idBuff = device.makeBuffer(bytes: indexArray, length: MemoryLayout<uint32>.size*indexArray.count, options: .cpuCacheModeWriteCombined)
      else {
        fatalError("Buffer could not been assigned.")
    }
    vertexBuffer = vBuff
    indexBuffer = idBuff
    
    if vertexArray.count-1 != Int(indexArray.max()!) {
      NSLog("vertexcount \(vertexArray.count-1) doesn't match max of indexArray \(String(describing: indexArray.max()))")
    }
  }
  
  
  
  func render(encoder :MTLRenderCommandEncoder) {
    encoder.setVertexBuffer(vertexBuffer, offset: 0, index: Buffer.MeshVertex.index())
    encoder.drawIndexedPrimitives(type: .triangle, indexCount: indexCount, indexType: .uint32, indexBuffer: indexBuffer, indexBufferOffset: 0)
  }
}



