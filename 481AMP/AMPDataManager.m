//
//  AMPDataModel.m
//  481AMP
//
//  Created by Alexander Athan on 10/27/14.
//  Copyright (c) 2014 Fiore Basile. All rights reserved.
//

#import "AMPDataManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation AMPDataManager

+(id)sharedManager{
    static AMPDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(void)setCurrentReadValue:(uint32_t)currentReadValue{
    if([self isPullingBand:currentReadValue]){
        NSNumber *newBrightness = [NSNumber numberWithInt:(self.brightnessValue*0.80f)];
        [self.myHue changeBrightness:newBrightness];
    }else if([self isPushingBand:currentReadValue]){
        NSNumber *newBrightness = [NSNumber numberWithInt:(self.brightnessValue*1.20f)];
        [self.myHue changeBrightness:newBrightness];
    }
}

-(BOOL)isPullingBand:(uint32_t)currentReadValue{
    return (currentReadValue < 0.95*_initialReadValue);
}

-(BOOL)isPushingBand:(uint32_t)currentReadValue{
    return (currentReadValue > 1.05*_initialReadValue && _brightnessValue <= 241);
}

-(void)setDigitalValue:(BOOL)digitalValue{
    if(digitalValue && self.digitalValue != 1){
        [self.myHue changeLightsToRandomColor];
    }
    _digitalValue = digitalValue;
}

-(void)playSongWithName:(NSString *)songName andType:(NSString *)songType{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:songName ofType:songType]];
    AVAudioPlayer *songPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [songPlayer setVolume:0.5f];
    [songPlayer prepareToPlay];
    [songPlayer play];
}

@end
