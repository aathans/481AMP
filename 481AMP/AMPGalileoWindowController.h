//
//  ADDetailWindowController.h
//  FirmataTestMac
//
//  Created by fiore on 31/10/13.
//  Copyright (c) 2013 Fiore Basile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADArduino.h"
#import "AMPDataManager.h"

@interface AMPGalileoWindowController : NSWindowController


@property (strong) ADArduino* arduino;
@property (assign) BOOL stopRefresh;
@property (assign) NSTimer* timer;

@property (nonatomic) AMPDataManager *dataManager;

@end
