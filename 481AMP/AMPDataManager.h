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

@property (nonatomic) long currentReadValue;
@property (nonatomic) long initialReadValue;
@property (nonatomic) BOOL digitalValue;

@property (nonatomic) AMPControlLightsViewController *myHue;

+(id)sharedManager;

@end


