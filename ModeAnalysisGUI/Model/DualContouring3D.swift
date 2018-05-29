import Foundation
import simd

class DualContouring3D{
    private var n:Int
    private var dx:Float
    private var distance:(float3)->Float
    private let edges = [
        [[0,0,0],[1,0,0]],[[0,0,0],[0,1,0]],[[0,0,0],[0,0,1]],
        [[1,1,1],[0,1,1]],[[1,1,1],[1,0,1]],[[1,1,1],[1,1,0]],
        [[1,0,1],[1,0,0]],[[1,0,1],[0,0,1]],
        [[0,1,1],[0,0,1]],[[0,1,1],[0,1,0]],
        [[1,1,0],[1,0,0]],[[1,1,0],[0,1,0]]
    ]
    private let directions = [
        (0,0,0),(-1,0,0),(0,-1,0),(0,0,-1),(-1,-1,0),(-1,0,-1),(0,-1,-1)
    ]
    public struct Vertex {
        var pos:float3
        var norm:float3
    }
    private var cells:[[[Vertex]]] = [[[]]]
    private var verticesOnEdges:[[[[(Bool,float3)]]]] = [[[[]]]]

    init(row N:Int, edgeLength:Float,distance:@escaping (float3)->Float)
    {
        self.n = N
        self.distance = distance
        if n<=0 {
            fatalError("N must be >=1")
        }
        dx = edgeLength/Float(N)

    }

    private func cornerPosition(X:Int, Y:Int, Z:Int) -> float3 {
        return dx*float3(Float(X),Float(Y),Float(Z))-dx*Float(n/2)*float3(1,1,1)
    }

    func makePolygonsWithEdges() -> ([Vertex],[[Int]])
    {
        var faces:[[Int]] = [[Int]]()
        var compactVertices:[Vertex] = []
        var verticiesReferense:[[[Int]]] = [[[]]]
        let date = NSDate()

        ////parallel start////
        let operationQueue = OperationQueue()

        //making vertex on edge
        verticesOnEdges = Array(repeating: Array(repeating: Array(repeating: Array(repeating: (false,float3(0)), count: 3), count: n+1), count: n+1), count: n+1)
        operationQueue.isSuspended = true
        for i in 0..<n+1{
            let operation = BlockOperation{
                if i%10==9{
                    print("making vertex on edge \(i+1)/\(self.n+1)")
                }
                for j in 0..<self.n+1{
                    for k in 0..<self.n+1{

                        let D = [(1,0,0),(0,1,0),(0,0,1)]
                        for m in 0..<D.count  {
                            let d = D[m]
                            self.verticesOnEdges[i][j][k][m] = self.checkCrossingWithEdges(X0: k, Y0: j, Z0: i, X1: k+d.0, Y1: j+d.1, Z1: i+d.2)
                        }
                    }
                }
            }
            operationQueue.addOperation(operation)
        }
        operationQueue.isSuspended = false
        operationQueue.waitUntilAllOperationsAreFinished()

        //making dualVertex
        cells = Array(repeating: Array(repeating: Array(repeating: Vertex(pos: float3(0),norm: float3(0)), count: n), count: n), count: n)
        operationQueue.isSuspended = true
        for i in 0..<n{
            let operation = BlockOperation{
                if i%10==9{
                    print("creating dualVertex \(i+1)/\(self.n)")
                }
                for j in 0..<self.n{
                    for k in 0..<self.n{

                        let p = self.makeDualVertexInCell(X: k, Y: j, Z: i)
                        if(p.x==0&&p.y==0&&p.z==0){continue}
                        let v = Vertex(pos: p, norm: normalize(self.grad(pos: p)))

                        self.cells[i][j][k] = v
                    }
                }
            }
            operationQueue.addOperation(operation)
        }
        operationQueue.isSuspended = false
        operationQueue.waitUntilAllOperationsAreFinished()
        ////parallel end////

        //register vertex IDs
        verticiesReferense = Array(repeating: Array(repeating: Array(repeating: -1, count: n), count: n), count: n)
        var arID:Int = 0
        zloop:for i in 0..<n{
            yloop:for j in 0..<n{
                xloop:for k in 0..<n{
                    if length(cells[i][j][k].norm) != 0 {//dual vertexが存在する条件
                        compactVertices.append(cells[i][j][k])
                        verticiesReferense[i][j][k] = arID
                        arID += 1
                    }
                }
            }
        }

        //register triangles
        zloop:for i in 0..<n{
            if i%10==9{
                Swift.print("progress \(i+1)/\(n)")
            }
            yloop:for j in 0..<n{
                xloop:for k in 0..<n{

                    let coords = [[k+1,j,i],[k,j+1,i],[k,j,i+1]]
                    for m in 0...2{
                        let id = coords[m]
                        if id[m] >= n{ continue }//境界対策

                        if getVertexOnEdge(X0: k, Y0: j, Z0: i, X1: id[0], Y1: id[1], Z1: id[2]).0 {
                            var dualVertices:[Int] = []
                            for d in directions{
                                let v = verticiesReferense[i+d.2][j+d.1][k+d.0]
                                dualVertices.append(v)
                            }

                            switch m{
                            case 0:
                                let dv1 = [dualVertices[2],dualVertices[3],dualVertices[0]]
                                let dv2 = [dualVertices[2],dualVertices[3],dualVertices[6]]
                                faces.append(dv1)
                                faces.append(dv2)
                            case 1:
                                let dv1 = [dualVertices[1],dualVertices[3],dualVertices[0]]
                                let dv2 = [dualVertices[1],dualVertices[3],dualVertices[5]]
                                faces.append(dv1)
                                faces.append(dv2)
                            case 2:
                                let dv1 = [dualVertices[1],dualVertices[2],dualVertices[0]]
                                let dv2 = [dualVertices[1],dualVertices[2],dualVertices[4]]
                                faces.append(dv1)
                                faces.append(dv2)
                            default: break
                            }
                        }
                    }
                }
            }
        }
        let t = Float(NSDate().timeIntervalSince(date as Date))
        print("elapsed time \(t)sec")
        cells = [[[]]]
        verticesOnEdges = [[[[]]]]
        print("vertices count",compactVertices.count)
        print("faces count",faces.count)
        return (compactVertices,faces)
    }



    private func checkCrossingWithEdges(X0:Int,Y0:Int,Z0:Int,X1:Int,Y1:Int,Z1:Int) -> (Bool,float3)
    {
        let p0 = cornerPosition(X: X0, Y: Y0, Z: Z0)
        let d0 = distance(p0)

        if X1>=n || Y1>=n || Z1>=n {
            return (false,float3(0,0,0))
        }
        let p1 = cornerPosition(X: X1, Y: Y1, Z: Z1)
        let d1 = distance(p1)
        if d0*d1 >= 0{
            return (false,float3(0,0,0))
        }else{
            let c = abs(d0)+abs(d1)
            let crossPos:float3 = abs(d1)/c*p0+abs(d0)/c*p1
            return (true,crossPos)
        }
    }

    private func getVertexOnEdge(X0:Int,Y0:Int,Z0:Int,X1:Int,Y1:Int,Z1:Int) -> (Bool,float3)
    {
        if X0 != X1 {
            let X = min(X0, X1)
            return verticesOnEdges[Z0][Y0][X ][0]
        }else if Y0 != Y1{
            let Y = min(Y0, Y1)
            return verticesOnEdges[Z0][Y ][X0][1]
        }else{
            let Z = min(Z0, Z1)
            return verticesOnEdges[Z ][Y0][X0][2]
        }
    }

    private func makeDualVertexInCell(X:Int, Y:Int, Z:Int) -> float3
    {
        var centroid = float3(0,0,0)
        var numEdges = 0
        for e in edges
        {
            let cr = getVertexOnEdge(X0: X+e[0][0], Y0: Y+e[0][1], Z0: Z+e[0][2],
                                       X1: X+e[1][0], Y1: Y+e[1][1], Z1: Z+e[1][2])
            if cr.0
            {
                centroid += cr.1
                numEdges += 1
            }
        }
        if numEdges > 0{
            centroid /= Float(numEdges)
        }

        return centroid
    }

    private func grad(pos:float3) -> float3
    {
        let eps:Float = 0.0001
        let fx = (distance(pos+float3(eps,0,0))-distance(pos-float3(eps,0,0)))/(2*eps)
        let fy = (distance(pos+float3(0,eps,0))-distance(pos-float3(0,eps,0)))/(2*eps)
        let fz = (distance(pos+float3(0,0,eps))-distance(pos-float3(0,0,eps)))/(2*eps)
        return float3(fx,fy,fz)
    }
}








