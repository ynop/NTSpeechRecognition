//
//  NTAudioSource.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 24/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class NTAudioSource;

/*!
 *  Delegate that receives data produced/read by the audio source.
 */
@protocol NTAudioSourceDelegate <NSObject>

/*!
 *  Notification on new data
 *
 *  @param audioSource Source
 *  @param data        Data
 */
- (void)audioSource:(NTAudioSource*)audioSource didReadData:(NSData*)data;

@end

/*!
 *  Base class for nn audio source. This is a component that produces audio data (e.g. reading from mic).
 *
 *  Default Audio Format is Mono 16Bit PCM 16000 rate
 */
@interface NTAudioSource : NSObject

/*!
 *  Whether the audio source currently produces data.
 */
@property (nonatomic, readonly) BOOL started;

/*!
 *  Whether the audio source is suspended.
 */
@property (nonatomic, readonly) BOOL suspended;

/*!
 *  The format of the audio data, this source is producing.
 */
@property (nonatomic, readonly) AudioStreamBasicDescription format;

/*!
 *  Create a source with the given format.
 *
 *  @param format Format
 *
 *  @return instance
 */
- (instancetype)initWithFormat:(AudioStreamBasicDescription)format;

#pragma mark - Processing
/*!
 *  Start producing audio.
 *
 *  @return YES on success, NO otherwise
 */
- (BOOL)start;

/*!
 *  Suspend producing audio.
 *
 *  @return YES on success, NO otherwise
 */
- (BOOL)suspend;

/*!
 *  Resume producing audio.
 *
 *  @return YES on success, NO otherwise
 */
- (BOOL)resume;

/*!
 *  Stop producing audio.
 *
 *  @return YES on success, NO otherwise
 */
- (BOOL)stop;

#pragma mark - Delegates
/*!
 *  Adds a delegate
 *
 *  @param delegate delegate
 */
- (void)addDelegate:(id<NTAudioSourceDelegate>)delegate;

/*!
 *  Removes a delegate
 *
 *  @param delegate delegate
 */
- (void)removeDelegate:(id<NTAudioSourceDelegate>)delegate;

#pragma mark - Subclassing
/*!
 *  Only for subclasses. Notifies all delegates that new data is available.
 *
 *  @param data Data
 */
- (void)notifyDelegatesDidReadData:(NSData*)data;

#pragma mark - Formats
/*!
 *  Audio Format with the following settings:
 *  Sample Rate = 16'000
 *  Format = Linear PCM
 *  Channels = 1
 *  Bits per Channel = 16
 *  Little Endian
 *  Signed Int
 *  Non interleaved
 *
 *  @return Format Description
 */
+ (AudioStreamBasicDescription)monoPCM16kInt16;

@end
