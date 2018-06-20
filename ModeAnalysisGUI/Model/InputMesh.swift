//
//  InputMesh.swift
//  ModeAnalysisGUI
//
//  Created by N.Ishida on 6/19/18.
//

import Foundation
import ModelIO
import MetalKit

class InputMesh: Polygon {
  init(filename:String,Extension:String) {
    super.init()
    if Extension=="obj" {
      loadObj(filename: filename, Extension: Extension)
    }else{
      MeshLoader(filename: filename, Extension: Extension)
    }
  }

  func MeshLoader(filename:String, Extension:String) {
    guard let url = Bundle.main.url(forResource: filename, withExtension: Extension) else {
      fatalError("Failed to find model file.")
    }
    let mtlVertex = MTLVertexDescriptor()
    mtlVertex.attributes[0].format = .float3
    mtlVertex.attributes[0].offset = 0
    mtlVertex.attributes[0].bufferIndex = 0
    mtlVertex.attributes[1].format = .float3
    mtlVertex.attributes[1].offset = 12
    mtlVertex.attributes[1].bufferIndex = 0
    mtlVertex.layouts[0].stride = 24
    mtlVertex.layouts[0].stepRate = 1

    let modelDescriptor = MTKModelIOVertexDescriptorFromMetal(mtlVertex)
    (modelDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
    (modelDescriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
    let asset = MDLAsset(url: url, vertexDescriptor: modelDescriptor, bufferAllocator: nil)
    guard let mesh:MDLMesh = asset.object(at: 0) as? MDLMesh else {
      fatalError("Failed to get mesh from asset.")
    }
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


    for _ in 0..<mesh.vertexCount {
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
      var maxID:Int = 0
      switch subMesh.indexType {
      case .invalid:
        fatalError("Mesh data type is invalid.")
      case .uInt8:
        var p3 = UnsafeMutablePointer<uint8>(opaque3)
        for _ in 0..<subMesh.indexBuffer.length/3 {
          let f1 = Int(p3.pointee)
          let f2 = Int((p3+1).pointee)
          let f3 = Int((p3+2).pointee)
          faces.append([f1,f2,f3])
          p3 += 3
        }
      case .uInt16:
        var p3 = UnsafeMutablePointer<uint16>(opaque3)
        for _ in 0..<subMesh.indexBuffer.length/2/3 {
          let f1 = Int(p3.pointee)
          let f2 = Int((p3+1).pointee)
          let f3 = Int((p3+2).pointee)
          faces.append([f1,f2,f3])
          p3 += 3
        }
      case .uInt32:
        var p3 = UnsafeMutablePointer<uint32>(opaque3)
        for i in 0...subMesh.indexCount/3 {
          let f1 = Int(p3.pointee)
          let f2 = Int((p3+1).pointee)
          let f3 = Int((p3+2).pointee)
          //faces.append([f1,f2,f3])
          faces.append([3*i,3*i+1,3*i+2])
          p3 += 3
          if max(f1,f2,f3)>maxID {maxID=max(f1,f2,f3)}
//          print((p3+0).pointee)
//          print((p3+1).pointee)
//          print((p3+2).pointee)
        }


      }
      print(mesh.vertexCount,subMesh.indexCount, vertices.count,faces.count)
      print(maxID)
    }

  }

  func loadObj(filename:String,Extension:String){
    if Extension != "obj" {
      fatalError("This method is only for .obj files.")
    }
    guard let url = Bundle.main.url(forResource: filename, withExtension: "obj") else {
      fatalError("Failed to find model file.")
    }
    let text:String = try! String(contentsOf: url)
    text.enumerateLines { (line, stop) in
      let elem:[String] = line.components(separatedBy: " ")
      if !elem.isEmpty{
        if elem[0]=="v" {
          var pos = double3(0)
          pos.x = double_t(elem[1])!
          pos.y = double_t(elem[2])!
          pos.z = double_t(elem[3])!
          self.vertices.append(pos)
          self.displacementBases.append(pos)
          self.normal.append(double3(0))
        }
        if elem[0]=="f" {
          let f1 = Int(elem[1])!-1
          let f2 = Int(elem[2])!-1
          let f3 = Int(elem[3])!-1
          self.faces.append([f1,f2,f3])
        }
      }
    }
    //normal = getDisplacedNormal(pos: vertices)
  }
}







