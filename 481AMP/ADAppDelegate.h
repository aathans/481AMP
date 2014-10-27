//
//  ADAppDelegate.h
//  FirmataTestMac
//
//  Created by fiore on 31/10/13.
//  Copyright (c) 2013 Fiore Basile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADDetailWindowController.h"
#include "PHBridgePushLinkViewController.h"
#include "PHBridgeSelectionViewController.h"
#import <HueSDK_OSX/HueSDK.h>

#define NSAppDelegate  ((ADAppDelegate *)[[NSApplication sharedApplication] delegate])

@class PHHueSDK;

@interface ADAppDelegate : NSObject <NSApplicationDelegate, PHBridgePushLinkViewControllerDelegate, PHBridgeSelectionViewControllerDelegate>

@property (assign) IBOutlet NSWindow *window;

//*** GALILEO ***
@property (assign) BOOL connected;
@property (assign) IBOutlet ADDetailWindowController *detailController;
@property (assign) IBOutlet NSComboBox* serialPortsCombo;
@property (assign) IBOutlet NSComboBox* serialBaudCombo;
@property (assign) IBOutlet NSButton* connectButton;
@property (assign) IBOutlet NSTextField* rxLabel;
@property (assign) IBOutlet NSTextField* txLabel;
//***************

//*** PHILIPS HUE ***
@property (nonatomic) PHHueSDK *phHueSDK;

-(void)enableLocalHeartbeat;

-(void)disableLocalHeartbeat;

-(void)searchForBridgeLocal;

//***************


- (IBAction)connectAction:(id)sender;


@end
