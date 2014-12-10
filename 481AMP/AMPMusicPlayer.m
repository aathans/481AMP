//
//  NSObject_AMPMusicPlayer_m.h
//  481AMP
//
//  Created by Alexander Athan on 11/22/14.
//  Copyright (c) 2014 dolo. All rights reserved.
//

#import "AMPMusicPlayer.h"
#import "AMPAppDelegate.h"
#import "AMPMusicWindowController.h"

@interface AMPMusicPlayer()

@property (nonatomic) AMPMusicWindowController* windowController;
@property (nonatomic) AVAudioPlayer *songPlayer;
@property (nonatomic) NSMutableArray *songList;
@property (nonatomic) NSMutableArray *songNames;
@property (nonatomic) int songIndex;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) float currentVolume;

@end


@implementation AMPMusicPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.songIndex = 0;
        self.currentVolume = 0.5f;
        self.isPlaying = true;
    }
    return self;
}

-(void)playSongWithIndex:(NSInteger ) songIndex {
    if (!self.windowController) {
        self.windowController = [NSAppDelegate.mainController getMusicWindowController];
    }
    
    NSURL *songURL = [self.songList objectAtIndex:songIndex];
    NSString *songName = [self.songNames objectAtIndex:songIndex];
    
    self.songPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:nil];
    [self.songPlayer setVolume:_currentVolume];
    [self.songPlayer play];
    
    [self.windowController updateSongBox:songName];
}

-(void)playMusic {
    if (!self.songPlayer) {
        [self playSongWithIndex:0];
    }
    
    if(self.isPlaying){
        return;
    }
    [self.songPlayer play];
    self.isPlaying = true;
}

-(void)pauseMusic {
    if(!self.isPlaying){
        return;
    }
    [self.songPlayer pause];
    self.isPlaying = false;
}

-(void)stopMusic {
    [self.songPlayer stop];
    self.isPlaying = false;
}

-(void)playNextSong {
    self.songIndex++;
    if(self.songIndex >= self.songList.count) {
        self.songIndex = 0;
    }
    [self.songPlayer stop];
    [self playSongWithIndex:self.songIndex];
    self.isPlaying = true;
}

-(void)playPrevSong {
    if(self.songIndex <= 0) {
        self.songIndex = (int)self.songList.count-1;
    } else {
        self.songIndex--;
    }
    [self.songPlayer stop];
    [self playSongWithIndex:self.songIndex];
    self.isPlaying = true;
}

-(void)playLastSong{
    self.songIndex = (int)self.songList.count - 1;
    [self.songPlayer stop];
    [self playSongWithIndex:self.songIndex];
    self.isPlaying = true;
}

-(void)toggleMusic {
    if(self.isPlaying) {
        [self pauseMusic];
    } else {
        [self playMusic];
    }
}

-(NSMutableArray *)songList
{
    if (!_songList) {
        self.songList = [NSMutableArray new];
        NSArray *defaultSongList = @[@"Fireflies", @"Safe and Sound", @"Break Free", @"Happy", @"Under the Sea", @"Proleter"];
        for(NSString *song in defaultSongList){
            [self addSongWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:song ofType:@"mp3"]] andSongName:song];
        }
    }
    return _songList;
}

-(NSMutableArray *)songNames
{
    if(!_songNames){
        _songNames = [NSMutableArray new];
    }
    return _songNames;
}

-(void)addSongWithURL:(NSURL *)songURL andSongName:(NSString *)songName{
    [self.songList addObject:songURL];
    [self.songNames addObject:songName];
}

-(void)startMusic{
    int numSongs = (int)self.songList.count;
    int pickSongIndex = arc4random_uniform(numSongs);
    self.songIndex = pickSongIndex;
    [self playSongWithIndex:self.songIndex];
    
}

-(void)increaseVolume
{
    self.currentVolume += 0.01;
    if (self.currentVolume < 0) {
        self.currentVolume = 0;
    } else if (self.currentVolume >= 1) {
        self.currentVolume = 1.0f;
    }
    [self.songPlayer setVolume:_currentVolume];
}

-(void)decreaseVolume
{
    self.currentVolume -= 0.01;
    if (self.currentVolume <= 0) {
        self.currentVolume = 0;
    } else if (self.currentVolume > 1) {
        self.currentVolume = 1.0f;
    }
    [self.songPlayer setVolume:_currentVolume];
}

-(NSString*)getCurrentSong{
    NSString *songName = [self.songNames objectAtIndex:self.songIndex];
    return songName;
}

-(NSInteger)getNumberOfSongs{
    return self.songList.count;
}

@end
