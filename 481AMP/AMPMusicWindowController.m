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
@property (unsafe_unretained) IBOutlet NSTextView *songTitle;

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
        [self.dataManager.musicPlayer playPrevSong];
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
- (IBAction)addSongButton:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"mp3"]];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            if([[url pathExtension] isEqualToString:@"mp3"]){
                NSString *songName = [[[url path] lastPathComponent] stringByDeletingPathExtension];
                [self.dataManager.musicPlayer addSongWithURL:url andSongName:songName];
                [self.dataManager.musicPlayer playPrevSong];
                [self.dataManager.musicPlayer playLastSong];
            }
        }
    }
}

-(void)changeButtonToPause{
    [self.pausePlayButton setState:NSOnState];
}

- (void)updateSongBox:(NSString*)songName{
    [self.songTitle setAlignment:NSCenterTextAlignment];
    [self.songTitle setString:songName];
}

@end
