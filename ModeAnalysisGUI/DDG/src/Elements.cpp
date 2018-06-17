#include "../include/Elements.h"
#include "../include/Eigen/Dense"

typedef Eigen::Vector3d vector;

double HEEdge::cotan()
{   
    if (this->next==NULL||this->vertex==NULL) assert(false);
    vector p = this->next->next->vertex->pos;
    vector u = this->next->vertex->pos-p;
    vector v = this->vertex->pos-p;
    double cot = u.dot(v)/u.cross(v).norm();
    return cot;
}

double HEEdge::cotanSum()
{
    if (this->pair!=NULL) {
        return 0.5*(this->cotan()+this->pair->cotan());
    }else{
        assert(false);
    }
}

double HEVertex::dualArea()
{
    double sum=0;

    for(auto edge: this->flows){
        vector p = edge->vertex->pos;
        vector u = edge->next->vertex->pos-p;
        vector v = edge->next->next->vertex->pos-p;
        sum += 0.5*(u.cross(v)).norm();
    }
    sum /= 3.0;

    return sum;
}
