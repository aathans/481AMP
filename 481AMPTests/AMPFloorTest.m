//
//  AMPValueTest.m
//  481AMP
//
//  Created by Brandon Mazzara on 11/22/14.
//  Copyright (c) 2014 dolo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMPDataManager.h"

@interface AMPFloorTest : XCTestCase

@end

@implementation AMPFloorTest

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

- (void)stepOnFloor:(NSNumber *) pinNum
{
    AMPDataManager* data = [AMPDataManager sharedManager];
    
    NSLog(@"Stepping on floor");
    [data updateValue:1 forPin:pinNum andIsAnalog:false];
    [data updateValue:0 forPin:pinNum andIsAnalog:false];
}

- (void)testFloor
{
    for(int i = 0; i < 4; i++) {
        NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow: 3.0 ];
        
        [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
        
        [self stepOnFloor:[NSNumber numberWithInt:i]];
    }
}

@end