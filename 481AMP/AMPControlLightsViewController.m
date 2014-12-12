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
#define NUM_LIGHTS 4

#define DEFAULT_HUE 14922
#define DEFAULT_BRIGHTNESS 140
#define DEFAULT_SATURATION 254

#define GREEN_COLOR 26000
#define RED_COLOR 65280
#define BLUE_COLOR 46920
#define YELLOW_COLOR 12750
#define PURPLE_COLOR 56100

#define INTERRUPT_TIME 15.0f

int stopColor = RED_COLOR;

@interface AMPControlLightsViewController ()

@property (nonatomic)NSMutableArray *lightStates;
@property (nonatomic)NSMutableArray *previousStates;
@property (nonatomic)NSNumber *redLightNumber;
@property (weak) IBOutlet NSTextField *stoppedLabel;

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
        self.previousStates = [NSMutableArray new];
        self.redLightNumber = @0;
        
        [self resetLights];
        [self.dataManager.musicPlayer startMusic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(pauseMusic) withObject:nil afterDelay:INTERRUPT_TIME];
        });
    }
    return self;
}

- (void)loadView{
    [super loadView];

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

- (IBAction)changeBrightnessButton:(id)sender {
    NSInteger tag = ((NSSlider*)sender).tag;
    double sliderVal = [(NSSlider*)sender doubleValue];
    
    [self changeBrightness:sliderVal ofLightNumber:[NSNumber numberWithInteger:tag]];
}

- (IBAction)overrideStop:(id)sender {
    if(![self.redLightNumber isEqualToNumber:@0]){
        [self incrementHueBy:0 ofLightNumber:self.redLightNumber];
    }
}

- (IBAction)randomizeLightsButton:(id)sender {
    [self changeLightsToRandomColor];
}

- (IBAction)changeStopColor:(id)sender {
    NSInteger clickedSegment = [sender selectedSegment];
    NSString * segmentLabel = [sender labelForSegment:clickedSegment];
    if ([segmentLabel isEqualToString:@"Red"]) {
        stopColor = RED_COLOR;
    } else if ([segmentLabel isEqualToString:@"Blue"]) {
        stopColor = BLUE_COLOR;
    } else if ([segmentLabel isEqualToString:@"Yellow"]) {
        stopColor = YELLOW_COLOR;
    } else if ([segmentLabel isEqualToString:@"Purple"]) {
        stopColor = PURPLE_COLOR;
    }
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
    NSUInteger count = self.lightStates.count;
    self.redLightNumber = [NSNumber numberWithInt:arc4random_uniform(NUM_LIGHTS-1)+1];
    
    self.dataManager.lightIsRed = YES;
    self.stoppedLabel.hidden = NO;
    [self.dataManager.musicPlayer pauseMusic];
    
    // Save current light states
    [self.previousStates removeAllObjects];
    NSArray *trueDeepCopyArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.lightStates]];
    self.previousStates = [NSMutableArray arrayWithArray:trueDeepCopyArray];
    
    // Change one light to red, the rest to green
    for (int i = 1; i <= count; i++) {
        PHLightState *lightState = [self.lightStates objectAtIndex:i-1];
        [lightState setBrightness:[NSNumber numberWithInt:DEFAULT_BRIGHTNESS]];
        if (self.redLightNumber != [NSNumber numberWithInt:i]) {
            [self changeHue:[NSNumber numberWithInt:GREEN_COLOR] ofLightNumber:[NSNumber numberWithInt:i]];
        }else{
            [self changeHue:[NSNumber numberWithInt:stopColor] ofLightNumber:self.redLightNumber];
        }
    }
    
}

- (void)restoreLights{
    // Restore all light states to their previous versions
    for(int i = 0; i < NUM_LIGHTS; i++) {
        NSNumber *lightNum = [NSNumber numberWithInt:(i+1)];
        PHLightState *lightState = [self.previousStates objectAtIndex:i];
        
        [self changeLightState:lightState ofLightNum:lightNum];
    }
}


- (void)changeLightsToRandomColor{
    if (self.dataManager.lightIsRed == NO) {
        PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
        NSUInteger count = cache.lights.count;
    
        for (int i = 1; i <= count; i++) {
            [self changeHue:[NSNumber numberWithInt:arc4random() % MAX_HUE] ofLightNumber:[NSNumber numberWithInt:i]];
        }
    }
}

- (void)resetLights{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    [self.lightStates removeAllObjects];
    
    for (PHLight *light in cache.lights.allValues) {
        PHLightState *lightState = [[PHLightState alloc] init];
        [lightState setOnBool:YES];
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
    
    self.dataManager.lightIsRed = NO;
}


-(void)changeHue:(NSNumber *)newHue ofLightNumber:(NSNumber *)lightNum{
    PHLightState *lightState = [self.lightStates objectAtIndex:[lightNum intValue]-1];
    
    [lightState setHue:newHue];
    
    [self changeLightState:lightState ofLightNum:lightNum];
}

-(void)changeBrightness:(double) percentage ofLightNumber:(NSNumber *)lightNum{
    PHLightState *lightState = [self.lightStates objectAtIndex:[lightNum intValue]-1];
    
    NSNumber *newBrightness = [NSNumber numberWithInt:255 * (percentage * .01)];
    [lightState setBrightness:newBrightness];
    
    [self changeLightState:lightState ofLightNum:lightNum];
}

-(void)incrementHueBy:(int) incrementValue ofLightNumber:(NSNumber *)lightNum{
    if([lightNum isEqualToNumber:self.redLightNumber]){
        [self changeHue:[NSNumber numberWithInt:GREEN_COLOR] ofLightNumber:lightNum];
        self.redLightNumber = @0;
        self.dataManager.lightIsRed = NO;
        self.stoppedLabel.hidden = YES;
        [self.dataManager.musicPlayer playMusic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(restoreLights) withObject:nil afterDelay:1.0f];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(pauseMusic) withObject:nil afterDelay:INTERRUPT_TIME];
        });
        return;
    }else if(self.dataManager.lightIsRed){
        return;
    }
    
    PHLightState *lightState = [self.lightStates objectAtIndex:[lightNum intValue]-1];
    int oldHue = [lightState.hue intValue];
    int newHueValue = (oldHue + incrementValue) % MAX_HUE;
    
    NSNumber *newHue = [NSNumber numberWithInt:newHueValue];
    [lightState setHue:newHue];
    [self changeLightState:lightState ofLightNum:lightNum];
}

-(void)changeLightState:(PHLightState*)newState ofLightNum:(NSNumber *)lightNum{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    PHLight *light = [cache.lights objectForKey:[lightNum stringValue]];
    
    [self.lightStates replaceObjectAtIndex:[lightNum intValue]-1 withObject:newState];
    
    [bridgeSendAPI updateLightStateForId:light.identifier withLightState:newState completionHandler:^(NSArray *errors) {
        if (errors != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
            NSLog(@"Response: %@",message);
        }
    }];
}

@end