import Foundation
import simd

class Polygon: NSObject {
    var vertices:[double3] = []
    var faces:[[Int]] = []
    var normal:[double3] = []
    var displacementBases:[double3] = []
    
    
    private let modeAnalysis:ObjCppModeAnalysis
    
    override init() {
        modeAnalysis = ObjCppModeAnalysis()
        super.init()
    }
    
    func setMesh() {
       //set vertices,faces,normal,displacementBases here.
    }
    
    final func solveEigen() {
        if(vertices.isEmpty||faces.isEmpty||normal.isEmpty||displacementBases.isEmpty){
            fatalError("more than one array is empty.")
        }
        
        var v:[[double_t]] = [[double_t]]()
        vertices.forEach { (p) in
            v.append([p[0],p[1],p[2]])
        }
        modeAnalysis.setVerticesAndFaces(v, faces: faces)
        
        let date = Date()
        modeAnalysis.solveEigenValueProblem()
        let t = Date().timeIntervalSince(date)
        print("elapsed time \(Double(t))")
    }
    
    final func getDisplacedVertices(ID:Int) ->[double3] {
        var v_ar:[double3] = []
        let vec:[double_t] = modeAnalysis.getEigenVector(Int32(ID)) as! [double_t]
        vec.enumerated().forEach {
            let v = displacementBases[$0.offset]+normal[$0.offset]*abs($0.element)*0.3
            v_ar.append(v)
        }
        return v_ar
    }
    
    final func getEigenValues()->[Double]{
        let vals:[Double] = modeAnalysis.getEigenValue() as! [Double]
        return vals
    }
    
    final func getEigenVector(ID:Int) -> [double_t] {
        return modeAnalysis.getEigenVector(Int32(ID)) as! [double_t]
    }
    
    final func getDisplacedNormal(pos:[double3]) -> [double3] {
        let pos_objc:[[double_t]] = pos.map { (p) -> [double_t] in
            return [p.x,p.y,p.z]
        }
        
        var normals:[double3] = []
        let ar:[[double_t]] = modeAnalysis.getNormals(pos_objc) as! [[double_t]]
        for normal in ar {
            normals.append(double3(normal[0],normal[1],normal[2]))
        }
        return normals
    }
}























