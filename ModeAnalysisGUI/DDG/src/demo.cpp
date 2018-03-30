#include "../include/ModeAnalysis.h"
#include "../include/Eigen/Core"
#include "../include/Eigen/Dense"
#include <iostream>
#include <vector>

using namespace std;
using namespace Eigen;

typedef Vector3d v3;

void Pallalelogram(vector<v3>* vertices,vector<vector<int> >* faces){
    int row = 30;
    int col = 30;
    double width = 1;
    double height = 1;
    double dx = width/(row-1);
    double dy = height/(col-1);

    
    for(int i=0;i<col;i++){
    for(int j=0;j<row;j++){
        v3 p = v3(dx*j,dy*i,0)-v3(0.5,0.5,0);
        p(0) += p(1);
        vertices->push_back(p);
    }
    }
    
    for(int i=0;i<col-1;i++){
    for(int j=0;j<row-1;j++){
        vector<int> f1 = {j+i*row,j+(i+1)*row,j+1+i*row}; 
        vector<int> f2 = {j+(i+1)*row,j+1+(i+1)*row,j+1+i*row};
        faces->push_back(f1);
        faces->push_back(f2);
    }
    }
}

int main(){
   //mesh setup
    vector<v3> vertices;
    vector<vector<int> > faces;
    
    Pallalelogram(&vertices,&faces);

    vector<ModeAnalysis::xyz> v_xyz;
    for(auto vertex: vertices){
        ModeAnalysis::xyz v = {vertex(0),vertex(1),vertex(2)};
        v_xyz.push_back(v);
    }


    //Mode Analysis
    ModeAnalysis* mode = new ModeAnalysis();
    mode->setVerticesandFaces(v_xyz,faces);
    mode->solveEigenProblem();

    vector<double> vals = mode->getEigenValues();
    vector<double> vec = mode->getEigenVector(4);

    int n_val = vals.size();
    cout << "EigenValues" <<endl;
    for(int i=0;i<n_val;i++){
        cout << vals[i] << endl;
    }
    int n_vec = vec.size();
    cout << "5th EigenVector. Please plot vertices in 3D." <<endl;
    for(int i=0;i<n_vec;i++){
        v3 p = vertices[i]+v3(0,0,1)*vec[i]*0.3;
        cout << p.transpose() << endl;
    }


}