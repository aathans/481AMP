//
//  AMPSoundTest.m
//  481AMP
//
//  Created by Alexander Athan on 11/7/14.
//  Copyright (c) 2014 dolo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>

@interface AMPSoundTest : XCTestCase

@end

@implementation AMPSoundTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSLog(@"BYYE");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testSpeaker{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"snare" ofType:@"mp3"]];
    AVAudioPlayer *songPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [songPlayer setVolume:0.7f];
    BOOL didPlaySong = [songPlayer play];
    XCTAssertEqual(didPlaySong, true, @"Failed to play song");
}

@end
