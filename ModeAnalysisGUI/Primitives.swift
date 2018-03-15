import Foundation
import simd

func Palallelogram() -> ([double3],[[Int]]) {
    var vertices:[double3] = []
    var faces:[[Int]] = [[Int]]()
    let row:Int = 20
    let col:Int = 20
    let width:double_t = 1
    let height:double_t = 1
    let dx = width/double_t(row-1)
    let dy = height/double_t(col-1)
    for i in 0..<col {
        for j in 0..<row {
            var p0 = double3(dx*double_t(j),dy*double_t(i),0)-double3(0.5,0.5,0)
            p0.x += p0.y
            vertices.append(p0)
            
            //normal.append(double3(0,0,1))
        }
    }
    
    for i in 0..<col-1 {
        for j in 0..<row-1 {
            faces.append([j+i*row,j+(i+1)*row,j+1+i*row])
            faces.append([j+(i+1)*row,j+1+(i+1)*row,j+1+i*row])
        }
    }
    return (vertices,faces)
}
