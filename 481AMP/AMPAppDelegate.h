//
//  ADAppDelegate.h
//  FirmataTestMac
//
//  Created by fiore on 31/10/13.
//  Copyright (c) 2013 Fiore Basile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMPGalileoWindowController.h"
#import "AMPHueWindowController.h"
#include "PHBridgePushLinkViewController.h"
#include "PHBridgeSelectionViewController.h"
#import "AMPMainWindowController.h"
#import <HueSDK_OSX/HueSDK.h>

#define NSAppDelegate  ((AMPAppDelegate *)[[NSApplication sharedApplication] delegate])

@class PHHueSDK;

@interface AMPAppDelegate : NSObject <NSApplicationDelegate, PHBridgePushLinkViewControllerDelegate, PHBridgeSelectionViewControllerDelegate>

@property (assign) IBOutlet NSWindow *window;

//*** GALILEO ***
@property (assign) BOOL connected;
@property (assign) IBOutlet AMPGalileoWindowController *detailController;
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

@property (strong) IBOutlet AMPMainWindowController *mainController;

- (IBAction)connectAction:(id)sender;


@end
