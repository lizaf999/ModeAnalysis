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
-(void)setPallalelogram;
-(void)setVerticesAndFaces:(NSArray *)vertices faces:(NSArray*)faces;
-(void)solveEigenValueProblem;
-(NSArray*)getEigenValue;
-(NSArray*)getEigenVector:(int) ID;
@end


#endif
