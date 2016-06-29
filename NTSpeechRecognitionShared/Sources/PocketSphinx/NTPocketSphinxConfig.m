//
//  NTPocketSphinxConfiguration.m
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 21/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTPocketSphinxConfig.h"
#import "NTPocketSphinxConfigArgument.h"
#import "pocketsphinx.h"

@interface NTPocketSphinxConfig ()

@property (nonatomic) cmd_ln_t* config;

@property (nonatomic, strong) NSMutableDictionary<NSString*, NTPocketSphinxConfigArgument*>* arguments;

@end

@implementation NTPocketSphinxConfig

- (instancetype)init
{
    return [self initWithOptions:@{}];
}

- (instancetype)initWithOptions:(NSDictionary<NSString*, NSString*>*)options
{
    self = [super init];
    if (self) {
        arg_t const* args = ps_args();

        [self loadArguments:args];

        self.config = cmd_ln_init(NULL, args, TRUE, NULL);

        [self setOptions:options];
    }
    return self;
}

- (void)dealloc
{
    cmd_ln_free_r(self.config);
}

- (void)loadArguments:(arg_t const*)ps_args
{
    self.arguments = [NSMutableDictionary dictionary];

    BOOL isLast = NO;
    NSInteger i = 0;

    while (!isLast) {
        arg_t argument = ps_args[i];

        if (argument.name == NULL) {
            isLast = YES;
        }
        else {
            NSString* name = nil;
            NSString* defaultValue = nil;
            NSString* doc = nil;

            if (argument.name != NULL) {
                name = [NSString stringWithCString:argument.name encoding:NSUTF8StringEncoding];
            }
            if (argument.deflt != NULL) {
                defaultValue = [NSString stringWithCString:argument.deflt encoding:NSUTF8StringEncoding];
            }

            if (argument.doc != NULL) {
                doc = [NSString stringWithCString:argument.doc encoding:NSUTF8StringEncoding];
            }

            if (name) {
                NTPocketSphinxConfigArgument* arg = [[NTPocketSphinxConfigArgument alloc] initWithName:name type:argument.type defaultValue:defaultValue doc:doc];
                self.arguments[name] = arg;
            }
        }

        i++;
    }
}

- (void*)ps_config
{
    return self.config;
}

#pragma mark - Generic Access
- (void)setOptions:(NSDictionary<NSString*, NSString*>*)options
{
    for (NSString* option in options.allKeys) {
        [self setValue:options[option] forOptionWithName:option];
    }
}

- (NSObject*)getOptionWithName:(NSString*)name
{
    NTPocketSphinxConfigArgument* argument = self.arguments[name];

    if (argument) {
        if (argument.type & ARG_INTEGER) {
            return @([self getIntOptionWithName:name]);
        }
        else if (argument.type & ARG_FLOATING) {
            return @([self getFloatOptionWithName:name]);
        }
        else if (argument.type & ARG_STRING) {
            return [self getStringOptionWithName:name];
        }
        else if (argument.type & ARG_STRING_LIST) {
            return [self getStringListOptionWithName:name];
        }
    }
    else {
        NSLog(@"No config argument named %@ existsing.", name);
    }

    return nil;
}

- (NSString*)getStringOptionWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    const char* value = cmd_ln_str_r(self.config, cName);

    if (value == NULL) {
        return nil;
    }

    return [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
}

- (NSArray<NSString*>*)getStringListOptionWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    const char** value = cmd_ln_str_list_r(self.config, cName);

    if (value == NULL) {
        return nil;
    }

    const char* currentValue = value[0];
    int i = 0;
    NSMutableArray* strings = [NSMutableArray array];

    while (currentValue != NULL) {
        [strings addObject:[NSString stringWithCString:currentValue encoding:NSUTF8StringEncoding]];
        i++;
        currentValue = value[i];
    }

    return [NSArray arrayWithArray:strings];
}

- (long)getIntOptionWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    long value = cmd_ln_int_r(self.config, cName);

    return value;
}

- (double)getFloatOptionWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    double value = cmd_ln_float_r(self.config, cName);

    return value;
}

- (void)setValue:(NSObject*)value forOptionWithName:(NSString*)name
{
    NTPocketSphinxConfigArgument* argument = self.arguments[name];

    if (argument) {
        if (argument.type & ARG_INTEGER) {
            NSNumber* number = (NSNumber*)value;
            [self setIntValue:number.longValue forOptionWithName:name];
        }
        else if (argument.type & ARG_FLOATING) {
            NSNumber* number = (NSNumber*)value;
            [self setFloatValue:number.doubleValue forOptionWithName:name];
        }
        else if (argument.type & ARG_STRING) {
            NSString* string = (NSString*)value;
            [self setStringValue:string forOptionWithName:name];
        }
    }
    else {
        NSLog(@"No config argument named %@ existsing.", name);
    }
}

- (void)setStringValue:(NSString*)value forOptionWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cValue = [value cStringUsingEncoding:NSUTF8StringEncoding];

    cmd_ln_set_str_r(self.config, cName, cValue);
}

- (void)setIntValue:(long)value forOptionWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];

    cmd_ln_set_int_r(self.config, cName, value);
}

- (void)setFloatValue:(double)value forOptionWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];

    cmd_ln_set_float_r(self.config, cName, value);
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
