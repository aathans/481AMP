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
#define DEFAULT_BRIGHTNESS 140

@interface AMPControlLightsViewController ()

@property (nonatomic,weak) IBOutlet NSTextField *bridgeMacLabel;
@property (nonatomic,weak) IBOutlet NSTextField *bridgeIpLabel;
@property (nonatomic,weak) IBOutlet NSTextField *bridgeLastHeartbeatLabel;
@property (weak) IBOutlet NSButton *light1Button;

@end

@implementation AMPControlLightsViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataManager = [AMPDataManager sharedManager];
        self.dataManager.myHue = self;
    }
    return self;
}
- (void)loadView{
    [super loadView];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    
    // Register for the local heartbeat notifications
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    
    [self noLocalConnection];
}
- (void)localConnection{
    [self loadConnectedBridgeValues];
}
- (void)noLocalConnection{
    self.bridgeLastHeartbeatLabel.stringValue = NSLocalizedString(@"Not connected", @"");
    [self.bridgeLastHeartbeatLabel setEnabled:NO];
    self.bridgeIpLabel.stringValue = NSLocalizedString(@"Not connected", @"");
    [self.bridgeIpLabel setEnabled:NO];
    self.bridgeMacLabel.stringValue = NSLocalizedString(@"Not connected", @"");
    [self.bridgeMacLabel setEnabled:NO];
}
- (void)loadConnectedBridgeValues{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    // Check if we have connected to a bridge before
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil){
        // Set the ip address of the bridge
        self.bridgeIpLabel.stringValue = cache.bridgeConfiguration.ipaddress;
        // Set the mac adress of the bridge
        self.bridgeMacLabel.stringValue = cache.bridgeConfiguration.mac;
        // Check if we are connected to the bridge right now
        if (NSAppDelegate.phHueSDK.localConnected) {
            // Show current time as last successful heartbeat time when we are connected to a bridge
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            self.bridgeLastHeartbeatLabel.stringValue = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
            //[self.randomLightsButton setEnabled:YES];
        } else {
            self.bridgeLastHeartbeatLabel.stringValue = NSLocalizedString(@"Waiting...", @"");
            //[self.randomLightsButton setEnabled:NO];
        }
    }
}

- (IBAction)selectOtherBridge:(id)sender{
    [NSAppDelegate searchForBridgeLocal];
}

- (IBAction)light1Pressed:(id)sender {
    [self toggleLightNumber:@1];
}

- (IBAction)light2Pressed:(id)sender {
    [self toggleLightNumber:@1];
}

- (IBAction)light3Pressed:(id)sender {
    [self toggleLightNumber:@1];
}

- (IBAction)light4Pressed:(id)sender {
    [self toggleLightNumber:@1];
}

-(void)toggleLightNumber:(NSNumber *)lightNum{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    PHLight *light = [cache.lights objectForKey:[lightNum stringValue]];
    
    PHLightState *lightState = light.lightState;
    
    if([lightState on]){
        [lightState setOn:[NSNumber numberWithBool:NO]];
    }else{
        [lightState setOn:[NSNumber numberWithBool:YES]];
    }
    
    [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
        if (errors != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
            NSLog(@"Response: %@",message);
        }
    }];
    
}

- (void)changeLightsToRandomColor{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    PHLightState *lightState = [[PHLightState alloc] init];
    [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
        
    for (PHLight *light in cache.lights.allValues) {
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                NSLog(@"Response: %@",message);
            }
        }];
    }
    
}

- (void)resetLights{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    PHLightState *lightState = [[PHLightState alloc] init];
    [lightState setHue:[NSNumber numberWithInt:14922]];
    [lightState setBrightness:[NSNumber numberWithInt:254]];
    [lightState setSaturation:[NSNumber numberWithInt:144]];
    
    for (PHLight *light in cache.lights.allValues) {
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
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    PHLight *light = [cache.lights objectForKey:[lightNum stringValue]];
    PHLightState *lightState = light.lightState;
    
    [lightState setBrightness:newBrightness];
    
    [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
        if (errors != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
            NSLog(@"Response: %@",message);
        }
    }];
}

@end