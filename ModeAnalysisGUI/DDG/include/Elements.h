#ifndef HalfEdge_Elements_H
#define HalfEdge_Elements_H

#include <vector>
#include "Eigen/Core"

using namespace Eigen;

class HEEdge;
class HEVertex;
class HEFace;

class HEEdge 
{
    public:
    HEVertex* vertex;
    HEEdge* next;
    HEEdge* pair;
    HEFace* face;

    double cotan();
    double cotanSum();
};

class HEVertex
{
    public:
    HEEdge* edge;
    Vector3d pos;
    std::vector<HEEdge*> flows;
    int ID;

    HEVertex(Vector3d pos,int ID)
    {
        this->pos = pos;
        this->ID = ID;
    }

    double dualArea();
};

class HEFace
{
    public:
    HEEdge* edge;
};

#endif