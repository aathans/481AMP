//
//  AMPMusicPlayer.h
//  481AMP
//
//  Created by Alexander Athan on 11/22/14.
//  Copyright (c) 2014 dolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AMPMusicPlayer : NSObject

@property (nonatomic) NSTimer *volumeIncreaseTimer;
@property (nonatomic) NSTimer *volumeDecreaseTimer;

-(void)stopMusic;
-(void)playMusic;
-(void)pauseMusic;
-(void)toggleMusic;
-(void)playNextSong;
-(void)playPrevSong;
-(void)startMusic;
-(void)playLastSong;
-(void)adjustVolumeWithRotation:(int)rotation;
-(NSInteger)getNumberOfSongs;
-(NSString*)getCurrentSong;

-(void)addSongWithURL:(NSURL *)songURL andSongName:(NSString *)songName;


@end
