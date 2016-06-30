//
//  NTPocketSphinxConfigArgument.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 28/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "pocketsphinx.h"
#import <Foundation/Foundation.h>

/*!
 *  Simple class that represents a argument in the pocketsphinx config.
 */
@interface NTPocketSphinxConfigArgument : NSObject

/*!
 *  Name of the argument (inclusive -)
 */
@property (nonatomic, strong, readonly) NSString* name;

/*!
 *  Type of the argument (see http://cmusphinx.sourceforge.net/doc/sphinxbase/cmd__ln_8h.html values for argtypes)
 */
@property (nonatomic, readonly) int type;

/*!
 *  The default value
 */
@property (nonatomic, strong, readonly) NSString* defaultValue;

/*!
 *  The description of this argument.
 */
@property (nonatomic, strong, readonly) NSString* documentation;

- (instancetype)initWithName:(NSString*)name type:(int)type defaultValue:(NSString*)defaultValue doc:(NSString*)doc;

@end
