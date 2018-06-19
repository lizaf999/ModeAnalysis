//
//  InputMesh.swift
//  ModeAnalysisGUI
//
//  Created by N.Ishida on 6/19/18.
//

import Foundation
import ModelIO

class InputMesh: Polygon {
  func MeshLoader(filename:String, Extension:String) {
    guard let url = Bundle.main.url(forResource: filename, withExtension: Extension) else {
      fatalError("Failed to find model file.")
    }
    let asset = MDLAsset(url: url)
    guard let mesh:MDLMesh = asset.object(at: 0) as? MDLMesh else {
      fatalError("Failed to get mesh from asset.")
    }
    let desc:MDLVertexDescriptor = mesh.vertexDescriptor
    if mesh.vertexBuffers.count==1 {
      mesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 1)//no smoothing
    }

    guard let attrPos:MDLVertexAttributeData = mesh.vertexAttributeData(forAttributeNamed: MDLVertexAttributePosition),
      let attrNorm:MDLVertexAttributeData = mesh.vertexAttributeData(forAttributeNamed: MDLVertexAttributeNormal) else{
        fatalError("Failed to get vertex attribute iterator.")
    }
    let opaque0 = OpaquePointer(attrPos.dataStart)
    let opaque1 = OpaquePointer(attrNorm.dataStart)
    var p0 = UnsafeMutablePointer<Float>(opaque0)
    var p1 = UnsafeMutablePointer<Float>(opaque1)
    for i in 0..<mesh.vertexCount {
      var pos = double3(0)
      pos.x = double_t(p0.pointee)
      pos.y = double_t((p0+1).pointee)
      pos.z = double_t((p0+2).pointee)
      var norm = double3(0)
      norm.x = double_t(p1.pointee)
      norm.y = double_t((p1+1).pointee)
      norm.z = double_t((p1+2).pointee)
      vertices.append(pos)
      normal.append(norm)
      displacementBases.append(pos)
      p0 += attrPos.stride/MemoryLayout<Float>.size
      p1 += attrNorm.stride/MemoryLayout<Float>.size
    }
    for subMesh:MDLSubmesh in mesh.submeshes as! [MDLSubmesh] {
      if subMesh.geometryType != MDLGeometryType.triangles {
        fatalError("Mesh data should be composed of triangles.")
      }
      let opaque3 = OpaquePointer(subMesh.indexBuffer.map().bytes)
      switch subMesh.indexType {

      case .invalid:
        fatalError("Mesh data type is invalid.")
      case .uInt8:
        var p3 = UnsafeMutablePointer<uint8>(opaque3)
        for _ in 0..<subMesh.indexCount {
          let f1 = Int(p3.pointee)
          let f2 = Int((p3+1).pointee)
          let f3 = Int((p3+2).pointee)
          faces.append([f1,f2,f3])
          p3 += 3
        }
      case .uInt16:
        var p3 = UnsafeMutablePointer<uint16>(opaque3)
        for _ in 0..<subMesh.indexCount {
          let f1 = Int(p3.pointee)
          let f2 = Int((p3+1).pointee)
          let f3 = Int((p3+2).pointee)
          faces.append([f1,f2,f3])
          p3 += 3
        }
      case .uInt32:
        var p3 = UnsafeMutablePointer<uint32>(opaque3)
        for _ in 0..<subMesh.indexCount {
          let f1 = Int(p3.pointee)
          let f2 = Int((p3+1).pointee)
          let f3 = Int((p3+2).pointee)
          faces.append([f1,f2,f3])
          p3 += 3
        }
      }


    }

  }
}
