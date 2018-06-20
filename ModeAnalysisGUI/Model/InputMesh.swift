//
//  InputMesh.swift
//  ModeAnalysisGUI
//
//  Created by N.Ishida on 6/19/18.
//

import Foundation
import simd

class InputMesh: Polygon {
  init(filename:String,Extension:String) {
    super.init()
    if Extension=="obj" {
      loadObj(filename: filename, Extension: Extension)
    }else{
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







