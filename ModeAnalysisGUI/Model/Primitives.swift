import Foundation
import simd

class Parallelogram: Polygon {
    override func setMesh() {
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

                normal.append(double3(0,0,1))
                displacementBases.append(p0)
            }
        }

        for i in 0..<col-1 {
            for j in 0..<row-1 {
                faces.append([j+i*row,j+(i+1)*row,j+1+i*row])
                faces.append([j+(i+1)*row,j+1+(i+1)*row,j+1+i*row])
            }
        }
    }
}

class Sphere: Polygon {
    override func setMesh() {
        let row:Int = 30
        let col:Int = 30

        let r:double_t = 1

        vertices.append(double3(0,0,-1))

        for i in 1..<col {
            var th = (1-double_t(i)/double_t(col))*double_t.pi
            th /= 1-1/double_t(col)
            th -= double_t.pi/double_t(col)*0.5


            for j in 0..<row {
                let phi = double_t(j)/double_t(row)*double_t.pi*2
                let x:double_t = r*sin(th)*cos(phi)
                let y:double_t = r*sin(th)*sin(phi)
                let z:double_t = r*cos(th)
                vertices.append(double3(x,y,z))

            }
        }
        vertices.append(double3(0,0,1))

        let offset:Int = vertices.count-row-1
        for i in 0..<row {
            faces.append([0,i+1,(i+1)%row+1])
            faces.append([vertices.count-1,(i+1)%row+offset,i+offset])
        }

        for i in 0..<col-1-1 {//謎の-2
            for j in 0..<row {
                faces.append([j+i*row+1,j+(i+1)*row+1,(j+1)%row+i*row+1])
                faces.append([j+(i+1)*row+1,(j+1)%row+(i+1)*row+1,(j+1)%row+i*row+1])
            }
        }

        for i in 0..<faces.count {
            let face:[Int] = faces[i]
            let u:double3 = vertices[face[1]]-vertices[face[0]]
            let v:double3 = vertices[face[2]]-vertices[face[0]]
            let crs:double3 = cross(u, v)
            let p:double3 = vertices[face[0]]

            if dot(crs, p)<0.0 {
                let v1:Int = faces[i][1]
                let v2:Int = faces[i][2]
                faces[i][1] = v2
                faces[i][2] = v1
            }
        }

        normal = vertices.map{return normalize($0)}
        displacementBases = Array(repeating: double3(0), count: vertices.count)
    }
}

class Torus: Polygon {
    override func setMesh() {
        let row:Int = 30
        let col:Int = 60
        let R:double_t = 1
        let r:double_t = 0.5

        for i in 0..<col {
            let th = double_t(i)/double_t(col)*double_t.pi*2
            let p0 = double3(R*cos(th),R*sin(th),0)
            for j in 0..<row {
                let u = normalize(p0)
                let v = double3(0,0,1)
                let phi = double_t(j)/double_t(row)*double_t.pi*2
                let p1 = r*(u*cos(phi)+v*sin(phi))
                vertices.append(p0+p1)
                normal.append(normalize(p1))
                displacementBases.append(p0)
            }
        }

        for i in 0..<col {
            for j in 0..<row {

                faces.append([j+i*row,j+((i+1)%col)*row,(j+1)%row+i*row])
                faces.append([j+((i+1)%col)*row,(j+1)%row+((i+1)%col)*row,(j+1)%row+i*row])
            }
        }
    }
}

class GeodesicDome: Polygon {
    override func setMesh() {
        let g:double_t = (1+sqrt(5))/2
        var vertex:[(double3,Int)] = []
        var id:Int = 0
        for s1:double_t in [1,-1] {
            for s2:double_t in [1,-1] {
                vertex.append((normalize(double3(s1*1,s2*g,0)),id))
                vertex.append((normalize(double3(0,s1*1,s2*g)),id+1))
                vertex.append((normalize(double3(s2*g,0,s1*1)),id+2))
                id += 3
            }
        }
        var edge:[[Int]] = [[Int]()]

        let itr:Int = 5
        for k in 0..<itr {
            let n = vertex.count
            edge =  Array(repeating: Array(repeating: 0, count: n), count: n)

            var vertex_temp = vertex
            for p in vertex {
                //edge探索
                vertex_temp.sort{
                    return length($0.0-p.0)<length($1.0-p.0)
                }
                for i in 1..<6 {//0番は自分
                    edge[p.1][vertex_temp[i].1] = 1
                    edge[vertex_temp[i].1][p.1] = 1
                }
                let lg5to6:double_t = length(vertex_temp[6].0-p.0)-length(vertex_temp[5].0-p.0)
                let lg6to7:double_t = length(vertex_temp[7].0-p.0)-length(vertex_temp[6].0-p.0)
                if lg5to6 < lg6to7 {
                    edge[p.1][vertex_temp[6].1] = 1
                    edge[vertex_temp[6].1][p.1] = 1
                }
            }

            if k==itr-1 {break}

            //頂点追加
            var id:Int = n
            for i in 0..<n {
                for j in i+1..<n {
                    if edge[i][j]==1 {
                        let p1 = normalize(vertex[i].0+vertex[j].0)
                        vertex.append((p1,id))
                        id += 1
                        edge[i][j] = 0
                        edge[j][i] = 0
                    }
                }
            }

            print("present vertices count \(vertex.count)")
        }



        var face:[[Int]] = [[Int]]()

        for i in 0..<vertex.count {
            for j in i+1..<vertex.count where edge[i][j]==1 {
                for k in 0..<vertex.count {
                    if edge[j][k]==1 && edge[k][i]==1 {
                        let u:double3 = vertex[j].0-vertex[i].0
                        let v:double3 = vertex[k].0-vertex[i].0
                        let s:double_t = dot(cross(u, v), vertex[i].0)
                        if s>0 {
                            face.append([i,j,k])
                        }else{
                            face.append([i,k,j])
                        }

                    }
                    edge[i][j] = 0
                    edge[j][i] = 0
                }
            }
        }

        for (p,_) in vertex {
            vertices.append(p)
            normal.append(normalize(p))
            displacementBases.append(double3(0))
        }
        faces = face

    }
}

class SphereImplicit: Polygon {
    override func setMesh() {
        func distance(pos:float3)->Float {
            let r = length(pos)
            return r-1
        }
        let dual = DualContouring3D(row: 40, edgeLength: 3, distance: distance)
        let (dualVertex,face) = dual.makePolygonsWithEdges()

        faces = face
        dualVertex.forEach { (v) in
            let p = double3(Double(v.pos.x),Double(v.pos.y),Double(v.pos.z))
            let n = double3(Double(v.norm.x),Double(v.norm.y),Double(v.norm.z))
            vertices.append(p)
            normal.append(n)
            displacementBases.append(double3(0))
        }

        for i in 0..<faces.count {
            let face = faces[i]
            let u:double3 = vertices[face[1]]-vertices[face[0]]
            let v:double3 = vertices[face[2]]-vertices[face[0]]
            if dot(cross(u,v), vertices[face[0]])<0 {
                (faces[i][1],faces[i][2]) = (faces[i][2],faces[i][1])
            }
        }

    }
}

//HalfEdgeでは実現不可能
class Mobius: Polygon {
    override func setMesh() {
        let row:Int = 10
        let col:Int = 100//circle

        let radius:double_t = 1
        let width:double_t = 0.2

        for i in 0..<col {
            let th = double_t(i)/double_t(col)*double_t.pi*2
            let p0 = radius*double3(cos(th),sin(th),0)
            let u:double3 = normalize(cos(th/2)*normalize(p0)+sin(th/2)*double3(0,0,1))

            for j in 0..<row {
                let p1:double3 = double_t(j*2-row+1)/double_t(row)*width*u
                let p:double3 = p0+p1
                vertices.append(p)

                let v:double3 = normalize(double3(-p0.y,p0.x,0))
                let n:double3 = normalize(cross(u, v))
                normal.append(n)
                displacementBases.append(p)
            }
        }

        for i in 0..<col-1 {
            for j in 0..<row-1 {
                faces.append([j+i*row,j+(i+1)*row,j+1+i*row])
                faces.append([j+(i+1)*row,j+1+(i+1)*row,j+1+i*row])
            }
        }

        //FIXME: このままではpairが登録されないので境界として認識されてしまう
        for j in 0..<row-1 {
            faces.append([j+(col-1)*row,row-1-j+0,j+1+(col-1)*row])
            faces.append([row-1-j+0,row-1-j-1+0,j+1+(col-1)*row])
        }
    }
}




























