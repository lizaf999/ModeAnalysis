import Foundation
import simd

class Polygon: NSObject {
    private(set) var vertices:[double3] = []
    private(set) var faces:[[Int]] = []
    
    private let modeAnalysis:ObjCppModeAnalysis
    
    override init() {
        modeAnalysis = ObjCppModeAnalysis()
        super.init()
    }
    
    func setMesh(vertices:[double3],faces:[[Int]]) {
        self.vertices = vertices
        self.faces = faces
        var v:[[double_t]] = [[double_t]]()
        vertices.forEach { (p) in
            v.append([p[0],p[1],p[2]])
        }
        modeAnalysis.setVerticesAndFaces(v, faces: faces)
    }
    
    func setTestMesh() {
        modeAnalysis.setPallalelogram()
    }
    
    func solveEigen() {
        
        modeAnalysis.solveEigenValueProblem()
    }
    
    func printDisplacedVertices(ID:Int) {
        let vec:[double_t] = modeAnalysis.getEigenVector(Int32(ID)) as! [double_t]
        vec.enumerated().forEach {
            let v = vertices[$0.offset]+double3(0,0,1)*$0.element*0.3
            print(v.x,v.y,v.z)
        }
    }
}


