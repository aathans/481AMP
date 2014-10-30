//
//  AMPDataModel.m
//  481AMP
//
//  Created by Alexander Athan on 10/27/14.
//  Copyright (c) 2014 Fiore Basile. All rights reserved.
//

#import "AMPDataManager.h"

@implementation AMPDataManager

+(id)sharedManager{
    static AMPDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(void)setCurrentReadValue:(long)currentReadValue{
    if(currentReadValue < 0.95*_initialReadValue){
        [self.myHue changeLightsToRandomColor];
    }
}

-(void)setDigitalValue:(BOOL)digitalValue{
    if(digitalValue && self.digitalValue != 1){
        [self.myHue changeLightsToRandomColor];
    }
    _digitalValue = digitalValue;
}
@end
