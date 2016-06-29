//
//  NTPocketSphinxConfigArgument.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 28/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "pocketsphinx.h"
#import <Foundation/Foundation.h>

@interface NTPocketSphinxConfigArgument : NSObject

@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, readonly) int type;
@property (nonatomic, strong, readonly) NSString* defaultValue;
@property (nonatomic, strong, readonly) NSString* documentation;

- (instancetype)initWithName:(NSString*)name type:(int)type defaultValue:(NSString*)defaultValue doc:(NSString*)doc;

@end
