#ifndef HALFEDGE_HEGRAPH_H
#define HALFEDGE_HEGRAPH_H

#include <vector>
#include "Eigen/Core"
#include "Elements.h"

typedef Eigen::Vector3d v3;
using namespace std;

class HEGraph {
    public:
    std::vector<HEFace*> faces;
    std::vector<HEVertex*> vertices;

    void setElements(vector<v3> vertices,vector<vector<int> > faces);
    void setVertices(vector<v3> pos);
    void setFaces(vector<vector<int> > polygons);
    HEEdge* findPair(HEEdge* edge);

};


#endif
