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
#define FLOOR_START_PIN 7
#define NUM_SONGS 3
#define GAME_TIME_INTERVAL 30.0f

@implementation AMPDataManager

+(id)sharedManager{
    static AMPDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(void) resetGame{
    self.gameTimer = GAME_TIME_INTERVAL;
    self.prevTime = [NSDate date];
    //! TODO: change all the lights to green.
    //! TODO: restore sound to normal value
}

-(void) gameTimeRanOut{
    if(self.lightIsRed == false){
        self.lightIsRed = true;
        //! TODO: Turn a random light red.
        //! TODO: Set the gameDirectionToPull corresponding direction
    }
    //! TODO: Possibly turn down the sound
    //! TODO: Possibly turn down the lights
    
}

-(void) changeToGameMode{
    self.gameMode = true;
    [self resetGame];
    [self gameTimeRanOut];
    //! TODO: possibly turn sound to 0
}


-(void)updateValue:(uint32_t) value forPin:(NSNumber *) pinNumber andIsAnalog:(BOOL) isAnalog{
    //update game here
    if(self.gameMode){
        if(self.gameTimer <= 0){
            [self gameTimeRanOut];
        }else{
            NSTimeInterval interval = [self.prevTime timeIntervalSinceNow];
            self.gameTimer = self.gameTimer - interval;
            self.prevTime = [NSDate date];
        }
    }
    
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
    
    NSNumber *lightNumber = [NSNumber numberWithInt:[pinNumber intValue] + 1];

    if(self.gameMode == false){
        if([self isPullingBand:pinNumber]){
        
            NSNumber *initialReading = [self.initialTubeValues objectAtIndex:[pinNumber intValue]];
        
            int differenceInReading = abs([value intValue] - [initialReading intValue]);
            int newBrightnessValue = (DEFAULT_BRIGHTNESS + differenceInReading)*1.5;
            if (newBrightnessValue > 241){
                newBrightnessValue = 241;
            }
            NSNumber *newBrightness = [NSNumber numberWithInt:newBrightnessValue];
            [self.myHue changeBrightness:newBrightness ofLightNumber:lightNumber];
        }else{
            [self.myHue changeBrightness:[NSNumber numberWithInt:DEFAULT_BRIGHTNESS] ofLightNumber:lightNumber];
        }
    }
    else{
        //reset game only if pulling the tube in teh same direction
        if([self isPullingBand:pinNumber]){
            if((self.gameTimer <=0) &&
              ([pinNumber integerValue] == [self.gameDirectionToPull integerValue])){
                [self resetGame];
            }
        }
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
-(NSArray *)songList
{
    if (!_songList) {
        _songList = @[@"chicken",@"goose",@"horse"];
    }
    return _songList;
}

-(void)updateDigitalPin:(NSNumber *)pinNumber withValue:(BOOL) value{
    if(self.lightIsRed){
        return;
    }
    
    NSNumber *previousState = [self.floorValues objectAtIndex:([pinNumber intValue]-FLOOR_START_PIN)];
    BOOL isPressedAlready = [previousState boolValue];
    if(!isPressedAlready && value){
        [self.myHue changeLightsToRandomColor];
        int soundIndex = arc4random_uniform(NUM_SONGS-1);
        NSString *soundName = [self.songList objectAtIndex:soundIndex];
        [self playSoundWithName:soundName andType:@"mp3"];
    }
    [self.floorValues replaceObjectAtIndex:([pinNumber intValue]-FLOOR_START_PIN) withObject:[NSNumber numberWithBool:value]];
}


-(void)playSoundWithName:(NSString *)songName andType:(NSString *)songType{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:songName ofType:songType]];
    self.songPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_songPlayer setVolume:1.0f];
    [_songPlayer play];
}

@end
