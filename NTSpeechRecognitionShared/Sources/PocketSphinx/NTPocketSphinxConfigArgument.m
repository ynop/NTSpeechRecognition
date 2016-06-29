//
//  NTPocketSphinxConfigArgument.m
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 28/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTPocketSphinxConfigArgument.h"

@implementation NTPocketSphinxConfigArgument

- (instancetype)initWithName:(NSString*)name type:(int)type defaultValue:(NSString*)defaultValue doc:(NSString*)doc
{
    self = [super init];
    if (self) {
        _name = name;
        _type = type;
        _defaultValue = defaultValue;
        _documentation = doc;
    }
    return self;
}

@end
