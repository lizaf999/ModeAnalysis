#include "../include/ModeAnalysis.h"
#include "../include/ExteriorCalculus.h"
#include "../include/Eigen/Core"
#include <vector>
#include <iostream>

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
    MatrixXd* matrix = new MatrixXd();
    MatrixXd* matrix_small = new MatrixXd();
    
    graph->setElements(vertices,faces);
    isFixed = detectBoundary(graph);

    matrix = getLaplacian0form(isFixed,graph);
    convert0formToGenenalized3form(matrix,isFixed,graph);
    
    matrix_small = reshapeForModeAnalysis(matrix,isFixed);
    delete(matrix);

    MatrixXd* vecs = new MatrixXd();
    eigenValues = new VectorXd();
    calcEigenValueandVector(matrix_small,eigenValues,vecs);
    
    //debug
    cout<<vecs->rows()<<endl;
    
    eigenVectors = getGeneralizedEigenVectors(vecs,isFixed,graph);

}

vector<double> ModeAnalysis::getEigenValues()
{
    int n = eigenValues->size();
    vector<double> vals(n,0);
    for(int i=0;i<n;i++){
        vals[i] = (*eigenValues)(i);
    }
    return vals;
}

vector<double> ModeAnalysis::getEigenVector(int id)
{
    VectorXd eigenVector = eigenVectors->col(eigenVectors->cols()-id-1);//inverce
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

void ModeAnalysis::setPallalellogram(){
    //mesh setup
    int row = 20;
    int col = 20;
    double width = 1;
    double height = 1;
    double dx = width/(row-1);
    double dy = height/(col-1);
    
    for(int i=0;i<col;i++){
        for(int j=0;j<row;j++){
            v3 p = v3(dx*j,dy*i,0)-v3(0.5,0.5,0);
            //p(0) += p(1);
            vertices.push_back(p);
        }
    }
    
    for(int i=0;i<col-1;i++){
        for(int j=0;j<row-1;j++){
            vector<int> f1 = {j+i*row,j+(i+1)*row,j+1+i*row};
            vector<int> f2 = {j+(i+1)*row,j+1+(i+1)*row,j+1+i*row};
            faces.push_back(f1);
            faces.push_back(f2);
        }
    }
}
