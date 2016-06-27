//
//  NTPocketSphinxRecognizer.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 27/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NTPocketSphinxDecoder.h"
#import "NTSpeechRecognizer.h"

@interface NTPocketSphinxRecognizer : NSObject <NTSpeechRecognizer>

@property (nonatomic, strong, readonly) NTPocketSphinxDecoder* decoder;

- (instancetype)initWithAudioSource:(NTAudioSource*)audioSource;

- (instancetype)initWithPocketSphinxDecoder:(NTPocketSphinxDecoder*)decoder;

- (instancetype)initWithPocketSphinxDecoder:(NTPocketSphinxDecoder*)decoder audioSource:(NTAudioSource*)audioSource;

@end
