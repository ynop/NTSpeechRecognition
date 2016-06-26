//
//  NTPocketSphinxConfiguration.h
//  NTSpeechRecognizer
//
//  Created by Matthias Büchi on 21/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTPocketSphinxConfig : NSObject

@property (nonatomic) void* ps_config;

- (instancetype)initWithOptions:(NSDictionary<NSString*, NSString*>*)options;

#pragma mark - Generic Access
/*!
 *  Set a list of options
 *
 *  @param options Name/Value pairs
 */
- (void)setOptions:(NSDictionary<NSString*, NSString*>*)options;

/*!
 *  Get value of option
 *
 *  @param name Name
 *
 *  @return Value or nil if option doesn't exist
 */
- (NSString*)getOptionWithName:(NSString*)name;

/*!
 *  Set the value of an option
 *
 *  @param value Value
 *  @param name  Name of the option
 */
- (void)setValue:(NSString*)value forOptionWithName:(NSString*)name;

#pragma mark - Convenience Constructor
/*!
 *  Create config with options
 *
 *  @param options name/value pairs
 *
 *  @return instance
 */
+ (NTPocketSphinxConfig*)configWithOptions:(NSDictionary<NSString*, NSString*>*)options;

/*!
 *  Create config with HMM dir
 *
 *  @param path Path to HMM dir
 *
 *  @return instance
 */
+ (NTPocketSphinxConfig*)configWithPathToAcousticModel:(NSString*)path;

@end
