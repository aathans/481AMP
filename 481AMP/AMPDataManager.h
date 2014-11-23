//
//  AMPDataModel.h
//  481AMP
//
//  Created by Alexander Athan on 10/27/14.
//  Copyright (c) 2014 Fiore Basile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMPControlLightsViewController.h"
#import "AMPMusicPlayer.h"

@class AMPControlLightsViewController;

@interface AMPDataManager : NSObject

@property (nonatomic) BOOL lightIsRed;

@property (nonatomic) NSMutableArray *currentMaxTubeValues; //Analog input
@property (nonatomic) NSMutableArray *initialTubeValues; //Resting position
@property (nonatomic) NSMutableArray *isPulling;

@property (nonatomic) NSMutableArray *floorValues; //Digital input

@property (nonatomic) AMPControlLightsViewController *myHue;
@property (nonatomic) AMPMusicPlayer *musicPlayer;
@property (nonatomic) AVAudioPlayer *soundPlayer;
@property (nonatomic) NSArray *soundList;

+(id)sharedManager;

-(void)updateValue:(uint32_t) value forPin:(NSNumber *) pinNumber andIsAnalog:(BOOL) isAnalog;

@end


