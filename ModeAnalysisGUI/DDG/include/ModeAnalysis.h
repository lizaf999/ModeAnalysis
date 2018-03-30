#ifndef DDG_MODEANALYSIS_H
#define DDG_MODEANALYSIS_H
#include "../include/ExteriorCalculus.h"
#include "../include/Eigen/Core"
#include <vector>

using namespace std;
using namespace Eigen;

class ModeAnalysis{
    private:
    vector<Vector3d> vertices;
    vector<vector<int> > faces;
    HEGraph* graph;
    vector<bool> isFixed;

    VectorXd* eigenValues;
    MatrixXd* eigenVectors;

    public:
    struct xyz{
        double x;
        double y;
        double z;
    };
    
    void setVerticesandFaces(vector<xyz> vertices,vector<vector<int> > faces);
    void solveEigenProblem();
    vector<double> getEigenValues();
    vector<double> getEigenVector(int ID);
    vector<xyz> getNormal(vector<xyz> positions);
};

#endif
