//
//  AMPDataModel.h
//  481AMP
//
//  Created by Alexander Athan on 10/27/14.
//  Copyright (c) 2014 Fiore Basile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMPControlLightsViewController.h"

@class AMPControlLightsViewController;

@interface AMPDataManager : NSObject

@property (nonatomic) BOOL gameMode;

@property (nonatomic) NSMutableArray *currentTubeValues; //Analog input
@property (nonatomic) NSMutableArray *initialTubeValues; //Resting position

@property (nonatomic) NSMutableArray *floorValues; //Digital input

@property (nonatomic) AMPControlLightsViewController *myHue;

+(id)sharedManager;

-(void)updateValue:(uint32_t) value forPin:(NSNumber *) pinNumber andIsAnalog:(BOOL) isAnalog;

@end


