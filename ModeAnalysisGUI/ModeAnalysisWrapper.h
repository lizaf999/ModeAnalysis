#ifndef ModeAnalysisWrapper_h
#define ModeAnalysisWrapper_h

#import <Foundation/Foundation.h>

typedef struct XYZ{
  double x;
  double y;
  double z;
}xyz;

@interface ObjCppModeAnalysis:NSObject{
  void* _cppModeAnalysis;
}
-(void)setVerticesAndFaces:(NSArray *)vertices faces:(NSArray*)faces;
-(void)solveEigenValueProblem;
-(NSArray*)getEigenValue;
-(NSArray*)getEigenVector:(int) ID;
-(NSArray*)getNormals:(NSArray*)positions;
-(NSArray*)getProjectedPosOn:(int) eigenID;
#pragma mark Public Mehotds
//-(NSArray*)array_xyzToNSArray:(std::vector<ModeAnalysis::xyz>*) vertices_cpp;
@end


#endif
