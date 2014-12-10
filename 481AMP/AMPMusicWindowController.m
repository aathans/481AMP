//
//  AMPMusicWindowController.m
//  481AMP
//
//  Created by Alexander Athan on 11/24/14.
//  Copyright (c) 2014 dolo. All rights reserved.
//

#import "AMPMusicWindowController.h"
#import "AMPMusicPlayer.h"
#import "AMPDataManager.h"

@interface AMPMusicWindowController ()

@property (nonatomic) AMPDataManager* dataManager;

@end

@implementation AMPMusicWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.dataManager = [AMPDataManager sharedManager];
    [self updateSongBox:[self.dataManager.musicPlayer getCurrentSong]];
}

- (IBAction)prevSongButton:(id)sender {
    if(![self.dataManager lightIsRed]){
        [self.dataManager.musicPlayer playLastSong];
    }
}

- (IBAction)nextSongButton:(id)sender {
    if(![self.dataManager lightIsRed]){
        [self.dataManager.musicPlayer playNextSong];
    }
}

- (IBAction)playPauseButton:(id)sender {
    if(![self.dataManager lightIsRed]){
        [self.dataManager.musicPlayer toggleMusic];
    }else if(self.pausePlayButton.state == NSOnState){
        self.pausePlayButton.state = NSOffState;
    }else{
        self.pausePlayButton.state = NSOnState;
    }
}

-(void)changeButtonToPause{
    [self.pausePlayButton setState:NSOnState];
}

- (void)updateSongBox:(NSString*)songName{
    NSControl* textField = [self.window.contentView viewWithTag:1];
    [textField setStringValue:songName];
}

@end
