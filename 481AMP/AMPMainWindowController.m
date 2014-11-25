//
//  AMPMainWindowController.m
//  481AMP
//
//  Created by Alexander Athan on 11/23/14.
//  Copyright (c) 2014 dolo. All rights reserved.
//

#import "AMPMainWindowController.h"
#import "AMPHueWindowController.h"
#import "AMPControlLightsViewController.h"
#import "AMPMusicWindowController.h"

@interface AMPMainWindowController ()

@property(nonatomic)AMPHueWindowController *hueWC;
@property(nonatomic)AMPControlLightsViewController *controlLightsVC;
@property(nonatomic)AMPDataManager *dataManager;
@property(nonatomic)AMPMusicWindowController *musicWC;

@end

@implementation AMPMainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.dataManager = [AMPDataManager sharedManager];
    self.hueWC = [[AMPHueWindowController alloc] initWithWindowNibName:@"AMPHueWindow"];
    self.controlLightsVC = [[AMPControlLightsViewController alloc] initWithNibName:@"AMPControlLightsViewController" bundle:[NSBundle mainBundle]];
    self.musicWC = [[AMPMusicWindowController alloc] initWithWindowNibName:@"AMPMusicWindowController"];
    self.dataManager.mainWC = self;
}
- (IBAction)lightOptionsPushed:(id)sender {
    self.controlLightsVC.view.frame = ((NSView *)self.hueWC.window.contentView).bounds;
    self.hueWC.window.contentView = self.controlLightsVC.view;
    [self.hueWC showWindow:self];
}

- (IBAction)musicOptionsPushed:(id)sender {
    [self.musicWC showWindow:self];
}

-(void)redLightWasSet{
    [self.musicWC changeButtonToPause];
}

@end
