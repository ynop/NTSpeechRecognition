//
//  NTPocketSphinxConfiguration.m
//  NTSpeechRecognizer
//
//  Created by Matthias Büchi on 21/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTPocketSphinxConfig.h"
#import "pocketsphinx.h"

@interface NTPocketSphinxConfig ()

@property (nonatomic) cmd_ln_t* config;

@end

@implementation NTPocketSphinxConfig

- (instancetype)initWithOptions:(NSDictionary<NSString*, NSString*>*)options
{
    self = [super init];
    if (self) {
        self.config = cmd_ln_init(NULL, ps_args(), TRUE, NULL);
    }
    return self;
}

#pragma mark - Generic Access
- (void)setOptions:(NSDictionary<NSString*, NSString*>*)options
{
    for (NSString* option in options.allKeys) {
        [self setValue:options[option] forKey:option];
    }
}

- (NSString*)getOptionWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    const char* value = cmd_ln_str_r(self.config, cName);

    if (value == NULL) {
        return nil;
    }

    return [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
}

- (void)setValue:(NSString*)value forOptionWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cValue = [name cStringUsingEncoding:NSUTF8StringEncoding];

    cmd_ln_set_str_r(self.config, cName, cValue);
}

#pragma mark - Convenience Constructor
+ (NTPocketSphinxConfig*)configWithOptions:(NSDictionary<NSString*, NSString*>*)options
{
    return [[NTPocketSphinxConfig alloc] initWithOptions:options];
}

+ (NTPocketSphinxConfig*)configWithPathToAcousticModel:(NSString*)path
{
    return [NTPocketSphinxConfig configWithOptions:@{ @"-hmm" : path }];
}

@end
