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

/*!
 *  Speech Recognizer base on the pocketsphinx decoder.
 */
@interface NTPocketSphinxRecognizer : NSObject <NTSpeechRecognizer>

/*!
 *  The pocketsphinx decoder used to decode data.
 */
@property (nonatomic, strong, readonly) NTPocketSphinxDecoder* decoder;

/*!
 *  The sample rate of audio data.
 */
@property (nonatomic) int sampleRate;

/*!
 *  Threshold to detect a pause between utterances in seconds.
 */
@property (nonatomic) CFTimeInterval pauseThreshold;

- (instancetype)initWithAudioSource:(NTAudioSource*)audioSource;

- (instancetype)initWithPocketSphinxDecoder:(NTPocketSphinxDecoder*)decoder;

- (instancetype)initWithPocketSphinxDecoder:(NTPocketSphinxDecoder*)decoder audioSource:(NTAudioSource*)audioSource;

@end
