//
//  AMPControlLightsViewController.m
//  481AMP
//
//  Created by Alexander Athan on 10/26/14.
//  Copyright (c) 2014 Fiore Basile. All rights reserved.
//

#import "AMPControlLightsViewController.h"
#import "AMPAppDelegate.h"
#import "AMPDataManager.h"

#define MAX_HUE 65535
#define NUM_LIGHTS 3
#define DEFAULT_HUE 14922
#define DEFAULT_BRIGHTNESS 140
#define DEFAULT_SATURATION 254
#define GREEN_COLOR 26000
#define RED_COLOR 65280


@interface AMPControlLightsViewController ()

@property (nonatomic)NSMutableArray *lightStates;
@property (nonatomic)NSNumber *redLightNumber;

@end

@implementation AMPControlLightsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataManager = [AMPDataManager sharedManager];
        self.dataManager.myHue = self;
        self.dataManager.musicPlayer = [AMPMusicPlayer new];
        self.dataManager.lightIsRed = NO;
        
        self.lightStates = [NSMutableArray new];
        self.redLightNumber = @0;
    }
    return self;
}

- (void)loadView{
    [super loadView];
    [self resetLights];
    
    [self.dataManager.musicPlayer playMusic];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(pauseMusic) withObject:nil afterDelay:5.0f];
    });
}

- (void)resetTube{
    if (self.dataManager.initialTubeValues.count == 0) {
        self.dataManager.initialTubeValues = [NSMutableArray new];
        self.dataManager.currentTubeValues = [NSMutableArray new];     for (int i = 0; i < 4; i++) {
            NSNumber *pinValue = @500;
            [self.dataManager.currentTubeValues addObject:pinValue];
            [self.dataManager.initialTubeValues addObject:pinValue];
        }
    } else {
        for (int i = 0; i < 4; i++) {
            NSNumber *pinValue = @500;
            [self.dataManager.currentTubeValues replaceObjectAtIndex:i withObject:pinValue];
        }
    }
}

- (void)pullTube: (NSNumber *) tubeNumber {
    AMPDataManager* data = self.dataManager;
    
    [self resetTube];
    
    int tubeInt = [tubeNumber intValue];
    NSNumber *pinNum = [NSNumber numberWithInt:(tubeInt-1)];
    NSLog(@"Pulling band");
    [data updateValue:240 forPin:pinNum andIsAnalog:true];
    
    // Wait 3 seconds, then release band
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow: 3.0 ];
    
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    [self resetTube];
}

- (IBAction)resetButtonPushed:(id)sender {
    [self resetLights];
}

- (IBAction)selectOtherBridge:(id)sender{
    [NSAppDelegate searchForBridgeLocal];
}

- (IBAction)light1Pressed:(id)sender {
    [self toggleLightNumber:@1];
}

- (IBAction)light2Pressed:(id)sender {
    [self toggleLightNumber:@2];
}

- (IBAction)light3Pressed:(id)sender {
    [self toggleLightNumber:@3];
}

- (IBAction)light4Pressed:(id)sender {
    [self toggleLightNumber:@4];
}

- (IBAction)pullTube1:(id)sender {
    [self pullTube:@1];
}

- (IBAction)pullTube2:(id)sender {
    [self pullTube:@2];
}
     
- (IBAction)pullTube3:(id)sender {
    [self pullTube:@3];
}

-(void)toggleLightNumber:(NSNumber *)lightNum{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    PHLight *light = [cache.lights objectForKey:[lightNum stringValue]];
    
    PHLightState *lightState = [self.lightStates objectAtIndex:[lightNum intValue]-1];
    
    if([lightState.on  isEqual: @YES]){
        lightState.on = @NO;
    }else{
        
        lightState.on = @YES;
    }
    
    [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
        if (errors != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
            NSLog(@"Response: %@",message);
        }
    }];
    
}

-(void)pauseMusic{
    self.redLightNumber = @1;//[NSNumber numberWithInt:arc4random_uniform(NUM_LIGHTS-1)+1];
    [self changeHue:[NSNumber numberWithInt:RED_COLOR] ofLightNumber:self.redLightNumber];
    self.dataManager.lightIsRed = YES;
    [self.dataManager.musicPlayer pauseMusic];
}

- (void)changeLightsToRandomColor{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    NSUInteger count = cache.lights.count;
    
    for (int i = 1; i <= count; i++) {
        [self changeHue:[NSNumber numberWithInt:arc4random() % MAX_HUE] ofLightNumber:[NSNumber numberWithInt:i]];
    }
}

- (void)resetLights{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    [self.lightStates removeAllObjects];
    
    for (PHLight *light in cache.lights.allValues) {
        PHLightState *lightState = [[PHLightState alloc] init];
        [lightState setHue:[NSNumber numberWithInt:DEFAULT_HUE]];
        [lightState setBrightness:[NSNumber numberWithInt:DEFAULT_BRIGHTNESS]];
        [lightState setSaturation:[NSNumber numberWithInt:DEFAULT_SATURATION]];
        [self.lightStates addObject:lightState];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                NSLog(@"Response: %@",message);
            }
        }];
    }
}

- (void)changeBrightness:(NSNumber *)newBrightness ofLightNumber:(NSNumber *)lightNum{
    
    if([lightNum isEqualToNumber:self.redLightNumber] && ([newBrightness intValue] != DEFAULT_BRIGHTNESS)){
        [self changeHue:[NSNumber numberWithInt:GREEN_COLOR] ofLightNumber:lightNum];
        self.redLightNumber = @0;
        self.dataManager.lightIsRed = NO;
        [self.dataManager.musicPlayer playMusic];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(pauseMusic) withObject:nil afterDelay:5.0f];
        });
        return;
    }
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    PHLight *light = [cache.lights objectForKey:[lightNum stringValue]];
    PHLightState *lightState = [self.lightStates objectAtIndex:[lightNum intValue]-1];
    
    [lightState setBrightness:newBrightness];
    
    [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
        if (errors != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
            NSLog(@"Response: %@",message);
        }
    }];
}

-(void)changeHue:(NSNumber *)newHue ofLightNumber:(NSNumber *)lightNum{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    PHLight *light = [cache.lights objectForKey:[lightNum stringValue]];
    PHLightState *lightState = [self.lightStates objectAtIndex:[lightNum intValue]-1];
    
    [lightState setHue:newHue];
    
    [self.lightStates replaceObjectAtIndex:[lightNum intValue]-1 withObject:lightState];
    
    [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
        if (errors != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
            NSLog(@"Response: %@",message);
        }
    }];
}

@end