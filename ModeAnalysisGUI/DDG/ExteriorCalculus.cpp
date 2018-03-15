#include <iostream>
#include "../include/Eigen/Core"
#include "../include/Eigen/Dense"
#include "../include/HalfEdge.h"
#include <vector>

using namespace Eigen;
using namespace std;

MatrixXd* getLaplacian0form(vector<bool> isFixed,HEGraph* graph)
{   
    cout << "getLaplacian0form start.";
    int n = graph->vertices.size();

    MatrixXd* matrix = new MatrixXd();
    *matrix = MatrixXd::Zero(n,n);

    for(auto vertex: graph->vertices){
        int id = vertex->ID;
        if(isFixed[id]){
            (*matrix)(id,id) = 1;
        }else{
            for(auto edge: vertex->flows){
                double cot = edge->cotanSum();
                (*matrix)(id,id) += -cot;

                int nextID = edge->next->vertex->ID;
                if(!isFixed[nextID]){(*matrix)(id,nextID) += cot;}
                else{}
            }
        }
    }
    cout << " finished." << endl;
    return matrix;
}

vector<bool> detectBoundary(HEGraph* graph)
{
    cout << "detectBoundary start.";
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
    if(noBoundary) cout << "No Boundary" << endl;
    cout << " finished." << endl;
    return isFixed;
}

void convert0formToGenenalized3form(MatrixXd* matrix,vector<bool> isFixed,HEGraph* graph)
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
    for(int i=0;i<n;i++){
    for(int j=0;j<n;j++){
        (*matrix)(i,j) /= sqrt(dualArea[i]*dualArea[j]);
    }
    }
    cout << " finished." << endl;
}

Eigen::MatrixXd* reshapeForModeAnalysis(Eigen::MatrixXd* matrix,vector<bool> isFixed)
{
    cout << "reshapeForModeAnalysis start.";
    int n = 0;
    for(int i=0;i<isFixed.size();i++){
        if(!isFixed[i]) n++;
    }
    
    MatrixXd* matrix_tar = new MatrixXd();
    *matrix_tar = MatrixXd::Zero(n,n);
    int col = 0;
    for(int i=0;i<matrix->cols();i++){//col?
        if(!isFixed[i]){
            for(int j=0;j<matrix->rows();j++){
                int newID = j;
                for(int k=0;k<j;k++){
                    if(isFixed[k]) newID--;
                }
                //cout << (*matrix)(i,j) << " ";
                if(newID>=324){
                    //cout << i << " " <<j << " " << newID << endl;
                    continue;
                }
                (*matrix_tar)(col,newID) = (*matrix)(i,j);
            }
            col++;
        }
    }
    cout << " finished." << endl;
    return matrix_tar;
}

void calcEigenValueandVector(MatrixXd* matrix,VectorXd* eigenValues,MatrixXd* eigenVectors)
{
    cout << "calcEigenValuesAndVector start."<<endl;
    SelfAdjointEigenSolver<MatrixXd> es(*matrix);
    if(es.info() != Success){
        cout << "failed during EigenSolver" << endl;
        return;
    }else{
        *eigenValues  = es.eigenvalues();
        *eigenVectors = es.eigenvectors();
    }
    cout << "eigen values and eigen vectors were succeessfully gained." << endl;
}

Eigen::MatrixXd* getGeneralizedEigenVectors(MatrixXd* eigenVectors, vector<bool> isFixed,HEGraph* graph)
{
    int n = eigenVectors->rows();
    VectorXd dualArea(n);
    MatrixXd* matrix = new MatrixXd();
    *matrix = MatrixXd::Zero(n,n);

    int k=0;
    for(int i=0;i<graph->vertices.size();i++){
        if(!isFixed[i]){
            dualArea(k) = graph->vertices[i]->dualArea();
            k++;    
        }
    }
    for(int i=0;i<n;i++){
    for(int j=0;j<n;j++){
        (*matrix)(i,j) = (*eigenVectors)(i,j)/dualArea(i);
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
    return fullvec;//値が保持されるかどうか

    }
