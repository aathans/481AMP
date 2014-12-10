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
#define INCREMENT_MULTIPLIER 600
#define FLOOR_START_PIN 7
#define NUM_SOUNDS 3

@implementation AMPDataManager

@synthesize lightIsRed = _lightIsRed;

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
        if([self isPullingBand:pinNumber withValue:analogValue]){
            [self updateAnalogPin:pinNumber withValue:analogValue];
        }else{
            NSNumber *initialValue = [self.initialTubeValues objectAtIndex:[pinNumber intValue]];
            NSNumber *currentValue = [self.currentMaxTubeValues objectAtIndex:[pinNumber intValue]];
            if(![currentValue isEqualToNumber:initialValue]){
                [self.currentMaxTubeValues replaceObjectAtIndex:[pinNumber intValue] withObject:initialValue];
            }
        }
    }else{
        BOOL digitalValue = value;
        [self updateDigitalPin:pinNumber withValue:digitalValue];
    }
}

-(void)updateAnalogPin:(NSNumber *) pinNumber withValue:(NSNumber *) value{
    NSNumber *previousValue = [self.currentMaxTubeValues objectAtIndex:[pinNumber intValue]];
    if([value intValue] >= [previousValue intValue]){
        return;
    }
    
    [self.currentMaxTubeValues replaceObjectAtIndex:[pinNumber intValue] withObject:value];
    
    NSNumber *lightNumber = [NSNumber numberWithInt:[pinNumber intValue] + 1];

    NSNumber *initialReading = [self.initialTubeValues objectAtIndex:[pinNumber intValue]];
    
    int differenceInReading = abs([value intValue] - [initialReading intValue]);
    int incrementValue = differenceInReading*INCREMENT_MULTIPLIER;
    [self.myHue incrementHueBy:incrementValue ofLightNumber:lightNumber];
}

-(BOOL)isPullingBand:(NSNumber *)pinNumber withValue:(NSNumber *)inValue{
    NSNumber *initialValue = [self.initialTubeValues objectAtIndex:[pinNumber intValue]];
    int thresholdValue = 0.95*[initialValue intValue];
    
    return ([inValue intValue] < thresholdValue);
}

-(NSArray *)soundList
{
    if (!_soundList) {
        _soundList = @[@"chicken",@"goose",@"horse"];
    }
    return _soundList;
}

-(void)updateDigitalPin:(NSNumber *)pinNumber withValue:(BOOL) value{
    if(self.lightIsRed){
        return;
    }
    
    NSNumber *previousState = [self.floorValues objectAtIndex:([pinNumber intValue]-FLOOR_START_PIN)];
    BOOL isPressedAlready = [previousState boolValue];
    if(!isPressedAlready && value){
        int soundIndex = arc4random() % NUM_SOUNDS;
        NSString *soundName = [self.soundList objectAtIndex:soundIndex];
        [self playSoundWithName:soundName andType:@"mp3"];
    }
    [self.floorValues replaceObjectAtIndex:([pinNumber intValue]-FLOOR_START_PIN) withObject:[NSNumber numberWithBool:value]];
}


-(void)playSoundWithName:(NSString *)songName andType:(NSString *)songType{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:songName ofType:songType]];
    self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_soundPlayer setVolume:1.0f];
    [_soundPlayer play];
}

-(BOOL)lightIsRed{
    return _lightIsRed;
}

-(void)setLightIsRed:(BOOL)lightIsRed{
    _lightIsRed = lightIsRed;
    if(lightIsRed){
        [self.mainWC redLightWasSet];
    }
}

@end
