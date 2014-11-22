//
//  AMPDataModel.m
//  481AMP
//
//  Created by Alexander Athan on 10/27/14.
//  Copyright (c) 2014 Fiore Basile. All rights reserved.
//

#import "AMPDataManager.h"
#import <AVFoundation/AVFoundation.h>

#define DEFAULT_BRIGHTNESS 140

@implementation AMPDataManager

+(id)sharedManager{
    static AMPDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(void)updateValue:(uint32_t) value forPin:(NSNumber *) pinNumber andIsAnalog:(BOOL) isAnalog{
    if(isAnalog){
        NSNumber *analogValue = [NSNumber numberWithInt:value];
        if(value < 10){
            return;
        }
        [self updateAnalogPin:pinNumber withValue:analogValue];
    }else{
        BOOL digitalValue = value;
        [self updateDigitalPin:pinNumber withValue:digitalValue];
    }
}

-(void)updateAnalogPin:(NSNumber *) pinNumber withValue:(NSNumber *) value{
    [self.currentTubeValues replaceObjectAtIndex:[pinNumber intValue] withObject:value];
    if([self isPullingBand:pinNumber]){
        NSNumber *initialReading = [self.initialTubeValues objectAtIndex:[pinNumber intValue]];
        int differenceInReading = [value intValue] - [initialReading intValue];
        int newBrightnessValue = DEFAULT_BRIGHTNESS + differenceInReading;
        if (newBrightnessValue > 241){
            newBrightnessValue = 241;
        }
        NSNumber *newBrightness = [NSNumber numberWithInt:newBrightnessValue];
        [self.myHue changeBrightness:newBrightness ofLightNumber:pinNumber];
    }else{
        [self.myHue changeBrightness:[NSNumber numberWithInt:DEFAULT_BRIGHTNESS] ofLightNumber:pinNumber];
    }
}

-(BOOL)isPullingBand:(NSNumber *)pinNumber{
    NSNumber *newValue = [self.currentTubeValues objectAtIndex:[pinNumber intValue]];
    NSNumber *initialValue = [self.initialTubeValues objectAtIndex:[pinNumber intValue]];
    int thresholdValue = 0.95*[initialValue intValue];
    return ([newValue intValue] < thresholdValue);
}

//-(BOOL)isPushingBand:(NSNumber *)currentReadValue{
//    return (currentReadValue > 1.05*_initialReadValue && _brightnessValue <= 241);
//}

-(void)updateDigitalPin:(NSNumber *)pinNumber withValue:(BOOL) value{
    NSNumber *previousState = [self.floorValues objectAtIndex:[pinNumber intValue]];
    BOOL isPressedAlready = [previousState boolValue];
    if(!isPressedAlready && value){
        [self.myHue changeLightsToRandomColor];
    }
    [self.floorValues replaceObjectAtIndex:[pinNumber intValue] withObject:[NSNumber numberWithBool:value]];
}

-(void)playSongWithName:(NSString *)songName andType:(NSString *)songType{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:songName ofType:songType]];
    AVAudioPlayer *songPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [songPlayer setVolume:0.5f];
    [songPlayer prepareToPlay];
    [songPlayer play];
}

@end
