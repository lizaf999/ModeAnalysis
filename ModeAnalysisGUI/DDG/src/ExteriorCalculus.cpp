#include <iostream>
#include "../include/Eigen/Core"
#include "../include/Eigen/Dense"
#include "../include/Eigen/SparseCore"

#include "../include/HalfEdge.h"
#include "../include/Spectra/SymEigsSolver.h"
#include "../include/Spectra/MatOp/SparseSymMatProd.h"
#include <vector>

using namespace Eigen;
using namespace Spectra;
using namespace std;

SparseMatrix<double>* getLaplacian0form(vector<bool> isFixed,HEGraph* graph)
{
  cout << "getLaplacian0form start.";
  int n = graph->vertices.size();
  
  SparseMatrix<double>* M = new SparseMatrix<double>(n,n);
  M->reserve(6*n);
  for(auto vertex: graph->vertices){
    int id = vertex->ID;
    if(isFixed[id]){
      M->insert(id, id) = 1;
    }else{
      double acc_cot = 0;
      for(auto edge: vertex->flows){
        double cot = edge->cotanSum();
        acc_cot += cot;
        
        int nextID = edge->next->vertex->ID;
        if(!isFixed[nextID]){M->insert(id,nextID) = cot;}//+=じゃなくても大丈夫か
        else{}
      }
      M->insert(id, id) = -acc_cot;
    }
  }
  cout << " finished." << endl;
  
  return M;
}

SparseMatrix<double>* getCombinationalLaplacian(vector<bool> isFixed,HEGraph* graph)
{
  cout << "getLaplacian0form start.";
  int n = graph->vertices.size();

  SparseMatrix<double>* M = new SparseMatrix<double>(n,n);
  M->reserve(6*n);
  for(auto vertex: graph->vertices){
    int id = vertex->ID;
    if(isFixed[id]){
      M->insert(id, id) = 1;
    }else{
      for(auto edge: vertex->flows){
        int nextID = edge->next->vertex->ID;
        if(!isFixed[nextID]){M->insert(id,nextID) = -1;}
        else{}
      }
      M->insert(id, id) = vertex->flows.size();
    }
  }
  cout << " finished." << endl;

  return M;
}

vector<bool> detectBoundary(HEGraph* graph)
{
  cout << "detectBoundary start. ";
  int n = graph->vertices.size();
  vector<bool> isFixed(n,false);
  
  bool noBoundary = true;
  for(auto vertex: graph->vertices){
    for(auto edge: vertex->flows){
      if(edge->pair==NULL){
        isFixed[edge->vertex->ID] = true;
        isFixed[edge->next->vertex->ID] = true;
        noBoundary = false;
      }
    }
  }
  if(noBoundary) cout << "No Boundary was detected. ";
  cout << "finished." << endl;
  return isFixed;
}

void convert0formToGenenalized3form(SparseMatrix<double>* matrix,vector<bool> isFixed,HEGraph* graph)
{
  cout<< "convert0formToGenenalized3form start.";
  int n = graph->vertices.size();
  vector<double> dualArea(n,1);
  for(int i=0;i<n;i++){
    dualArea[i] = isFixed[i] ? 1:graph->vertices[i]->dualArea();
    if(dualArea[i]<=0){
      cout<<"invalid area"<<endl;
      assert(dualArea[i]>0);
    }
  }
  
  int nOuter = matrix->outerSize();
  for (int i=0; i<nOuter; i++) {
    for (SparseMatrix<double>::InnerIterator it(*matrix,i); it; ++it) {
      int row = it.row();
      int col = it.col();
      matrix->coeffRef(row, col) /= sqrt(dualArea[row]*dualArea[col]);
    }
  }
  
  cout << " finished." << endl;
}

SparseMatrix<double>* reshapeForModeAnalysis(SparseMatrix<double>* matrix,vector<bool> isFixed)
{
  cout << "reshapeForModeAnalysis start.";
  int n = 0;
  for(int i=0;i<isFixed.size();i++){
    if(!isFixed[i]) n++;
  }
  
  if (n==matrix->cols()){
    cout << "No chages. finished." << endl;
    return matrix;
  }
  
  SparseMatrix<double>* matrix_tar = new SparseMatrix<double>(n,n);
  matrix_tar->reserve(6*n);

  int nOuter = matrix->outerSize();
  int nowCol = 0;
  for (int i=0; i<nOuter; i++) {
    if(!isFixed[i]){
      for (SparseMatrix<double>::InnerIterator it(*matrix,i); it; ++it) {
        int row = it.row();
        int newID = row;
        if (isFixed[newID]) {
          continue;
        }
        for(int k=0;k<row;k++){
          if(isFixed[k]) newID--;
        }
        matrix_tar->insert(nowCol, newID) = matrix->coeff(it.row(), it.col());
      }
      nowCol++;
    }
  }
  cout << " finished." << endl;
  return matrix_tar;
}

void calcEigenValueandVector(SparseMatrix<double>* matrix,VectorXd* eigenValues,MatrixXd* eigenVectors)
{
  cout << "calcEigenValuesAndVectors start."<<endl;
  
  SparseSymMatProd<double> op(*matrix);
  SymEigsSolver<double, SMALLEST_MAGN, SparseSymMatProd<double>> eigs(&op, 100, 200);
  eigs.init();
  eigs.compute();
  if (eigs.info() == SUCCESSFUL) {
    *eigenValues = eigs.eigenvalues();
    *eigenVectors = eigs.eigenvectors();
  }
  cout << "eigen values and eigen vectors were succeessfully gained." << endl;
}

Eigen::MatrixXd* getGeneralizedEigenVectors(MatrixXd* eigenVectors, vector<bool> isFixed,HEGraph* graph)
{
  int nRow = eigenVectors->rows();
  int nCol = eigenVectors->cols();
  VectorXd dualArea(nRow);
  MatrixXd* matrix = new MatrixXd();
  *matrix = MatrixXd::Zero(nRow,nCol);
  
  int k=0;
  for(int i=0;i<graph->vertices.size();i++){
    if(!isFixed[i]){
      dualArea(k) = graph->vertices[i]->dualArea();
      k++;
    }
  }
  for(int i=0;i<nRow;i++){
    for(int j=0;j<nCol;j++){
      (*matrix)(i,j) = (*eigenVectors)(i,j)/dualArea(i);
    }
  }
  return matrix;
}

Eigen::MatrixXd* reverseEigenVectors(MatrixXd* eigenVectors)
{
  int nRow = eigenVectors->rows();
  int nCol = eigenVectors->cols();
  MatrixXd* matrix = new MatrixXd();
  *matrix = MatrixXd::Zero(nRow,nCol);

  for(int i=0;i<nRow;i++){
    for(int j=0;j<nCol;j++){
      (*matrix)(i,j) = (*eigenVectors)(i,nCol-j-1);
    }
  }
  return matrix;
}

void printDisplacedVertices(vector<Vector3d> vertices,VectorXd eigenVector,vector<bool> isFixed)
{
  cout << "print vertices" << endl;
  int n_mod = eigenVector.size();
  vector<double> vec(n_mod,0);
  double maxi = 0;
  for(int i=0;i<n_mod;i++){
    vec[i] = eigenVector(i);
    if(abs(vec[i])>maxi) maxi = abs(vec[i]);
  }
  if(maxi==0){
    cout << "0 vector" << endl;
    maxi=1;
    return;
  }
  for(int i=0;i<n_mod;i++){
    vec[i] /= maxi;
  }
  
  int j=0;
  for(int i=0;i<vertices.size();i++){
    Vector3d p(0,0,0);
    if(!isFixed[i]){
      p = vertices[i] + vec[j]*v3(0,0,1)*0.3;
      j++;
    }else{
      p = vertices[i];
    }
    cout <<p.transpose()<<endl;
  }
  
}

VectorXd getFullEigenVector(VectorXd eigenVector,vector<bool> isFixed)
{
  cout<<"getFullEigenVector"<<endl;
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
  
  VectorXd fullvec = VectorXd(isFixed.size());
  int j=0;
  for(int i=0;i<isFixed.size();i++){
    if(isFixed[i]){
      fullvec(i) = 0;
    }else{
      fullvec(i) = vec[j]/maxi;
      j++;
    }
  }
  return fullvec;
}













