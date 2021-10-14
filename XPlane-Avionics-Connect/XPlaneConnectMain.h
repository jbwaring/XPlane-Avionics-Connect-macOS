//
//  XPlaneConnectMain.h
//  XPlane-Avionics-Connect
//
//  Created by Jean-Baptiste Waring on 2021-10-13.
//
#ifndef XPlaneConnectMain_h
#define XPlaneConnectMain_h
#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "xplaneConnect.h"

@interface XPlaneConnectMain : NSObject // Inherits from NSObject
{
    NSString *engine1REVFromSim;
    XPCSocket sock;
    
}

+ (XPlaneConnectMain*) init:(int)overriden ; //Overriden init to set up environment.
-(float)getDataRefScalarFloat:(NSString *)dataRefIdentifier andSize:(int)sizeOfData andElement:(int)elementNo;
-(void)sendThrottleCommand:(float)withCommandedThrottle;
@end

#endif /* XPlaneConnectMain_h */
