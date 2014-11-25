//
//  NSObject_AMPMusicPlayer_m.h
//  481AMP
//
//  Created by Alexander Athan on 11/22/14.
//  Copyright (c) 2014 dolo. All rights reserved.
//

#import "AMPMusicPlayer.h"

@interface AMPMusicPlayer()

@property (nonatomic) AVAudioPlayer *songPlayer;
@property (nonatomic) NSArray *songList;
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
    }
    return self;
}

-(void)playSongWithName:(NSString *)song {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:song ofType:@"mp3"]];
    self.songPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.songPlayer setVolume:_currentVolume];
    [self.songPlayer play];
    NSLog(@"playing music");
}

-(void)playMusic {
    if (!self.songPlayer) {
        NSString *title = [self.songList firstObject];
        [self playSongWithName:title];
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
    if(self.songIndex >= 16) {
        self.songIndex = 0;
    }
    [self.songPlayer stop];
    [self playSongWithName:[self.songList objectAtIndex:self.songIndex]];
    self.isPlaying = true;
}

-(void)playLastSong {
    if(self.songIndex <= 0) {
        self.songIndex = 16;
    } else {
        self.songIndex--;
    }
    [self.songPlayer stop];
    [self playSongWithName:[self.songList objectAtIndex:self.songIndex]];
    self.isPlaying = true;
}

-(void)toggleMusic {
    if(self.isPlaying) {
        [self pauseMusic];
    } else {
        [self playMusic];
    }
}

-(NSArray *)songList
{
    if (!_songList) {
        _songList = @[@"Fireflies", @"SafeAndSound", @"BreakFree", @"Happy", @"UnderTheSea", @"Proleter"];
    }
    return _songList;
}

-(void)startMusic{
    NSInteger size = self.songList.count;
    int pickSongIndex = arc4random()%size;
    NSString *songName = [self.songList objectAtIndex:pickSongIndex];
    [self playSongWithName:songName];
    
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
//
//-(void)adjustVolumeWithRotation:(int)rotation
//{
//    BOOL shouldIncrease = rotation > 30;
//    BOOL shouldDecrease = rotation < -30;
//    
//    if (shouldIncrease) {
//        [self.volumeDecreaseTimer invalidate];
//        self.volumeIncreaseTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(increaseVolume) userInfo:nil repeats:NO];
//        [self.volumeIncreaseTimer fire];
//    } else if (shouldDecrease) {
//        [self.volumeIncreaseTimer invalidate];
//        self.volumeDecreaseTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(decreaseVolume) userInfo:nil repeats:NO];
//        [self.volumeDecreaseTimer fire];
//    }
//    
//}

@end
