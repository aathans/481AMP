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
}

- (IBAction)prevSongButton:(id)sender {
    [self.dataManager.musicPlayer playLastSong];
}

- (IBAction)nextSongButton:(id)sender {
    [self.dataManager.musicPlayer playNextSong];
}

- (IBAction)playPauseButton:(id)sender {
    [self.dataManager.musicPlayer toggleMusic];
}

@end
