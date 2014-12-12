//
//  ADDetailWindowController.m
//  FirmataTestMac
//
//  Created by fiore on 31/10/13.
//  Copyright (c) 2013 Fiore Basile. All rights reserved.
//

#import "AMPGalileoWindowController.h"
#import "ADArduinoPin.h"
#import "ADFirmataConst.h"

@interface AMPGalileoWindowController ()

@end

#define NUM_TUBE_PINS 4
#define NUM_FLOOR_PINS 1
#define FLOOR_START_PIN 7

@implementation AMPGalileoWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.

    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


-(void)showWindow:(id)sender {
    self.stopRefresh = NO;
    //[super showWindow:sender];
    self.dataManager = [AMPDataManager sharedManager];
    self.dataManager.initialTubeValues = [NSMutableArray new];
    self.dataManager.currentMaxTubeValues = [NSMutableArray new];
    self.dataManager.floorValues = [NSMutableArray new];
    
    [self initArduino];
}

- (void) initArduino {
    
    __block ADArduino* _warduino = self.arduino;
    [self.arduino connectWithBlock:^{
        
        NSLog(@"Arduino connected");
        NSLog(@"Arduino Firmata version %@ %@",[_warduino firmataVersion], [_warduino firmataVersionString]);
        
        NSLog(@"Analog pins %@", _warduino.analogPins);
        NSLog(@"Digital pins %@", _warduino.digitalPins);
        
        //**** GET INITIAL PIN VALUE ***
        for (int i = 0; i < NUM_TUBE_PINS; i++) {
            ADArduinoPin *analogPin = [self.arduino.analogPins objectAtIndex:i];
            NSNumber *pinValue = [NSNumber numberWithInt:analogPin.value];
            [self.dataManager.currentMaxTubeValues addObject:pinValue];
            [self.dataManager.initialTubeValues addObject:pinValue];
        }
        
        for (int i = FLOOR_START_PIN; i < FLOOR_START_PIN + NUM_FLOOR_PINS; i++) {
            ADArduinoPin *digitalPin = [self.arduino.digitalPins objectAtIndex:i];
            NSNumber *pinValue = [NSNumber numberWithInt:digitalPin.value];
            [self.dataManager.floorValues addObject:pinValue];
        }
    
        [self setup];
    }];
}


- (void)setup {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
    ADArduinoPin *floorPin = [self.arduino.digitalPins objectAtIndex:FLOOR_START_PIN];
    [floorPin setMode:MODE_INPUT];
    NSLog(@"Analog pins %@", self.arduino.analogPins);
    NSLog(@"Digital pins %@", self.arduino.digitalPins);
}


- (void)refresh:(NSTimer*)timer {
    for(unsigned int i = 0; i < NUM_TUBE_PINS; i++){
        ADArduinoPin *analogPin = [self.arduino.analogPins objectAtIndex:i];
        [self.dataManager updateValue:analogPin.value forPin:[NSNumber numberWithInt:i] andIsAnalog:YES];
    }
    
    for(unsigned int i = FLOOR_START_PIN; i < FLOOR_START_PIN + NUM_FLOOR_PINS; i++){
        ADArduinoPin *digitalPin = [self.arduino.digitalPins objectAtIndex:i];
        [self.dataManager updateValue:digitalPin.value forPin:[NSNumber numberWithInt:i] andIsAnalog:NO];
    }
    NSLog(@"Analog pins %@", self.arduino.analogPins);
    NSLog(@"Digital pins %@", self.arduino.digitalPins);
}

-(void)close {
    [self.timer invalidate];
    self.stopRefresh = YES;
    [super close];
    
}
@end
