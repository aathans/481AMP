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
-(void)playLastSong;
-(void)startMusic;
-(void)adjustVolumeWithRotation:(int)rotation;

@end
