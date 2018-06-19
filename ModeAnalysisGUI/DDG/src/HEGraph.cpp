#include <vector>
#include <iostream>
#include "../include/Eigen/Core"
#include "../include/Elements.h"
#include "../include/HEGraph.h"

typedef Eigen::Vector3d v3;
using namespace std;

void HEGraph::setElements(vector<v3> vertices,vector<vector<int> > faces)
{
  setVertices(vertices);
  setFaces(faces);
}

void HEGraph::setVertices(vector<v3> pos)
{
  for(int i=0;i<pos.size();i++)
  {
    HEVertex* vertex = new HEVertex(pos[i],i);
    this->vertices.push_back(vertex);
  }
  cout << "Verteices Count " << this->vertices.size()<<endl;
}

void HEGraph::setFaces(vector<vector<int> > polygons)
{
  for(vector<int> polygon :polygons)
  {
    HEFace* face = new HEFace();
    this->faces.push_back(face);
    vector<HEEdge*> edges;
    for(int i=0;i<polygon.size();i++)
    {
      HEEdge* edge = new HEEdge();
      HEVertex* vertex = vertices[polygon[i]];
      edge->vertex = vertex;
      vertex->flows.push_back(edge);
      if(vertex->edge==NULL) vertex->edge = edge;
      if(!edges.empty())edges.back()->next = edge;
      edge->face = face;
      edges.push_back(edge);
    }
    edges.back()->next = edges.front();
    face->edge = edges.front();
  }
  for(HEFace* face: faces)
  {
    //TODO iteratorの実装による簡略化
    HEEdge* edge = face->edge;
    do{
      edge->pair = findPair(edge);
      edge = edge->next;
    }while(edge!=NULL&&edge!=face->edge);
  }
}

HEEdge* HEGraph::findPair(HEEdge* edge)
{
  HEVertex* vertex = edge->next->vertex;
  for(HEEdge* flow: vertex->flows)
  {
    if(flow->next->vertex==edge->vertex 
       && flow->vertex==edge->next->vertex) return flow;
  }
  return NULL;
}
