//
//  AMPBandTest.m
//  481AMP
//
//  Created by Brandon Mazzara on 11/22/14.
//  Copyright (c) 2014 dolo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMPDataManager.h"

@interface AMPTubeTest : XCTestCase

@end

@implementation AMPTubeTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)pullBand:(NSNumber *) pinNum
{
    AMPDataManager* data = [AMPDataManager sharedManager];
    
    NSLog(@"Pulling band");
    [data updateValue:220 forPin:pinNum andIsAnalog:true];
    
    // Wait 3 seconds, then release band
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow: 3.0 ];
    
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    [data updateValue:310 forPin:pinNum andIsAnalog:true];
}

- (void)testTube
{
    for(int i = 0; i < 3; i++) {
        NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow: 3.0 ];
        
        [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
        
        [self pullBand:[NSNumber numberWithInt:i]];
    }
}

@end