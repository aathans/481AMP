//
//  AMPControlLightsViewController.h
//  481AMP
//
//  Created by Alexander Athan on 10/26/14.
//  Copyright (c) 2014 Fiore Basile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMPDataManager.h"

@class AMPDataManager;

@interface AMPControlLightsViewController : NSViewController

@property (nonatomic) AMPDataManager* dataManager;

- (void)changeBrightness:(NSNumber *)brightness;
- (void)changeLightsToRandomColor;

@end
