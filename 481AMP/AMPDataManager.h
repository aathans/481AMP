//
//  AMPDataModel.h
//  481AMP
//
//  Created by Alexander Athan on 10/27/14.
//  Copyright (c) 2014 Fiore Basile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMPDataManager : NSObject

@property (nonatomic) int readValue;

+(id)sharedManager;

@end


