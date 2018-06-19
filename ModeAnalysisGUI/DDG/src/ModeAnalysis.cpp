#include "../include/ModeAnalysis.h"
#include "../include/ExteriorCalculus.h"
#include "../include/Eigen/Dense"
#include "../include/Eigen/SparseCore"
#include <vector>
#include <iostream>

using namespace std;
using namespace Eigen;

void ModeAnalysis::setVerticesandFaces(vector<ModeAnalysis::xyz> vertices,vector<vector<int> > faces)
{
  for(auto vx: vertices){
    this->vertices.push_back(Eigen::Vector3d(vx.x,vx.y,vx.z));
  }
  this->faces = faces;
}

void ModeAnalysis::solveEigenProblem()
{   
  graph = new HEGraph();
  SparseMatrix<double>* matrix;
  SparseMatrix<double>* matrix_small;

  graph->setElements(vertices,faces);
  isFixed = detectBoundary(graph);

  matrix = getLaplacian0form(isFixed,graph);
  convert0formToGenenalized3form(matrix,isFixed,graph);

  matrix_small = reshapeForModeAnalysis(matrix,isFixed);
  if (matrix!=matrix_small) {
    delete(matrix);
  }

  MatrixXd* vecs = new MatrixXd();
  eigenValues = new VectorXd();
  calcEigenValueandVector(matrix_small,eigenValues,vecs);

  eigenVectors = getGeneralizedEigenVectors(vecs,isFixed,graph);

}

vector<double> ModeAnalysis::getEigenValues()
{
  int n = eigenValues!=NULL ? eigenValues->size() : 0;
  vector<double> vals(n,0);
  for(int i=0;i<n;i++){
    vals[i] = (*eigenValues)(i);
  }
  return vals;
}

vector<double> ModeAnalysis::getEigenVector(int ID)
{
  if (ID>=eigenVectors->cols()) {
    return vector<double>(isFixed.size(),0);
  }
  VectorXd eigenVector = eigenVectors->col(ID);
  int n_small = eigenVector.size();
  vector<double> vec(n_small,0);
  double maxi=0;
  for(int i=0;i<n_small;i++){
    vec[i] = eigenVector(i);
    if(abs(vec[i])>maxi) maxi = abs(vec[i]);
  }
  if(maxi==0){
    cout << "0 vector" << endl;
    maxi=1;
  }

  int n = isFixed.size();
  vector<double> fullvec(n,0);
  int j=0;
  for(int i=0;i<n;i++){
    if(isFixed[i]){
      fullvec[i] = 0;
    }else{
      fullvec[i] = vec[j]/maxi;
      j++;
    }
  }
  return fullvec;
}

vector<ModeAnalysis::xyz> ModeAnalysis::getNormal(vector<ModeAnalysis::xyz> positions)
{
  int n = positions.size();
  vector<Vector3d> normals;

  for(int i=0;i<n;i++){
    Vector3d normal = Vector3d::Zero();
    HEVertex* vertex = graph->vertices[i];
    HEEdge* edge = vertex->edge;
    do{
      xyz p1_c,p2_c,p3_c;
      Vector3d p1,p2,p3,u,v;
      p1_c = positions[edge->vertex->ID];
      p2_c = positions[edge->next->vertex->ID];
      p3_c = positions[edge->next->next->vertex->ID];
      p1 = Vector3d(p1_c.x,p1_c.y,p1_c.z);
      p2 = Vector3d(p2_c.x,p2_c.y,p2_c.z);
      p3 = Vector3d(p3_c.x,p3_c.y,p3_c.z);
      u  = p2-p1;
      v  = p3-p1;
      normal += u.cross(v);
      edge = edge->next->next->pair;
    }while(edge!=NULL && edge!=vertex->edge);

    normal.normalize();
    normals.push_back(normal);
  }

  vector<xyz> normals_xyz;
  for(auto pos: normals){
    xyz nr = {pos(0),pos(1),pos(2)};
    normals_xyz.push_back(nr);
  }

  return normals_xyz;
}

vector<ModeAnalysis::xyz> ModeAnalysis::projectPosOnEigenVec(int ID)
{
  int n = vertices.size();
  int nVal = eigenValues->size();
  if (ID>=nVal) {
    return vector<xyz>(vertices.size(),xyz({0,0,0}));
  }
  vector<double> eigenVec = getEigenVector(ID);
  Vector3d mht = Vector3d::Zero();
  double norm = 0;
  for (int i=0; i<n; i++) {
    mht += vertices[i]*eigenVec[i];
    norm += eigenVec[i]*eigenVec[i];
  }
  
  //IDまで全て重ね合わせる
  vector<xyz> projected(n,xyz({0,0,0}));

  for (int j=ID; j>=0; j--) {
    eigenVec = getEigenVector(j);
    mht = Vector3d::Zero();
    norm = 0;
    for (int i=0; i<n; i++) {
      mht += vertices[i]*eigenVec[i];
      norm += eigenVec[i]*eigenVec[i];
    }
    for (int i=0; i<n; i++) {
      Vector3d p = mht*eigenVec[i]/norm;
      projected[i].x += p.x();
      projected[i].y += p.y();
      projected[i].z += p.z();
    }
  }

  static vector<pair<double, int>> absMHT;
  if (absMHT.size() != eigenValues->size()) {
    absMHT = vector<pair<double, int>>(nVal,make_pair(0, 0));
    for (int i=0; i<nVal; i++) {
      eigenVec = getEigenVector(i);
      mht = Vector3d::Zero();
      norm = 0;
      for (int j=0; j<n; j++) {
        mht += vertices[j]*eigenVec[j];
        norm += eigenVec[j]*eigenVec[j];
      }
      double lg = mht.norm();
      absMHT[i] = make_pair(lg, i);
    }
    sort(absMHT.begin(), absMHT.end(), greater<pair<double, int>>());
    for (int i=0; i<20; i++) {
      cout << absMHT[i].first << " " << absMHT[i].second << endl;
    }
  }




  return projected;
}












