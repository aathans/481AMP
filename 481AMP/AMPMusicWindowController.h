//
//  AMPMusicWindowController.h
//  481AMP
//
//  Created by Alexander Athan on 11/24/14.
//  Copyright (c) 2014 dolo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMPMusicWindowController : NSWindowController
@property (weak) IBOutlet NSButton *pausePlayButton;

-(void)changeButtonToPause;
-(void)updateSongBox:(NSString*)songName;


@end
