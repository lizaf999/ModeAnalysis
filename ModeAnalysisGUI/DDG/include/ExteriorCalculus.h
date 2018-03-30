#ifndef DDG_EXTERIORCALCULUS_H
#define DDG_EXTERIORCALCULUS_H

#include "../include/Eigen/Core"
#include "../include/HalfEdge.h"
#include <vector>

using namespace std;
using namespace Eigen;

//呼ぶ順番が複雑
vector<bool> detectBoundary(HEGraph* graph);
MatrixXd* getLaplacian0form(vector<bool> isFixed,HEGraph* graph);
void convert0formToGenenalized3form(MatrixXd* matrix,vector<bool> isFixed,HEGraph* graph);
MatrixXd* reshapeForModeAnalysis(MatrixXd* matrix,vector<bool> isFixed);

void calcEigenValueandVector(MatrixXd* matrix,VectorXd* eigenValues, MatrixXd* eigenVectors);
MatrixXd* getGeneralizedEigenVectors(MatrixXd* eigenVectors,vector<bool> isFixed, HEGraph* graph);

void printDisplacedVertices(vector<Vector3d> vertices,VectorXd eigenVector,vector<bool> isFixed);
VectorXd getFullEigenVector(VectorXd eigenVector,vector<bool> isFixed);

#endif
