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
    // HEEdge* now = this->edge;

    // do{
    //     vector p = now->next->next->vertex->pos;
    //     vector u = now->next->vertex->pos - p;
    //     vector v = now->vertex->pos - p;
    //     vector w = now->vertex->pos - now->next->vertex->pos;

    //     double cot1 = u.dot(v)/u.cross(v).norm();
    //     double cot2 = (-u).dot(w)/(-u).cross(w).norm();

    //     double a = w.norm();
    //     double b = v.norm();

    //     sum += a*a*cot1/8+b*b*cot2/8;
    //     now = now->next->next->pair;

    // }while(now!=NULL && now != this->edge);

    for(auto edge: this->flows){
        vector p = edge->vertex->pos;
        vector u = edge->next->vertex->pos-p;
        vector v = edge->next->next->vertex->pos-p;
        sum += 0.5*(u.cross(v)).norm();
    }
    sum /= 3.0;

    return sum;
}
