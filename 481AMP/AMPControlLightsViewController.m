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
#import "AMPMusicPlayer.h"

#define MAX_HUE 65535
#define NUM_LIGHTS 3
#define DEFAULT_BRIGHTNESS 140
#define GREEN_COLOR 36210
#define RED_COLOR 65280

@interface AMPControlLightsViewController ()

@property (nonatomic)AMPMusicPlayer *myMusicPlayer;
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
        self.myMusicPlayer = [AMPMusicPlayer new];
        self.lightStates = [NSMutableArray new];
        self.redLightNumber = @0;
    }
    return self;
}

- (void)loadView{
    [super loadView];
    [self resetLights];
    [self.myMusicPlayer playMusic];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(toggleMusic) withObject:nil afterDelay:5.0f];
    });
    //[self.myMusicPlayer playMusic];
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

- (IBAction)pullBand:(id)sender {
    
    for(int i = 0; i < 5; i++) {
        [self changeLightsToRandomColor];
        NSLog(@"Pulling band");
        NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow: 3.0 ];
        [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
        
        [self changeBrightness:@50 ofLightNumber:@1];
        
        // Wait 3 seconds, then release band
        runUntil = [NSDate dateWithTimeIntervalSinceNow: 3.0 ];
        [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
        
        [self changeBrightness:@250 ofLightNumber:@1];
        
        runUntil = [NSDate dateWithTimeIntervalSinceNow: 3.0 ];
        [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    }
    
      //[data updateValue:310 forPin:@0 andIsAnalog:true];
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

-(void)toggleMusic{
    //self.redLightNumber = [NSNumber numberWithInt:arc4random_uniform(2)+1];
    self.redLightNumber = @1;
    [self changeHue:[NSNumber numberWithInt:RED_COLOR] ofLightNumber:self.redLightNumber];
    [self.myMusicPlayer pauseMusic];
}

- (void)changeLightsToRandomColor{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
  //  PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
   /*PHLightState *lightState = [[PHLightState alloc] init];
    [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];*/
    NSUInteger count = cache.lights.count;
    for (int i = 1; i < count+1; i++) {
        // Send lightstate to light
        [self changeHue:[NSNumber numberWithInt:arc4random() % MAX_HUE] ofLightNumber:[NSNumber numberWithInt:i]];
     /*  [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                NSLog(@"Response: %@",message);
            }
        }];*/
    }
    
}

- (void)resetLights{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    [self.lightStates removeAllObjects];
    
    for (PHLight *light in cache.lights.allValues) {
        PHLightState *lightState = [[PHLightState alloc] init];
        [lightState setHue:[NSNumber numberWithInt:14922]];
        [lightState setBrightness:[NSNumber numberWithInt:DEFAULT_BRIGHTNESS]];
        [lightState setSaturation:[NSNumber numberWithInt:200]];
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
    
    if([lightNum isEqualToNumber:self.redLightNumber]){
        [self changeHue:[NSNumber numberWithInt:GREEN_COLOR] ofLightNumber:lightNum];
        self.redLightNumber = @0;
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
    
    [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
        if (errors != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
            NSLog(@"Response: %@",message);
        }
    }];
}

@end